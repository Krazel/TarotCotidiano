$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$recordPath = Join-Path $repoRoot 'docs\technical\APP_STORE_RECORD.md'
$preflightPath = Join-Path $repoRoot 'docs\technical\APP_REVIEW_PREFLIGHT.md'
$screenshotsPath = Join-Path $repoRoot 'docs\technical\APP_STORE_SCREENSHOTS.md'
$privacyPath = Join-Path $repoRoot 'docs\technical\PRIVACY_DATA_INVENTORY.md'
$rightsPath = Join-Path $repoRoot 'docs\technical\CONTENT_RIGHTS_AUDIT.md'
$frameToolPath = Join-Path $repoRoot 'native-ios\Tools\extract-app-store-video-frame.ps1'

foreach ($path in @($recordPath, $preflightPath, $screenshotsPath, $privacyPath, $rightsPath, $frameToolPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing App Review evidence document: $path"
    }
}

$record = Get-Content -LiteralPath $recordPath -Raw
$preflight = Get-Content -LiteralPath $preflightPath -Raw
$screenshots = Get-Content -LiteralPath $screenshotsPath -Raw
$privacy = Get-Content -LiteralPath $privacyPath -Raw
$rights = Get-Content -LiteralPath $rightsPath -Raw
$frameTool = Get-Content -LiteralPath $frameToolPath -Raw

$metadata = @(
    @{ Label = 'EN name'; Value = 'Tarot Deck: Read & Learn'; Limit = 30 },
    @{ Label = 'EN subtitle'; Value = 'Your deck, always with you'; Limit = 30 },
    @{ Label = 'ES name'; Value = 'Tarot Deck: Lee y aprende'; Limit = 30 },
    @{ Label = 'ES subtitle'; Value = 'Tu mazo, siempre contigo'; Limit = 30 },
    @{ Label = 'EN keywords'; Value = 'tarot,cards,spreads,meanings,learn,arcana,reading,favorites,offline,custom'; Limit = 100 },
    @{ Label = 'ES keywords'; Value = 'tarot,cartas,tiradas,significados,aprender,arcanos,lectura,favoritas,sin conexión'; Limit = 100 }
)

foreach ($item in $metadata) {
    if (-not $record.Contains($item.Value)) {
        throw "App Store record is missing $($item.Label): $($item.Value)"
    }
    if ($item.Value.Length -gt $item.Limit) {
        throw "$($item.Label) exceeds its App Store limit: $($item.Value.Length)/$($item.Limit)"
    }
}

$requiredRecord = @(
    '`1.0 (1)`',
    '`com.krazel.tarotdeck`',
    '`tarot-deck-ios`',
    '`6800144105`',
    'English (U.S.)',
    'Spanish (Spain)',
    'https://krazel.github.io/tarot-deck/privacy/',
    'https://krazel.github.io/tarot-deck/support/',
    'Data Not Collected / No se recopilan datos',
    'Seven equivalent monthly supporter subscriptions',
    'Optional monthly support is processed by Apple through StoreKit',
    'solo `US`, `GB` y `ES`',
    'Marketing URL | Vacío',
    'Promotional Text and Marketing URL remain empty'
)

foreach ($contract in $requiredRecord) {
    if (-not $record.Contains($contract)) {
        throw "App Store record is missing required metadata/compliance contract: $contract"
    }
}

foreach ($contract in @('1.0 (1)', 'UPLOAD_APP_REVIEW_RC_1_0_1', 'DSA gate for Spain', 'App Review notes')) {
    if (-not $preflight.Contains($contract)) {
        throw "App Review preflight is missing: $contract"
    }
}

foreach ($contract in @('1320 × 2868', 'English (U.S.)', 'Spanish (Spain)', 'source build `1.0 (1)`', 'source filename and SHA-256', 'video timestamp')) {
    if (-not $screenshots.Contains($contract)) {
        throw "Screenshot plan is missing: $contract"
    }
}

foreach ($contract in @('buildVersion = ''1.0''', 'buildNumber = ''1''', 'sourceSHA256', 'frameSHA256', 'finalAppStoreExport = $false', 'Refusing to overwrite')) {
    if (-not $frameTool.Contains($contract)) {
        throw "Video-frame evidence tool is missing: $contract"
    }
}

foreach ($contract in @('Data Not Collected / No se recopilan datos', 'Saved custom spreads', 'Custom-spread recovery draft', 'No third-party framework', 'Apple StoreKit 2 is used only for voluntary monthly support')) {
    if (-not $privacy.Contains($contract)) {
        throw "Privacy inventory is missing: $contract"
    }
}

foreach ($contract in @('approvedTerritories=[US, GB, ES]', 'worldwideDistributionApproved=false')) {
    if (-not $rights.Contains($contract)) {
        throw "Content rights audit is missing: $contract"
    }
}

$forbidden = @(
    'No active support was found',
    'worldwideDistributionApproved=true',
    'Submitted for Review',
    'Automatically release'
)

foreach ($contract in $forbidden) {
    if ($record.Contains($contract)) {
        throw "Public 1.0 App Store record contains forbidden or inapplicable copy: $contract"
    }
}

Write-Host 'Validated App Review metadata package: 1.0 (1), EN-US/ES-ES limits, seven equivalent StoreKit support levels, Data Not Collected, US/GB/ES rights boundary, review notes, screenshot evidence plan, and no automatic release.'
