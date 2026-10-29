$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$workflow = (Get-Content -LiteralPath (Join-Path $repoRoot '.github\workflows\tarot-app-review-rc.yml') -Raw) -replace "`r`n", "`n"
$project = Get-Content -LiteralPath (Join-Path $repoRoot 'native-ios\TarotDeck.xcodeproj\project.pbxproj') -Raw

if ($workflow -notmatch '(?m)^on:\s*\n\s{2}workflow_dispatch:\s*$' -or
    $workflow -match '(?m)^\s{2}(push|pull_request|pull_request_target|schedule|repository_dispatch|workflow_run):') {
    throw 'Public RC upload must be manual-only.'
}
$required = @(
    'public_rc_confirmation:', 'default: "DO_NOT_UPLOAD"', '"PUBLIC_1_2_1_BUILD_1"',
    "if: `${{ github.ref == 'refs/heads/main' && inputs.public_rc_confirmation == 'PUBLIC_1_2_1_BUILD_1' && inputs.release_readiness == 'PRIVACY_SOURCE_REVIEWED' && inputs.verified_source_sha == github.sha && inputs.readiness_evidence != '' && inputs.readiness_evidence != 'PENDING' && (inputs.private_ci_clearance == 'PRIVATE_CI_NO_SPEND_VERIFIED' || inputs.private_ci_clearance == 'PUBLIC_STANDARD_RUNNER_NO_SPEND_VERIFIED') }}",
    'release_readiness:', 'verified_source_sha:', 'readiness_evidence:', 'private_ci_clearance:',
    '"PUBLIC_STANDARD_RUNNER_NO_SPEND_VERIFIED"',
    'Verify repository visibility matches the authorized CI route',
    'GH_METADATA_TOKEN: ${{ github.token }}',
    'CI_CLEARANCE: ${{ inputs.private_ci_clearance }}',
    'curl --fail --silent --show-error',
    '"$GITHUB_API_URL/repos/$GITHUB_REPOSITORY"',
    '.full_name == $repository',
    '.private == false and .visibility == "public"',
    '.private == true and .visibility == "private"',
    'billingVerifiedByAPI: false',
    'cp "$RUNNER_TEMP/tarot-ci-route.json" "$OUTPUT_PATH/ci-route.json"',
    'default: "PENDING"', 'Record external readiness declaration for the exact source',
    'automatedPrivacyCertification: false', 'automatedPhysicalATTValidation: false',
    'cp "$RUNNER_TEMP/tarot-release-readiness.json" "$OUTPUT_PATH/readiness.json"',
    'environment: app-store-production', 'cancel-in-progress: false', 'persist-credentials: false',
    './native-ios/Tools/validate-app-review-workflow.ps1', './native-ios/Content/validate-content.ps1',
    './native-ios/Content/Education/validate-education.ps1', './native-ios/Content/Localization/validate-localization.ps1',
    './native-ios/Tools/validate-app-integration.ps1', 'python3 native-ios/Tools/validate-monetization.py',
    'swift test --package-path native-ios --parallel', '-configuration Debug -sdk iphonesimulator',
    'Record simulator privacy capabilities without changing permissions', 'xcrun simctl help privacy',
    'Verify real sample consent choices in simulator', '-only-testing:TarotConsentUITests',
    '-parallel-testing-enabled NO', 'TarotConsentQA.xcresult', 'Preserve native consent QA result',
    'tarot-consent-tests.log', 'tarot-qa-simctl-privacy-help.txt',
    'Sample integration does not certify production AdMob message configuration or physical-device ATT behavior.',
    'grep -q test_banner_loaded', '--qa-consent-eea', 'grep -q consent_form_presenting',
    'for language in spanish english',
    '--qa-remove-ads "--qa-$language" --qa-prices "$PRICES" --qa-active-product com.krazel.tarotdeck.support.monthly.499',
    'tarot-remove-ads-active-$language.png',
    'Prepare existing distribution certificate and Tarot profile',
    'Archive signed Release app with existing distribution identity', '-configuration Release',
    'CODE_SIGN_STYLE=Manual', 'CODE_SIGN_IDENTITY="Apple Distribution"',
    'PROVISIONING_PROFILE_SPECIFIER="Tarot Deck App Store 2026-10-18"',
    'CURRENT_PROJECT_VERSION=1', 'MARKETING_VERSION=1.2.1',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS=TAROT_PRODUCTION_ADS', 'TAROT_ADS_MODE=production',
    'PrivacyInfo.xcprivacy', 'Mazo de tarot', 'ITSAppUsesNonExemptEncryption', 'TarotBannerAdUnitID',
    'codesign --verify --deep --strict', 'get-task-allow', 'embedded.mobileprovision',
    'destination string export', 'destination string upload', 'internalTestingOnly: false',
    'externalTestingCapable: true', 'appStoreReleaseCapable: true', 'submittedForReview: false',
    'advertisingMode: "production"', 'admobApplicationID: $admobApplicationID', 'admobBannerID: $admobBannerID',
    'ciRunNumber: $ciRunNumber', 'ciRunAttempt: $ciRunAttempt', 'ciRunID: $ciRunID',
    'Preserve non-binary RC evidence', 'Remove temporary signing material', 'if: ${{ always() }}',
    'security delete-keychain', 'retention-days: 7'
)
foreach ($contract in $required) {
    if (-not $workflow.Contains($contract)) { throw "Missing public RC workflow contract: $contract" }
}
foreach ($contract in @(
    '"--sdk", "iphonesimulator", "--show-sdk-version"',
    'version(item["version"]) <= version(sdk)',
    'runtime = max(compatible, key=lambda item: version(item["version"]))',
    'runtime.get("supportedDeviceTypes", [])',
    '["xcrun", "simctl", "create", name, device_type["identifier"], runtime["identifier"]]',
    'TAROT_QA_DEVICE_ID=', 'Fresh smoke simulator ID is required',
    'tarot-qa-created-device.json', 'tarot-qa-boot.log',
    '600 - (time.monotonic() - started)', 'check=True',
    'tarot-qa-before-app.png', 'tarot-qa-after-launch-non-eea.png', 'tarot-qa-after-launch-eea.png',
    'trap finish_smoke EXIT', 'exit "$status"', 'tarot-qa-crash-report-index.json',
    '"--info", "--debug"', 'log stream --level debug', 'kill -0 "$APP_PID"',
    '--qa-consent-non-eea --qa-consent-observe --qa-english',
    '--qa-consent-eea --qa-consent-observe --qa-english',
    '${{ runner.temp }}/tarot-qa-*',
    '-only-testing:TarotConsentUITests/TarotConsentUITests/testNonEEAATTDenialAllowsTestBanner',
    'TarotATTDenialSmoke.xcresult', 'tarot-att-denial-smoke.log',
    "grep -Eq 'testNonEEAATTDenialAllowsTestBanner.*passed'",
    'Running six UMP/ATT sample integration tests.'
)) {
    if (-not $workflow.Contains($contract)) { throw "Missing fresh simulator or smoke diagnostic contract: $contract" }
}
$bootstrapStart = $workflow.IndexOf('-only-testing:TarotConsentUITests/TarotConsentUITests/testNonEEAATTDenialAllowsTestBanner')
$firstCLILaunch = $workflow.IndexOf('xcrun simctl launch "$DEVICE_ID"')
if ($bootstrapStart -lt 0 -or $firstCLILaunch -le $bootstrapStart -or
    $workflow.Substring($bootstrapStart, $firstCLILaunch - $bootstrapStart) -match 'simctl (uninstall|install)|--qa-consent-reset' -or
    $workflow -notmatch '(?s)name: Preserve native consent QA result\s+if: \$\{\{ always\(\) \}\}.*?TarotATTDenialSmoke\.xcresult.*?tarot-att-denial-smoke\.log') {
    throw 'Real ATT denial bootstrap must precede CLI launch, retain its choices and preserve test evidence even on failure.'
}
if ($workflow.Contains('[0].udid') -or $workflow -match '(?m)^\s*xcrun simctl boot .*\|\| true') {
    throw 'Never select the first pre-existing simulator or suppress a failed boot.'
}
if ([regex]::Matches($workflow, '(?m)^\s*runs-on:\s*macos-latest\s*$').Count -ne 1 -or
    [regex]::Matches($workflow, '(?m)^\s*runs-on:').Count -ne 1 -or
    $workflow.IndexOf('Verify repository visibility matches the authorized CI route') -gt
    $workflow.IndexOf('Check out repository without retained credentials') -or
    $workflow -notmatch '(?m)^permissions:\s*\n\s{2}contents: read\s*$' -or
    $workflow -match '(?i)echo[^\r\n]*GH_METADATA_TOKEN|curl[^\r\n]*--verbose') {
    throw 'The declared no-spend CI route requires a standard runner, read-only metadata verification before checkout, and no token output.'
}
foreach ($contract in @(
    'testFlightInternalTestingOnly bool true',
    'CODE_SIGN_STYLE=Automatic', 'signingStyle string automatic', 'manageAppVersionAndBuildNumber bool true',
    'submitForReview', 'reviewSubmissions', 'appStoreVersionSubmissions', 'betaAppReviewSubmissions',
    'phasedRelease', 'automaticReleaseDate', 'releaseToAllUsers', 'set -x',
    'validate-app-review-metadata.ps1', '-InternalTestFlightGate', '-ReleaseGate'
)) {
    if ($workflow.Contains($contract)) { throw "Forbidden or obsolete public RC contract: $contract" }
}
foreach ($contract in @(
    'Add :testFlightInternalTestingOnly bool false', 'Add :manageAppVersionAndBuildNumber bool false',
    'Add :signingStyle string manual', 'Add :signingCertificate string Apple Distribution',
    'Add :provisioningProfiles:com.krazel.tarotdeck string Tarot Deck App Store 2026-10-18',
    '[[ "$ADMOB_APP_ID" == "ca-app-pub-3425091654264901~4270953811" ]]',
    '[[ "$ADMOB_BANNER_ID" == "ca-app-pub-3425091654264901/3573694673" ]]',
    'Print :NSUserTrackingUsageDescription', 'for language in en es; do',
    'plutil -extract NSUserTrackingUsageDescription raw'
)) {
    if ([regex]::Matches($workflow, [regex]::Escape($contract)).Count -ne 2) {
        throw "Both archive/IPA or export/upload phases must enforce: $contract"
    }
}
$expectedSecrets = @(
    'APPLE_TEAM_ID', 'APP_STORE_CONNECT_API_KEY_ID', 'APP_STORE_CONNECT_ISSUER_ID',
    'APP_STORE_CONNECT_API_KEY_BASE64', 'IOS_DISTRIBUTION_P12_BASE64',
    'IOS_DISTRIBUTION_P12_PASSWORD', 'IOS_APP_STORE_PROFILE_BASE64'
) | Sort-Object
$actualSecrets = @([regex]::Matches($workflow, '\$\{\{\s*secrets\.(?<name>[A-Z0-9_]+)\s*\}\}') |
    ForEach-Object { $_.Groups['name'].Value } | Sort-Object -Unique)
