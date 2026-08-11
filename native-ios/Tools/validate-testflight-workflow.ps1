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
$appValidator = Get-Content -Raw -LiteralPath $appValidatorPath
$project = Get-Content -Raw -LiteralPath $projectPath
$scheme = Get-Content -Raw -LiteralPath $schemePath

if ($workflow -notmatch '(?m)^on:\s*\n\s{2}workflow_dispatch:\s*$' -or
    $workflow -match '(?m)^\s{2}(push|pull_request|schedule|repository_dispatch):') {
    throw "TestFlight workflow must be manual-only."
}

$requiredContracts = @(
    'permissions:`n  contents: read',
    'internal_only_confirmation:',
    'default: "TESTFLIGHT_INTERNAL_ONLY"',
    "if: `${{ github.ref == 'refs/heads/main' && inputs.internal_only_confirmation == 'TESTFLIGHT_INTERNAL_ONLY' }}",
    'environment: app-store-production',
    'uses: actions/checkout@v4',
    'persist-credentials: false',
    './native-ios/Tools/validate-testflight-workflow.ps1',
    './native-ios/Content/validate-content.ps1',
    './native-ios/Content/Education/validate-education.ps1',
    './native-ios/Content/Localization/validate-localization.ps1',
    './native-ios/Tools/validate-app-integration.ps1 -InternalTestFlightGate',
    'swift test --package-path native-ios --parallel',
    '-scheme TarotDeckInternal',
    '-configuration Release',
    '-archivePath "$ARCHIVE_PATH"',
    '-allowProvisioningUpdates',
    '-authenticationKeyPath "$API_KEY_PATH"',
    '-authenticationKeyID "$APP_STORE_CONNECT_API_KEY_ID"',
    '-authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID"',
    'DEVELOPMENT_TEAM="$APPLE_TEAM_ID"',
    'CODE_SIGN_STYLE=Automatic',
    'CURRENT_PROJECT_VERSION=1',
    'MARKETING_VERSION=0.2.1',
    'Add :method string app-store-connect',
    'Add :destination string export',
    'Add :destination string upload',
    'Add :signingStyle string automatic',
    'Add :manageAppVersionAndBuildNumber bool false',
    'Add :testFlightInternalTestingOnly bool true',
    'CFBundleIdentifier',
    'com.krazel.tarotdeck',
    'CFBundleDisplayName',
    'Tarot Deck',
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
    'APP_STORE_CONNECT_API_KEY_BASE64'
)
$referencedSecrets = @(
    [regex]::Matches($workflow, '\$\{\{\s*secrets\.(?<name>[A-Z0-9_]+)\s*\}\}') |
        ForEach-Object { $_.Groups['name'].Value } |
        Sort-Object -Unique
)
if (@(Compare-Object ($requiredSecrets | Sort-Object) $referencedSecrets).Count -gt 0) {
    throw "TestFlight workflow must reference only the approved cloud-signing secret names."
}

$forbiddenPatterns = @(
    '(?i)BUILD_CERTIFICATE_BASE64|P12_PASSWORD|BUILD_PROVISION_PROFILE_BASE64|KEYCHAIN_PASSWORD',
    '(?i)\bReleaseGate\b',
    '(?i)external\s+(tester|testing|group)',
    '(?i)beta\s+app\s+review|app\s+review|submit\s+for\s+review',
    '(?i)manageAppVersionAndBuildNumber\s+bool\s+true',
    '(?i)testFlightInternalTestingOnly\s+bool\s+false',
    '(?i)\b(push|pull_request|schedule|repository_dispatch):',
    '(?i)\becho\s+"?\$\{?(APPLE_TEAM_ID|APP_STORE_CONNECT_API_KEY_ID|APP_STORE_CONNECT_ISSUER_ID|APP_STORE_CONNECT_API_KEY_BASE64)',
    '(?i)set\s+-x',
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
    'MARKETING_VERSION = 0.2.1;',
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
    [regex]::Matches($project, [regex]::Escape('MARKETING_VERSION = 0.2.1;')).Count -ne 2 -or
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

if ($appValidator -cnotmatch [regex]::Escape('[switch]$ReleaseGate') -or
    $appValidator -cnotmatch [regex]::Escape('[switch]$InternalTestFlightGate') -or
    $appValidator -cnotmatch [regex]::Escape('candidateOnly, finalAsset, distributionApproved, or territorial rights review is still pending.') -or
    $appValidator -cnotmatch [regex]::Escape('Validated INTERNAL-ONLY TestFlight artwork gate: 78/78 candidates are intact')) {
    throw "Public ReleaseGate and separate internal-only artwork gate must both remain explicit."
}

if ($localQAWorkflow -match '(?i)TestFlight|App Store Connect|\bsecrets\.|-exportArchive|destination string upload' -or
    $localQAWorkflow -notmatch '-configuration Debug' -or
    $localQAWorkflow -notmatch 'CODE_SIGNING_ALLOWED=NO') {
    throw "Local-QA workflow must remain unsigned and incapable of TestFlight upload."
}

Write-Host "Validated manual protected TestFlight INTERNAL-ONLY workflow for Tarot Deck 0.2.1 (1): main-only cloud signing is parameterized, only non-binary evidence is preserved, and no external/App Store path exists."
