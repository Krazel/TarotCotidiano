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
check(project.count('IPHONEOS_DEPLOYMENT_TARGET = 16.0;') == 2,
      'App target retains iOS16 in both configurations')
check(project.count('MARKETING_VERSION = 1.1.1;') == 2 and project.count('CURRENT_PROJECT_VERSION = 1;') == 2,
      'Candidate identity is 1.1.1 (1)')
check(project.count('INFOPLIST_FILE = TarotDeckApp/Resources/Advertising.plist;') == 2,
      'Debug and Release merge advertising plist')
plist = plistlib.loads((APP / 'Resources/Advertising.plist').read_bytes())
sample_app = 'ca-app-pub-3940256099942544~1458002511'
sample_banner = 'ca-app-pub-3940256099942544/2435281174'
check(plist['GADApplicationIdentifier'] == sample_app and plist['GADDelayAppMeasurementInit'] is True,
      'Only public Google sample application and delayed measurement configured')
all_swift = '\n'.join(path.read_text(encoding='utf-8') for path in APP.rglob('*.swift'))
check(set(re.findall(r'ca-app-pub-\d+[~/]\d+', all_swift)) == {sample_app, sample_banner},
      'Runtime source contains only official sample ad identifiers')
check(not re.search(r'import (AppTrackingTransparency|AdSupport)|ATTrackingManager|ASIdentifierManager|requestTrackingAuthorization', all_swift),
      'No ATT request, AdSupport import or application IDFA access')
consent = (APP / 'Internal/TarotAdConsent.swift').read_text(encoding='utf-8')
check('#if DEBUG || TAROT_TEST_ADS' in consent and '== \"test-only\"' in consent and 'return nil\n        #endif' in consent,
      'Ordinary Release stays off; internal test mode is explicit')
check('setPublisherFirstPartyIDEnabled(false)' in consent and 'publisherPrivacyPersonalizationState = .disabled' in consent,
      'Publisher first-party ID and personalization explicitly disabled before SDK start')
check('ConsentInformation.shared.canRequestAds' in consent and 'requestConsentInfoUpdate' in consent,
      'UMP consent info is refreshed and consulted rather than app-cached consent')
banner = (APP / 'Components/TarotBanner.swift').read_text(encoding='utf-8')
check('extras.additionalParameters = ["npa": "1"]' in banner and 'ConsentInformationBridge.canRequestAds' in banner,
      'Nonpersonalized request and fresh UMP request-boundary gate')
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
new_keys = ['Advertisement', 'Support the app without ads', 'Any monthly level removes ads while active. The full app stays free.',
            'See support options', 'Not now', "Don't ask again", 'Advertising choices',
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
report = {'date': '2026-10-18', 'type': 'offline structural validation', 'status': 'PASS',
          'checks': checks, 'swiftCompiled': False, 'xctestExecuted': False, 'nativeRuntimeQA': False}
(ROOT / 'docs/technical/monetization-20261018/VALIDATION.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(f'PASS: {len(checks)} offline structural checks; Swift compilation/XCTest/device QA NOT executed.')