if (@(Compare-Object $expectedSecrets $actualSecrets).Count -gt 0) {
    throw 'Only the existing approved signing and upload secrets are allowed.'
}
$archiveStart = $workflow.IndexOf('Archive signed Release app with existing distribution identity')
$exportStart = $workflow.IndexOf('Export signed public-capable IPA')
$uploadStart = $workflow.IndexOf('Upload binary to App Store Connect without submitting for review')
if ($archiveStart -lt 0 -or $exportStart -le $archiveStart -or $uploadStart -le $exportStart) {
    throw 'Signed archive, export/verification and upload must occur in that order.'
}
$archiveBlock = $workflow.Substring($archiveStart, $exportStart - $archiveStart)
if ($archiveBlock.Contains('CODE_SIGNING_ALLOWED=NO') -or $archiveBlock.Contains('CODE_SIGNING_REQUIRED=NO')) {
    throw 'The public archive must use the existing distribution signature.'
}
$signingStart = $workflow.IndexOf('Prepare App Store Connect upload key')
$testsStart = $workflow.IndexOf('Verify real sample consent choices in simulator')
$evidenceStart = $workflow.IndexOf('Preserve native consent QA result')
if ($testsStart -lt 0 -or $evidenceStart -le $testsStart -or $signingStart -le $evidenceStart) {
    throw 'Native consent tests and evidence must precede signing.'
}
$signedPipeline = $workflow.Substring($signingStart)
if ($signedPipeline.Contains('TAROT_TEST_ADS') -or $signedPipeline.Contains('ca-app-pub-3940256099942544') -or
    $signedPipeline.Contains('TAROT_ADS_MODE=test-only')) {
    throw 'Google sample inventory and DEBUG test conditions must never enter the public archive/export/upload.'
}
foreach ($contract in @(
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG TAROT_TEST_ADS"', 'TAROT_ADS_MODE=test-only',
    "TAROT_ADMOB_APP_ID='ca-app-pub-3940256099942544~1458002511'",
    "TAROT_ADMOB_BANNER_ID='ca-app-pub-3940256099942544/2435281174'"
)) {
    if ([regex]::Matches($workflow.Substring(0, $signingStart), [regex]::Escape($contract)).Count -ne 3) {
        throw "Unsigned simulator build, ATT bootstrap and full consent suite must use: $contract"
    }
}
if ($workflow -match '(?i)xcrun\s+simctl\s+privacy\s+[^\r\n]*(grant|revoke|reset)|TCC\.db|\btccutil\b' -or
    $workflow -match '(?m)^\s*continue-on-error:\s*true' -or
    $workflow -notmatch '(?s)name: Verify real sample consent choices in simulator.*?set -euo pipefail.*?xcodebuild test') {
    throw 'Do not bypass native QA failures or mutate tracking permissions in the upload workflow.'
}
if ($workflow -match '(?m)^\s*cp\s+"\$SOURCE_IPA"' -or
    $workflow -notmatch '(?m)^\s*IPA_PATH="\$SOURCE_IPA"$') {
    throw 'The signed IPA must remain runner-local; preserve only checksum and manifest evidence.'
}
$artifactSteps = @($workflow -split '(?m)^      - name:' | Where-Object { $_.Contains('uses: actions/upload-artifact@v4') })
if ($artifactSteps.Count -ne 3) { throw 'Only screenshots, native QA results and non-binary RC evidence uploads are allowed.' }
foreach ($step in $artifactSteps) {
    if ($step -match '(?i)(\.ipa|\.p12|\.p8|mobileprovision|xcarchive|tarot-app-review-export)') {
        throw 'An artifact upload could expose a signed binary or signing material.'
    }
}
$unexpectedActions = @([regex]::Matches($workflow, '(?m)^\s*uses:\s*(?<value>\S+)\s*$') |
    ForEach-Object { $_.Groups['value'].Value } |
    Where-Object { $_ -notin @('actions/checkout@v4', 'actions/upload-artifact@v4') })
if ($unexpectedActions.Count -gt 0) { throw "Unexpected workflow action: $($unexpectedActions -join ', ')" }
if ([regex]::Matches($project, [regex]::Escape('MARKETING_VERSION = 1.2.1;')).Count -ne 2 -or
    [regex]::Matches($project, [regex]::Escape('CURRENT_PROJECT_VERSION = 1;')).Count -ne 2) {
    throw 'The Xcode project must expose Tarot Deck 1.2.1 (1) in Debug and Release.'
}
foreach ($pattern in @(
    'TAROT_ADMOB_APP_ID\s*=\s*"ca-app-pub-3425091654264901~4270953811";',
    'TAROT_ADMOB_BANNER_ID\s*=\s*"ca-app-pub-3425091654264901/3573694673";'
)) {
    if ([regex]::Matches($project, $pattern).Count -ne 1) {
        throw 'Production AdMob IDs must be configured for Tarot before starting public release CI.'
    }
}
Write-Host 'Validated manual public-capable Tarot Deck 1.2.1 (1): existing manual signing, production publisher checks, simulator ad/consent and active subscription screenshots, no binary artifacts, and separate API review submission.'
