param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "../..")
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$path = Join-Path $root ".github/workflows/tarot-testflight-status.yml"
$workflow = Get-Content -Raw -LiteralPath $path

$required = @(
    "workflow_dispatch:",
    "permissions:`n  contents: read",
    "github.ref == 'refs/heads/main'",
    "TESTFLIGHT_INTERNAL_ONLY_1_0_BUILD_2",
    "environment: app-store-production",
    "APP_STORE_CONNECT_API_KEY_ID",
    "APP_STORE_CONNECT_ISSUER_ID",
    "APP_STORE_CONNECT_API_KEY_BASE64",
    'MARKETING_VERSION="1.0"',
    'BUILD_NUMBER="2"',
    'APP_ID="6800144105"',
    'apps/$APP_ID/buildUploads',
    'filter[cfBundleShortVersionString]',
    'filter[cfBundleVersion]',
    'uploadState',
    'buildAudienceType',
    'INTERNAL_ONLY',
    'processingState',
    'VALID',
    '.attributes.name == "Testers"',
    '.attributes.isInternalGroup == true',
    'relationships/builds',
    'externalTestingEnabled: false',
    'appStoreSubmitted: false',
    'uses: actions/upload-artifact@v4'
)
$normalized = $workflow -replace "`r`n", "`n"
foreach ($contract in $required) {
    if (-not $normalized.Contains($contract)) {
        throw "TestFlight status workflow contract is missing: $contract"
    }
}

$forbidden = @(
    '(?m)^\s{2}(push|pull_request|schedule|repository_dispatch):',
    '(?i)externalTestingCapable:\s*true|externalTestingEnabled:\s*true',
    '(?i)appStoreSubmitted:\s*true',
    '(?i)betaAppReview|appStoreVersionSubmissions|reviewSubmissions',
    '(?i)publicLinkEnabled|publicLinkId',
    '(?i)git\s+push|gh\s+(release|workflow\s+run)'
)
foreach ($pattern in $forbidden) {
    if ($workflow -match $pattern) {
        throw "TestFlight status workflow crosses a forbidden boundary: $pattern"
    }
}

Write-Host "Validated protected processing check for optional Tarot Deck 1.0 (2): Internal Only, existing Testers group only, no external testing, review, or App Store submission."
