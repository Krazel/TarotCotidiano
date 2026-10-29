param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "../..")
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$workflowPath = Join-Path $root ".github/workflows/tarot-testflight-internal.yml"
$localQAWorkflowPath = Join-Path $root ".github/workflows/tarot-local-qa-ipa.yml"
$appValidatorPath = Join-Path $root "native-ios/Tools/validate-app-integration.ps1"
$projectPath = Join-Path $root "native-ios/TarotDeck.xcodeproj/project.pbxproj"
$schemePath = Join-Path $root "native-ios/TarotDeck.xcodeproj/xcshareddata/xcschemes/TarotDeckInternal.xcscheme"
$privacyManifestPath = Join-Path $root "native-ios/TarotDeckApp/Resources/PrivacyInfo.xcprivacy"

foreach ($path in @($workflowPath, $localQAWorkflowPath, $appValidatorPath, $projectPath, $schemePath, $privacyManifestPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required TestFlight input is missing: $path"
    }
}

$workflow = (Get-Content -Raw -LiteralPath $workflowPath) -replace "`r`n", "`n"
$localQAWorkflow = (Get-Content -Raw -LiteralPath $localQAWorkflowPath) -replace "`r`n", "`n"
$project = Get-Content -Raw -LiteralPath $projectPath
$scheme = Get-Content -Raw -LiteralPath $schemePath

if ($workflow -notmatch '(?m)^on:\s*\n\s{2}workflow_dispatch:\s*$' -or
    $workflow -match '(?m)^\s{2}(push|pull_request|schedule|repository_dispatch):') {
    throw "TestFlight workflow must be manual-only."
}

$requiredContracts = @(
    'permissions:`n  contents: read',
    'internal_only_confirmation:',
    'default: "DO_NOT_UPLOAD"',
    'TESTFLIGHT_INTERNAL_ONLY_1_2_1_BUILD_1',
    "if: `${{ github.ref == 'refs/heads/main' && inputs.internal_only_confirmation == 'TESTFLIGHT_INTERNAL_ONLY_1_2_1_BUILD_1' }}",
    'environment: app-store-production',
    'uses: actions/checkout@v4',
    'persist-credentials: false',
    './native-ios/Tools/validate-testflight-workflow.ps1',
    './native-ios/Content/validate-content.ps1',
    './native-ios/Content/Education/validate-education.ps1',
    './native-ios/Content/Localization/validate-localization.ps1',
    './native-ios/Tools/validate-app-integration.ps1',
    'python3 native-ios/Tools/validate-monetization.py',
    '[[ "$(git rev-parse HEAD)" == "$GITHUB_SHA" ]]',
    'swift test --package-path native-ios --parallel',
    '-scheme TarotDeckInternal',
    '-configuration Release',
    '-archivePath "$ARCHIVE_PATH"',
    '-allowProvisioningUpdates',
    '-authenticationKeyPath "$API_KEY_PATH"',
    '-authenticationKeyID "$APP_STORE_CONNECT_API_KEY_ID"',
    '-authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID"',
    'DEVELOPMENT_TEAM="$APPLE_TEAM_ID"',
    'CODE_SIGN_STYLE=Manual',
    'CODE_SIGN_IDENTITY="Apple Distribution"',
    'PROVISIONING_PROFILE_SPECIFIER="Tarot Deck App Store 2026-10-18"',
    'CURRENT_PROJECT_VERSION=1',
    'MARKETING_VERSION=1.2.1',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG TAROT_TEST_ADS"',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS=TAROT_TEST_ADS',
    'TAROT_ADS_MODE=test-only',
    "TAROT_ADMOB_APP_ID='ca-app-pub-3940256099942544~1458002511'",
    "TAROT_ADMOB_BANNER_ID='ca-app-pub-3940256099942544/2435281174'",
    'Print :TarotBannerAdUnitID',
    'grep -q test_banner_loaded',
    'grep -q consent_form_presenting',
    'for language in spanish english; do',
    '--qa-active-product com.krazel.tarotdeck.support.monthly.499',
    'Google sample app/banner identifiers only; no production inventory.',
    'Add :method string app-store-connect',
    'Add :destination string export',
    'Add :destination string upload',
    'Add :signingStyle string manual',
    'Add :signingCertificate string Apple Distribution',
    'Add :provisioningProfiles:com.krazel.tarotdeck string Tarot Deck App Store 2026-10-18',
    'Add :manageAppVersionAndBuildNumber bool false',
    'Add :testFlightInternalTestingOnly bool true',
    'CFBundleIdentifier',
    'com.krazel.tarotdeck',
    'CFBundleDisplayName',
    'Tarot Deck',
    'es.lproj/InfoPlist.strings',
    'Mazo de tarot',
    'CFBundleShortVersionString',
    'CFBundleVersion',
    'MinimumOSVersion',
    'ITSAppUsesNonExemptEncryption',
    'PrivacyInfo.xcprivacy',
    'lipo -archs',
    'codesign --verify --deep --strict',
    "Print :get-task-allow",
    'security cms -D -i',
    'Print :Entitlements:get-task-allow',
    'TestFlight-Internal',
    'internalTestingOnly: true',
    'externalTestingCapable: false',
    'appStoreReleaseCapable: false',
    'advertisingMode: "test-only"',
    'advertisingInventory: "Google sample IDs"',
    'ciRunNumber: $ciRunNumber',
    'uses: actions/upload-artifact@v4',
    'Preserve non-binary TestFlight evidence',
    'retention-days: 7'
)
foreach ($contract in $requiredContracts) {
    $normalizedContract = $contract -replace [regex]::Escape('`n'), "`n"
    if (-not $workflow.Contains($normalizedContract)) {
        throw "TestFlight workflow contract is missing: $contract"
    }
}

