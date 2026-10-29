"""Offline structural checks. This does NOT compile Swift, execute XCTest, or simulate SDKs."""
from pathlib import Path
import hashlib
import json
import plistlib
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / 'native-ios/TarotDeckApp'
checks = []

def check(condition, description):
    if not condition:
        raise AssertionError(description)
    checks.append(description)

project = (ROOT / 'native-ios/TarotDeck.xcodeproj/project.pbxproj').read_text(encoding='utf-8')
definitions = re.findall(r'^\s*([A-F0-9]{24})\s*(?:/\*.*?\*/)?\s*=\s*\{\s*isa\s*=', project, re.M)
references = set(re.findall(r'\b[A-F0-9]{24}\b', project))
check(len(definitions) == len(set(definitions)) and references == set(definitions),
      'Xcode object IDs are unique and all referenced IDs are defined')
for name in ['TarotAdConsent.swift', 'SupportReminderStore.swift', 'TarotBanner.swift']:
    check(project.count(f'{name} in Sources') == 2 and project.count(f'path = {name};') == 1,
          f'{name} has one file reference and one target source membership')
for package, version in [('GoogleMobileAds', '12.14.0'), ('GoogleUserMessagingPlatform', '3.1.0')]:
    check(f'productName = {package};' in project and f'kind = exactVersion; version = {version};' in project,
          f'{package} exact pin and target linkage present')
check(project.count('repositoryURL = ') == 2, 'Exactly two authorized remote SDK package references')
check(project.count('IPHONEOS_DEPLOYMENT_TARGET = 16.0;') == 4,
      'App and UI test targets retain iOS16 in both configurations')
check(project.count('MARKETING_VERSION = 1.2.1;') == 2 and project.count('CURRENT_PROJECT_VERSION = 3;') == 2,
      'Candidate identity is 1.2.1 (3)')
check(project.count('INFOPLIST_FILE = TarotDeckApp/Resources/Advertising.plist;') == 2,
      'Debug and Release merge advertising plist')
plist = plistlib.loads((APP / 'Resources/Advertising.plist').read_bytes())
sample_app = 'ca-app-pub-3940256099942544~1458002511'
sample_banner = 'ca-app-pub-3940256099942544/2435281174'
check(plist['GADApplicationIdentifier'] == '$(TAROT_ADMOB_APP_ID)' and
      plist['TarotBannerAdUnitID'] == '$(TAROT_ADMOB_BANNER_ID)' and
      plist['GADDelayAppMeasurementInit'] is True,
      'Build-specific identifiers and delayed measurement configured')
all_swift = '\n'.join(path.read_text(encoding='utf-8') for path in APP.rglob('*.swift'))
configuration = (ROOT / 'native-ios/Sources/TarotDeckCore/AdvertisingConfiguration.swift').read_text(encoding='utf-8')
consent = (APP / 'Internal/TarotAdConsent.swift').read_text(encoding='utf-8')
publisher_app = 'ca-app-pub-3425091654264901~4270953811'
publisher_guard = consent[consent.index('enum TarotAdsConfiguration'):consent.index('    static var bannerID')]
check(set(re.findall(r'ca-app-pub-\d+[~/]\d+', all_swift + configuration)) == {sample_app, sample_banner, publisher_app}
      and all_swift.count(publisher_app) == 1
      and '#if DEBUG' in publisher_guard and '#if targetEnvironment(simulator)' in publisher_guard
      and '"TarotPublisherMessageQA") as? Bool == true' in publisher_guard
      and 'Bundle.main.bundleIdentifier == "com.krazel.tarotdeck.internal.provisional"' in publisher_guard
      and '"TarotAdvertisingMode") as? String == "test-only"' in publisher_guard
      and publisher_app in publisher_guard
      and '== AdvertisingConfiguration.sampleBannerID' in publisher_guard
      and '#if DEBUG\n        if publisherMessageQAEnabled { return AdvertisingConfiguration.sampleBannerID }' in consent,
      'Publisher App ID is permitted only by the exact DEBUG simulator/sample-banner CMP guard; live banner IDs remain build-config only')
check('NSUserTrackingUsageDescription' in plist and
      project.count('-framework AppTrackingTransparency') == 2 and
      not re.search(r'ASIdentifierManager|requestTrackingAuthorization', all_swift),
      'ATT purpose and framework configured; UMP owns the prompt with no duplicate/manual IDFA access')
info = json.loads((APP / 'Resources/InfoPlist.xcstrings').read_text(encoding='utf-8'))
check(all(info['strings']['NSUserTrackingUsageDescription']['localizations'][language]['stringUnit']['state'] == 'translated'
          for language in ['en', 'es']), 'ATT purpose text translated in EN/ES')
check('#if DEBUG || TAROT_TEST_ADS' in consent and '#elseif TAROT_PRODUCTION_ADS' in consent and
      'let allowsProduction = false' in consent and 'AdvertisingConfiguration.bannerID' in consent,
      'Development never uses real inventory; production needs explicit compilation and valid publisher configuration')
check('setPublisherFirstPartyIDEnabled(true)' in consent and 'publisherPrivacyPersonalizationState = .default' in consent and
      not re.search(r'publisherPrivacyPersonalizationState\s*=\s*\.(enabled|disabled)', consent),
      'Explicit publisher first-party enablement migrates prior persisted opt-out; no app-wide personalization override')
