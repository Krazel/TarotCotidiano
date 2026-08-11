param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "../..")
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$workflowPath = Join-Path $root ".github/workflows/tarot-local-qa-ipa.yml"
$appPath = Join-Path $root "native-ios/TarotDeckApp/App/TarotDeckInternalApp.swift"
$projectPath = Join-Path $root "native-ios/TarotDeck.xcodeproj/project.pbxproj"
$schemePath = Join-Path $root "native-ios/TarotDeck.xcodeproj/xcshareddata/xcschemes/TarotDeckInternal.xcscheme"
$packagePath = Join-Path $root "native-ios/Package.swift"

foreach ($path in @($workflowPath, $appPath, $projectPath, $schemePath, $packagePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required local QA input is missing: $path"
    }
}

$workflow = Get-Content -Raw -LiteralPath $workflowPath
$appSource = Get-Content -Raw -LiteralPath $appPath
$project = Get-Content -Raw -LiteralPath $projectPath
$scheme = Get-Content -Raw -LiteralPath $schemePath
$package = Get-Content -Raw -LiteralPath $packagePath

if ($workflow -notmatch '(?m)^on:\s*\r?\n\s{2}workflow_dispatch:\s*$') {
    throw "Local QA IPA workflow must be manual-only with workflow_dispatch."
}
if ($workflow -match '(?m)^\s{2}(push|pull_request|schedule|repository_dispatch):') {
    throw "Local QA IPA workflow contains a non-manual trigger."
}

$requiredWorkflowContracts = @(
    "permissions:`n  contents: read",
    "runs-on: macos-latest",
    "uses: actions/checkout@v4",
    "persist-credentials: false",
    "./native-ios/Content/validate-content.ps1",
    "./native-ios/Content/Education/validate-education.ps1",
    "./native-ios/Content/Localization/validate-localization.ps1",
    "./native-ios/Tools/validate-app-integration.ps1",
    "swift test --package-path native-ios --parallel",
    "-configuration Debug",
    "-sdk iphoneos",
    "-destination 'generic/platform=iOS'",
    "CODE_SIGNING_ALLOWED=NO",
    "CODE_SIGNING_REQUIRED=NO",
    "AD_HOC_CODE_SIGNING_ALLOWED=NO",
    "Debug-iphoneos/TarotDeckInternal.app",
    "CFBundleExecutable",
    "DTPlatformName",
    "MinimumOSVersion",
    '[[ "$MINIMUM_OS_VERSION" != "16.0" ]]',
    '--arg minimumOSVersion "$MINIMUM_OS_VERSION"',
    'minimumOSVersion: $minimumOSVersion',
    '[[ "$VERSION" != "0.2.2" ]]',
    '[[ "$BUILD_NUMBER" != "1" ]]',
    "EXECUTABLE_DESCRIPTION",
    "codesign -dv",
    "Payload/TarotDeckInternal.app",
    "zipinfo -1",
    'grep -Fqx "Payload/TarotDeckInternal.app/$EXECUTABLE_NAME"',
    "shasum -a 256",
    ".manifest.json",
    "INTERNAL ONLY - provisional RWS artwork - not for redistribution",
    "uses: actions/upload-artifact@v4",
    'BASE_NAME="TarotDeck-${VERSION}-${BUILD_NUMBER}-ci${GITHUB_RUN_NUMBER}-${SHORT_COMMIT}-Local-QA-unsigned"',
    '--arg purpose "Local-QA"',
    'purpose: $purpose',
    '--arg artifact "$BASE_NAME"',
    'artifact: $artifact',
    '--arg ciRunNumber "$GITHUB_RUN_NUMBER"',
    'ciRunNumber: $ciRunNumber',
    '--arg ciRunAttempt "$GITHUB_RUN_ATTEMPT"',
    'ciRunAttempt: $ciRunAttempt',
    '--arg ciRunID "$GITHUB_RUN_ID"',
    'ciRunID: $ciRunID',
    "retention-days: 3"
)
$normalizedWorkflow = $workflow -replace "`r`n", "`n"
foreach ($contract in $requiredWorkflowContracts) {
    if (-not $normalizedWorkflow.Contains($contract)) {
        throw "Local QA IPA workflow contract is missing: $contract"
    }
}