$requiredSecrets = @(
    'APPLE_TEAM_ID',
    'APP_STORE_CONNECT_API_KEY_ID',
    'APP_STORE_CONNECT_ISSUER_ID',
    'APP_STORE_CONNECT_API_KEY_BASE64',
    'IOS_DISTRIBUTION_P12_BASE64',
    'IOS_DISTRIBUTION_P12_PASSWORD',
    'IOS_APP_STORE_PROFILE_BASE64'
)
$referencedSecrets = @(
    [regex]::Matches($workflow, '\$\{\{\s*secrets\.(?<name>[A-Z0-9_]+)\s*\}\}') |
        ForEach-Object { $_.Groups['name'].Value } |
        Sort-Object -Unique
)
if (@(Compare-Object ($requiredSecrets | Sort-Object) $referencedSecrets).Count -gt 0) {
    throw "TestFlight workflow must reference only the approved API and distribution-signing secret names."
}

$forbiddenPatterns = @(
    '(?i)BUILD_CERTIFICATE_BASE64|BUILD_PROVISION_PROFILE_BASE64|KEYCHAIN_PASSWORD',
    '(?i)\bReleaseGate\b',
    '(?i)\bInternalTestFlightGate\b|TAROT_PRODUCTION_ADS|TAROT_ADS_MODE=production',
    '(?i)external\s+(tester|testing|group)',
    '(?i)beta\s+app\s+review|app\s+review|submit\s+for\s+review',
    '(?i)manageAppVersionAndBuildNumber\s+bool\s+true',
    '(?i)testFlightInternalTestingOnly\s+bool\s+false',
    '(?i)\b(push|pull_request|schedule|repository_dispatch):',
    '(?i)\becho\s+"?\$\{?(APPLE_TEAM_ID|APP_STORE_CONNECT_API_KEY_ID|APP_STORE_CONNECT_ISSUER_ID|APP_STORE_CONNECT_API_KEY_BASE64)',
    '(?i)set\s+-x',
    '(?i)xcrun\s+simctl\s+privacy\s+[^\r\n]*(grant|revoke|reset)',
    '(?i)TCC\.db|\btccutil\b',
    '(?i)\bgh\s+(workflow|run|api|release)\b'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($workflow -match $pattern) {
        throw "TestFlight workflow crosses an internal-only or credential boundary: $pattern"
    }
}

if ([regex]::Matches($workflow, 'Add :testFlightInternalTestingOnly bool true').Count -ne 2 -or
    [regex]::Matches($workflow, 'Add :manageAppVersionAndBuildNumber bool false').Count -ne 2 -or
    [regex]::Matches($workflow, 'Add :destination string upload').Count -ne 1) {
    throw "Both export and upload must be permanently internal-only with fixed source version/build."
}

$sampleAppID = 'ca-app-pub-3940256099942544~1458002511'
$sampleBannerID = 'ca-app-pub-3940256099942544/2435281174'
$workflowAdIDs = @([regex]::Matches($workflow, 'ca-app-pub-\d+[~/]\d+') |
    ForEach-Object { $_.Value } | Sort-Object -Unique)
if (@(Compare-Object (@($sampleAppID, $sampleBannerID) | Sort-Object) $workflowAdIDs).Count -gt 0 -or
    [regex]::Matches($workflow, [regex]::Escape("TAROT_ADMOB_APP_ID='$sampleAppID'")).Count -ne 3 -or
    [regex]::Matches($workflow, [regex]::Escape("TAROT_ADMOB_BANNER_ID='$sampleBannerID'")).Count -ne 3 -or
    [regex]::Matches($workflow, 'TAROT_ADS_MODE=test-only').Count -ne 3 -or
    [regex]::Matches($workflow, 'Print :GADApplicationIdentifier').Count -ne 3 -or
    [regex]::Matches($workflow, 'Print :TarotBannerAdUnitID').Count -ne 3) {
    throw "Simulator build, consent tests and signed archive must override production IDs with samples; simulator, archive and IPA must verify identifiers."
}

