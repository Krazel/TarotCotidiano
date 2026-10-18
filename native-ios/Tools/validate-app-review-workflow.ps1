$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$workflow = (Get-Content -LiteralPath (Join-Path $repoRoot '.github\workflows\tarot-app-review-rc.yml') -Raw) -replace "`r`n", "`n"
$project = Get-Content -LiteralPath (Join-Path $repoRoot 'native-ios\TarotDeck.xcodeproj\project.pbxproj') -Raw

if ($workflow -notmatch '(?m)^on:\s*\n\s{2}workflow_dispatch:\s*$' -or
    $workflow -match '(?m)^\s{2}(push|pull_request|pull_request_target|schedule|repository_dispatch|workflow_run):') {
    throw 'Public RC upload must be manual-only.'
}
$required = @(
    'public_rc_confirmation:', 'default: "DO_NOT_UPLOAD"', '"PUBLIC_1_2_BUILD_1"',
    "if: `${{ github.ref == 'refs/heads/main' && inputs.public_rc_confirmation == 'PUBLIC_1_2_BUILD_1' }}",
    'environment: app-store-production', 'cancel-in-progress: false', 'persist-credentials: false',
    './native-ios/Tools/validate-app-review-workflow.ps1', './native-ios/Content/validate-content.ps1',
    './native-ios/Content/Education/validate-education.ps1', './native-ios/Content/Localization/validate-localization.ps1',
    './native-ios/Tools/validate-app-integration.ps1', 'python3 native-ios/Tools/validate-monetization.py',
    'swift test --package-path native-ios --parallel', '-configuration Debug -sdk iphonesimulator',
    'grep -q test_banner_loaded', '--qa-consent-eea', 'grep -q consent_form_presenting',
    'for language in spanish english',
    '--qa-remove-ads "--qa-$language" --qa-prices "$PRICES" --qa-active-product com.krazel.tarotdeck.support.monthly.499',
    'tarot-remove-ads-active-$language.png',
    'Prepare existing distribution certificate and Tarot profile',
    'Archive signed Release app with existing distribution identity', '-configuration Release',
    'CODE_SIGN_STYLE=Manual', 'CODE_SIGN_IDENTITY="Apple Distribution"',
    'PROVISIONING_PROFILE_SPECIFIER="Tarot Deck App Store 2026-10-18"',
    'CURRENT_PROJECT_VERSION=1', 'MARKETING_VERSION=1.2',
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
    'testFlightInternalTestingOnly bool true', 'TAROT_TEST_ADS', 'ca-app-pub-3940256099942544',
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
    'Print :TarotAdvertisingMode', '^ca-app-pub-3425091654264901~[0-9]{10}$',
    '^ca-app-pub-3425091654264901/[0-9]{10}$'
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
if ($workflow -match '(?m)^\s*cp\s+"\$SOURCE_IPA"' -or
    $workflow -notmatch '(?m)^\s*IPA_PATH="\$SOURCE_IPA"$') {
    throw 'The signed IPA must remain runner-local; preserve only checksum and manifest evidence.'
}
$artifactSteps = @($workflow -split '(?m)^      - name:' | Where-Object { $_.Contains('uses: actions/upload-artifact@v4') })
if ($artifactSteps.Count -ne 2) { throw 'Only simulator and non-binary RC evidence uploads are allowed.' }
foreach ($step in $artifactSteps) {
    if ($step -match '(?i)(\.ipa|\.p12|\.p8|mobileprovision|xcarchive|tarot-app-review-export)') {
        throw 'An artifact upload could expose a signed binary or signing material.'
    }
}
$unexpectedActions = @([regex]::Matches($workflow, '(?m)^\s*uses:\s*(?<value>\S+)\s*$') |
    ForEach-Object { $_.Groups['value'].Value } |
    Where-Object { $_ -notin @('actions/checkout@v4', 'actions/upload-artifact@v4') })
if ($unexpectedActions.Count -gt 0) { throw "Unexpected workflow action: $($unexpectedActions -join ', ')" }
if ([regex]::Matches($project, [regex]::Escape('MARKETING_VERSION = 1.2;')).Count -ne 2 -or
    [regex]::Matches($project, [regex]::Escape('CURRENT_PROJECT_VERSION = 1;')).Count -ne 2) {
    throw 'The Xcode project must expose Tarot Deck 1.2 (1) in Debug and Release.'
}
foreach ($pattern in @(
    'TAROT_ADMOB_APP_ID\s*=\s*"ca-app-pub-3425091654264901~[0-9]{10}";',
    'TAROT_ADMOB_BANNER_ID\s*=\s*"ca-app-pub-3425091654264901/[0-9]{10}";'
)) {
    if ([regex]::Matches($project, $pattern).Count -ne 1) {
        throw 'Production AdMob IDs must be configured for Tarot before starting public release CI.'
    }
}
Write-Host 'Validated manual public-capable Tarot Deck 1.2 (1): existing manual signing, production publisher checks, simulator ad/consent and active subscription screenshots, no binary artifacts, and separate API review submission.'