$forbiddenWorkflowPatterns = @(
    '(?i)ReleaseGate',
    '(?i)TestFlight|App Store Connect',
    '(?i)\bsecrets\.',
    '(?m)^\s*environment:',
    '(?i)\barchive\b|-exportArchive',
    '(?i)\b(altool|notarytool|transporter)\b',
    '(?i)\bgh\s+(release|workflow|api)',
    '(?i)\b(curl|wget|scp|sftp|rsync|ftp)\b|Invoke-(WebRequest|RestMethod)|git\s+push',
    '(?i)BUILD_CERTIFICATE|PROVISION_PROFILE|P12_PASSWORD|KEYCHAIN_PASSWORD',
    '(?i)softprops/action-gh-release|actions/create-release|upload-release-asset'
)
foreach ($pattern in $forbiddenWorkflowPatterns) {
    if ($workflow -match $pattern) {
        throw "Local QA IPA workflow crosses a forbidden distribution/signing boundary: $pattern"
    }
}

$uses = @(
    [regex]::Matches($workflow, '(?m)^\s*uses:\s*(?<value>\S+)\s*$') |
        ForEach-Object { $_.Groups['value'].Value }
)
$unexpectedActions = @($uses | Where-Object {
    $_ -notin @('actions/checkout@v4', 'actions/upload-artifact@v4')
})
if ($unexpectedActions.Count -gt 0) {
    throw "Unexpected third-party or upload action in local QA workflow: $($unexpectedActions -join ', ')"
}

$bodyIndex = $appSource.IndexOf("var body: some Scene")
$shellIndex = $appSource.IndexOf("TarotDeckMainShell(", $bodyIndex)
$readIndex = $appSource.IndexOf("ReadRootView(", $bodyIndex)
if ($bodyIndex -lt 0 -or $shellIndex -lt $bodyIndex -or $readIndex -lt $shellIndex -or
    $appSource -match '#if\s+DEBUG|EmptyView\(\)') {
    throw "The composition root must compile the real Tarot UI in both Debug and Release."
}

$requiredProjectContracts = @(
    'PRODUCT_BUNDLE_IDENTIFIER = com.krazel.tarotdeck.internal.provisional;',
    'MARKETING_VERSION = 0.2.2;',
    'CURRENT_PROJECT_VERSION = 1;',
    'IPHONEOS_DEPLOYMENT_TARGET = 16.0;',
    'TARGETED_DEVICE_FAMILY = 1;',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";'
)
foreach ($contract in $requiredProjectContracts) {
    if ($project -cnotmatch [regex]::Escape($contract)) {
        throw "Project contract required by local QA IPA is missing: $contract"
    }
}

if ($project -cmatch 'MARKETING_VERSION = 0\.0\.1;' -or
    $project -cmatch 'MARKETING_VERSION = 0\.1\.0;' -or
    $workflow -cmatch 'local-qa-unsigned' -or
    $workflow -cmatch 'TarotDeck-\$\{VERSION\}-\$\{BUILD_NUMBER\}-local-qa') {
    throw "Legacy 0.0.1 or pre-versioning Local-QA artifact naming is still present."
}

if ($workflow -cmatch 'BUILD_NUMBER="\$GITHUB_RUN_NUMBER"' -or
    $workflow -cmatch 'CURRENT_PROJECT_VERSION="\$GITHUB_RUN_NUMBER"') {
    throw "GitHub run_number is CI evidence only and must not become CFBundleVersion."
}

$marketingVersions = @([regex]::Matches($project, 'MARKETING_VERSION = (?<value>\d+\.\d+(?:\.\d+)?);') |
    ForEach-Object { $_.Groups['value'].Value } | Select-Object -Unique)
if ($marketingVersions.Count -ne 1 -or $marketingVersions[0] -ne '0.2.2') {
    throw "The Xcode project must have exactly one formal marketing version: 0.2.2."
}

$projectBuildNumbers = @([regex]::Matches($project, 'CURRENT_PROJECT_VERSION = (?<value>\d+);') |
    ForEach-Object { $_.Groups['value'].Value } | Select-Object -Unique)
if ($projectBuildNumbers.Count -ne 1) {
    throw "CURRENT_PROJECT_VERSION must remain a separate numeric source build value."
}

if ($package -cnotmatch [regex]::Escape('.iOS(.v16)')) {
    throw "Swift package must declare iOS 16 support for the local QA build."
}

$requiredSchemeContracts = @(
    'BuildableName = "TarotDeckInternal.app"',
    'BlueprintName = "TarotDeckInternal"',
    'buildForRunning = "YES"',
    'buildConfiguration = "Debug"',
    'buildForArchiving = "YES"',
    '<ArchiveAction',
    'buildConfiguration = "Release"'
)
foreach ($contract in $requiredSchemeContracts) {
    if ($scheme -cnotmatch [regex]::Escape($contract)) {
        throw "Shared scheme contract required by local QA IPA is missing: $contract"
    }
}

Write-Host "Validated manual Local-QA IPA workflow: formal 0.2.2 (1), CI run and commit evidence, unsigned exact Payload, real UI in all configurations, and no release/upload/signing boundary."