foreach ($contract in @(
    'Verify real sample consent choices in simulator', '-parallel-testing-enabled NO',
    '-only-testing:TarotConsentUITests', 'TarotConsentQA.xcresult',
    'Preserve native consent QA result', 'tarot-consent-tests.log',
    'Record simulator privacy capabilities without changing permissions',
    'xcodebuild -version', 'xcrun simctl help privacy',
    'tarot-qa-xcode-version.txt', 'tarot-qa-simulator-runtimes.json',
    'tarot-qa-simulator-devices.json', 'tarot-qa-simctl-privacy-help.txt',
    'The UMP sample message does not certify the production IDFA explainer or the real ATT prompt.',
    'Any observed ATT state must come from the OS; no production consent fixture is supplied.'
)) {
    if (-not $workflow.Contains($contract)) { throw "Missing native consent QA contract: $contract" }
}

if ($workflow.IndexOf('Record simulator privacy capabilities without changing permissions') -gt
    $workflow.IndexOf('Prepare App Store Connect cloud-signing key') -or
    $workflow -notmatch '(?s)name: Preserve native consent QA result\s+if: \$\{\{ always\(\) \}\}.*?tarot-qa-simctl-privacy-help\.txt') {
    throw "Native privacy evidence must precede signing and be retained on failed QA runs."
}

if ($workflow -match '(?m)^\s*cp\s+"\$SOURCE_IPA"' -or
    $workflow -match '(?m)^\s*IPA_PATH="\$OUTPUT_PATH/.+\.ipa"' -or
    $workflow -notmatch '(?m)^\s*IPA_PATH="\$SOURCE_IPA"$') {
    throw "The signed IPA must remain runner-local; GitHub may preserve only its manifest and checksum evidence."
}

$uses = @(
    [regex]::Matches($workflow, '(?m)^\s*uses:\s*(?<value>\S+)\s*$') |
        ForEach-Object { $_.Groups['value'].Value }
)
$unexpectedActions = @($uses | Where-Object {
    $_ -notin @('actions/checkout@v4', 'actions/upload-artifact@v4')
})
if ($unexpectedActions.Count -gt 0) {
    throw "Unexpected action in TestFlight workflow: $($unexpectedActions -join ', ')"
}

$projectContracts = @(
    'MARKETING_VERSION = 1.2.1;',
    'CURRENT_PROJECT_VERSION = 1;',
    'PRODUCT_BUNDLE_IDENTIFIER = com.krazel.tarotdeck.internal.provisional;',
    'PRODUCT_BUNDLE_IDENTIFIER = com.krazel.tarotdeck;',
    'INFOPLIST_KEY_CFBundleDisplayName = "Tarot Deck";',
    'INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;',
    'IPHONEOS_DEPLOYMENT_TARGET = 16.0;',
    'CODE_SIGN_STYLE = Automatic;'
)
foreach ($contract in $projectContracts) {
    if ($project -cnotmatch [regex]::Escape($contract)) {
        throw "Project is missing a TestFlight contract: $contract"
    }
}
if ($project -match '(?m)^\s*DEVELOPMENT_TEAM\s*=' -or
    [regex]::Matches($project, [regex]::Escape('MARKETING_VERSION = 1.2.1;')).Count -ne 2 -or
    [regex]::Matches($project, [regex]::Escape('CURRENT_PROJECT_VERSION = 1;')).Count -ne 2) {
    throw "Team must be workflow-parametrized and version/build must be exact in both configurations."
}

$schemeContracts = @(
    'buildForArchiving = "YES"',
    '<ArchiveAction',
    'buildConfiguration = "Release"'
)
foreach ($contract in $schemeContracts) {
    if ($scheme -cnotmatch [regex]::Escape($contract)) {
        throw "Shared scheme is not Release-archivable: $contract"
    }
}

if ([regex]::Matches($workflow, '(?m)^\s*\./native-ios/Tools/validate-app-integration\.ps1\s*$').Count -ne 1) {
    throw "Use the current normal app/artwork validation once; the historical territory-limited internal gate is not the candidate's distribution scope."
}

if ($localQAWorkflow -match '(?i)TestFlight|App Store Connect|\bsecrets\.|-exportArchive|destination string upload' -or
    $localQAWorkflow -notmatch '-configuration Debug' -or
    $localQAWorkflow -notmatch 'CODE_SIGNING_ALLOWED=NO') {
    throw "Local-QA workflow must remain unsigned and incapable of TestFlight upload."
}

Write-Host "Validated optional protected TestFlight INTERNAL-ONLY QA workflow for Tarot Deck 1.2.1 (1): default is no upload, sample ads remain internal-only, existing distribution signing is parameterized, only non-binary evidence is preserved, and no external/App Store path exists."