check('ConsentInformation.shared.canRequestAds' in consent and 'requestConsentInfoUpdate' in consent,
      'UMP consent info is refreshed and consulted rather than app-cached consent')
banner = (APP / 'Components/TarotBanner.swift').read_text(encoding='utf-8')
check('ConsentInformationBridge.canRequestAds' in banner and
      not re.search(r'additionalParameters\s*=.*[\"\']npa[\"\']', banner),
      'Fresh UMP request-boundary gate; no NPA override of user choices')
check('dismantleUIViewController' in banner and 'banner?.delegate = nil' in banner and 'banner?.removeFromSuperview()' in banner,
      'Controller teardown removes banner and detaches late callbacks')
check('.frame(height: loadedHeight)' in banner and 'onHeight(0)' in banner and '.transaction { $0.animation = nil }' in banner,
      'Loading/failure/exclusion has zero reserved banner height and no removal animation')
shell = (APP / 'App/TarotDeckMainShell.swift').read_text(encoding='utf-8')
check('MonetizationPolicy.surface(' in shell and 'tutorialReturnsToReading: tutorialReturnsToReading' in shell and 'hasLearnRoute: !learnPath.isEmpty' in shell,
      'Reading, contextual meaning and tutorial exclusions use the tested policy')
app = (APP / 'App/TarotDeckInternalApp.swift').read_text(encoding='utf-8')
check('readModel.surface != .home || readModel.hasActiveReading' in app and 'invalidateEntitlements()' in app,
      'Table entry/restoration and foreground stale-entitlement exclusion are wired at root')
check('adConsent.applicationDidBecomeActive()' in app and
      'guard !isBusy else { return }' in consent and 'requestGeneration += 1' in consent,
      'Foreground revalidation invalidates old requests without interrupting an in-flight consent flow')
store = (APP / 'Internal/SupporterStore.swift').read_text(encoding='utf-8')
original = json.loads((ROOT / 'store/tarot-subscriptions.v1.json').read_text(encoding='utf-8'))
ids = re.findall(r'"(com\.krazel\.tarotdeck\.support\.monthly\.[^"]+)"', store)
check(ids == [p['productID'] for p in original['products']] and len(ids) == 7,
      'All seven existing product IDs unchanged in canonical order')
check('Transaction.currentEntitlements' in store and '!transaction.isUpgraded' in store and
      'transaction.revocationDate == nil' in store and 'AppStore.sync()' in store,
      'Verified current rights, upgrades/revocations and Apple restore retained')
check('expirationDate >' not in store, 'No naive expiration-date filter that would revoke billing grace')
settings = (APP / 'Screens/Settings/SettingsView.swift').read_text(encoding='utf-8')
check('reminder.claimIfEligible(store: supporterStore)' in settings and
      'Button("Not now")' in settings and 'Button("Don\'t ask again")' in settings,
      'Reminder is optional inline Settings content with dismiss and persistent opt-out')
keys = json.loads((APP / 'Resources/required-interface-keys.v1.json').read_text(encoding='utf-8'))['keys']
catalog = json.loads((APP / 'Resources/Localizable.xcstrings').read_text(encoding='utf-8'))
new_keys = ['Advertisement', 'Read without ads', 'Choose a monthly option to remove ads. All readings and cards remain free.',
            'Remove ads', 'Not now', "Don't ask again", 'Advertising choices',
            'Opens advertising privacy choices', 'Advertising choices unavailable', 'Ads remain off. You can try again later.']
check(all(k in keys and catalog['strings'][k]['localizations']['es']['stringUnit']['state'] == 'translated' for k in new_keys),
      'New UI and AX copy covered by required EN/ES interface catalog')
audit = json.loads((ROOT / 'docs/technical/monetization-20261018/SDK_AUDIT.json').read_text(encoding='utf-8'))
check(len(audit['sdks']) == 2 and all(s['privacyManifests'] and s['sha256'] for s in audit['sdks']),
      'Exact SDK archive checksums and actual bundled privacy manifests recorded')
svg = ROOT / 'design/monetization-20261018/integration.svg'
ET.parse(svg)
check(hashlib.sha256(svg.read_text(encoding='utf-8').encode('utf-8')).hexdigest() in (svg.parent / 'REFERENCE.md').read_text(encoding='utf-8'),
      'Complete visual reference matches registered canonical UTF-8 LF SHA-256')
tests = (ROOT / 'native-ios/Tests/TarotDeckCoreTests/MonetizationPolicyTests.swift').read_text(encoding='utf-8')
check(tests.count('func test') == 4 and 'UserDefaults(suiteName: suite)' in tests and 'MonetizationPolicy.Surface.normal, .table, .restoring, .readingMeaning' in tests,
      'XCTest source covers banner gates, reminder boundaries and real UserDefaults persistence (not executed here)')
report = {'date': '2026-10-29', 'type': 'offline structural validation', 'status': 'PASS',
          'checks': checks, 'swiftCompiled': False, 'xctestExecuted': False, 'nativeRuntimeQA': False}
(ROOT / 'docs/technical/consent-ad-preferences-20261029/VALIDATION.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(f'PASS: {len(checks)} offline structural checks; Swift compilation/XCTest/device QA NOT executed.')
