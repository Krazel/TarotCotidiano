$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$workflowPath = Join-Path $repoRoot '.github\workflows\tarot-app-review-rc.yml'
$projectPath = Join-Path $repoRoot 'native-ios\TarotDeck.xcodeproj\project.pbxproj'

if (-not (Test-Path -LiteralPath $workflowPath)) {
    throw 'Missing App Review RC workflow.'
}

$workflow = Get-Content -LiteralPath $workflowPath -Raw
$project = Get-Content -LiteralPath $projectPath -Raw

$required = @(
    'workflow_dispatch:',
    'default: "DO_NOT_UPLOAD"',
    '"UPLOAD_APP_REVIEW_RC_1_0_1"',
    "github.ref == 'refs/heads/main'",
    'environment: app-store-production',
    'persist-credentials: false',
    'validate-app-integration.ps1 -ReleaseGate -RequestedTerritories US,GB,ES',
    'validate-app-review-metadata.ps1',
    'swift test --package-path native-ios --parallel',
    '-configuration Release',
    'CURRENT_PROJECT_VERSION=1',
    'MARKETING_VERSION=1.0',
    'com.krazel.tarotdeck',
    'PrivacyInfo.xcprivacy',
    'Mazo de tarot',
    'ITSAppUsesNonExemptEncryption',
    'Archive public Release candidate without development signing',
    'CODE_SIGNING_ALLOWED=NO',
    'CODE_SIGNING_REQUIRED=NO',
    'CODE_SIGN_IDENTITY=""',
    'get-task-allow',
    'destination string upload',
    'manageAppVersionAndBuildNumber bool false',
    'appStoreReleaseCapable: true',
    'submittedForReview: false',
    'Remove temporary App Store Connect key'
)

foreach ($contract in $required) {
    if (-not $workflow.Contains($contract)) {
        throw "App Review workflow is missing required contract: $contract"
    }
}

$forbidden = @(
    'testFlightInternalTestingOnly bool true',
    'submitForReview',
    'appStoreVersionSubmissions',
    'betaAppReviewSubmissions',
    'phasedRelease',
    'automaticReleaseDate',
    'releaseToAllUsers'
)

foreach ($contract in $forbidden) {
    if ($workflow.Contains($contract)) {
        throw "App Review workflow contains forbidden submission or release contract: $contract"
    }
}

$archiveStart = $workflow.IndexOf('Archive public Release candidate without development signing')
$exportStart = $workflow.IndexOf('Export and verify public-capable IPA')
if ($archiveStart -lt 0 -or $exportStart -le $archiveStart) {
    throw 'The unsigned archive and signed export phases are not ordered correctly.'
}
$archiveBlock = $workflow.Substring($archiveStart, $exportStart - $archiveStart)
foreach ($forbiddenArchiveContract in @('-allowProvisioningUpdates', '-authenticationKeyPath', 'CODE_SIGN_STYLE=Automatic')) {
    if ($archiveBlock.Contains($forbiddenArchiveContract)) {
        throw "The archive phase must not request a disposable development certificate: $forbiddenArchiveContract"
    }
}

$exportBlock = $workflow.Substring($exportStart)
foreach ($signedExportContract in @('-allowProvisioningUpdates', '-authenticationKeyPath', 'signingStyle string automatic', 'embedded.mobileprovision')) {
    if (-not $exportBlock.Contains($signedExportContract)) {
        throw "The exported IPA must be cloud-signed and verified: $signedExportContract"
    }
}

if ([regex]::Matches($project, [regex]::Escape('MARKETING_VERSION = 1.0;')).Count -ne 2 -or
    [regex]::Matches($project, [regex]::Escape('CURRENT_PROJECT_VERSION = 1;')).Count -ne 2) {
    throw 'The Xcode project must expose exactly Tarot Deck 1.0 (1) in Debug and Release.'
}

Write-Host 'Validated manual App Review RC workflow for Tarot Deck 1.0 (1): exact US/GB/ES release gate, unsigned archive without disposable development certificates, cloud-signed public-capable export/upload, evidence manifest, and no build selection, review submission, agreement acceptance, territory mutation, or release action.'
