param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "../..")
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$workflowPath = Join-Path $root ".github/workflows/tarot-local-qa-ipa.yml"
$appPath = Join-Path $root "native-ios/TarotDeckApp/App/TarotDeckInternalApp.swift"
$projectPath = Join-Path $root "native-ios/TarotDeck.xcodeproj/project.pbxproj"
$schemePath = Join-Path $root "native-ios/TarotDeck.xcodeproj/xcshareddata/xcschemes/TarotDeckInternal.xcscheme"

foreach ($path in @($workflowPath, $appPath, $projectPath, $schemePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required local QA input is missing: $path"
    }
}

$workflow = Get-Content -Raw -LiteralPath $workflowPath
$appSource = Get-Content -Raw -LiteralPath $appPath
$project = Get-Content -Raw -LiteralPath $projectPath
$scheme = Get-Content -Raw -LiteralPath $schemePath

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
    "EXECUTABLE_DESCRIPTION",
    "codesign -dv",
    "Payload/TarotDeckInternal.app",
    "zipinfo -1",
    'grep -Fqx "Payload/TarotDeckInternal.app/$EXECUTABLE_NAME"',
    "shasum -a 256",
    ".manifest.json",
    "INTERNAL ONLY - provisional RWS artwork - not for redistribution",
    "uses: actions/upload-artifact@v4",
    "local-qa-unsigned",
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
$debugIndex = $appSource.IndexOf("#if DEBUG", $bodyIndex)
$shellIndex = $appSource.IndexOf("TarotDeckMainShell(", $debugIndex)
$readIndex = $appSource.IndexOf("ReadRootView(", $debugIndex)
$elseIndex = $appSource.IndexOf("#else", $debugIndex)
$emptyIndex = $appSource.IndexOf("EmptyView()", $elseIndex)
if ($bodyIndex -lt 0 -or $debugIndex -lt $bodyIndex -or
    $shellIndex -lt $debugIndex -or $readIndex -lt $debugIndex -or
    $elseIndex -lt $shellIndex -or $emptyIndex -lt $elseIndex) {
    throw "Debug target does not demonstrably compile the real Tarot UI before the release-only EmptyView branch."
}

$requiredProjectContracts = @(
    'PRODUCT_BUNDLE_IDENTIFIER = com.krazel.tarotdeck.internal.provisional;',
    'MARKETING_VERSION = 0.0.1;',
    'CURRENT_PROJECT_VERSION = 1;',
    'IPHONEOS_DEPLOYMENT_TARGET = 17.0;',
    'TARGETED_DEVICE_FAMILY = 1;',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";'
)
foreach ($contract in $requiredProjectContracts) {
    if ($project -cnotmatch [regex]::Escape($contract)) {
        throw "Project contract required by local QA IPA is missing: $contract"
    }
}

$requiredSchemeContracts = @(
    'BuildableName = "TarotDeckInternal.app"',
    'BlueprintName = "TarotDeckInternal"',
    'buildForRunning = "YES"',
    'buildConfiguration = "Debug"'
)
foreach ($contract in $requiredSchemeContracts) {
    if ($scheme -cnotmatch [regex]::Escape($contract)) {
        throw "Shared scheme contract required by local QA IPA is missing: $contract"
    }
}

Write-Host "Validated manual local QA IPA workflow: Debug iphoneos, unsigned exact Payload, private short-lived artifact, and no release/upload/signing boundary."
