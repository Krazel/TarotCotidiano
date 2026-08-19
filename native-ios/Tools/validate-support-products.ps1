$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$manifestPath = Join-Path $repoRoot "store/tarot-subscriptions.v1.json"
$storePath = Join-Path $repoRoot "native-ios/TarotDeckApp/Internal/SupporterStore.swift"
$settingsPath = Join-Path $repoRoot "native-ios/TarotDeckApp/Screens/Settings/SettingsView.swift"
$workflowPath = Join-Path $repoRoot ".github/workflows/tarot-storekit-setup.yml"
$projectPath = Join-Path $repoRoot "native-ios/TarotDeck.xcodeproj/project.pbxproj"
$configurePath = Join-Path $repoRoot "native-ios/Tools/configure-support-products.rb"

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$store = Get-Content -Raw -LiteralPath $storePath
$settings = Get-Content -Raw -LiteralPath $settingsPath
$workflow = Get-Content -Raw -LiteralPath $workflowPath
$project = Get-Content -Raw -LiteralPath $projectPath
$configure = Get-Content -Raw -LiteralPath $configurePath

if ($manifest.schemaVersion -ne 1 -or $manifest.appAppleID -cne "6800144105" -or
    $manifest.bundleID -cne "com.krazel.tarotdeck") {
    throw "Subscription manifest identity is invalid."
}

$expectedIDs = @(
    "com.krazel.tarotdeck.support.monthly.099",
    "com.krazel.tarotdeck.support.monthly.299",
    "com.krazel.tarotdeck.support.monthly.499",
    "com.krazel.tarotdeck.support.monthly.999",
    "com.krazel.tarotdeck.support.monthly.1499",
    "com.krazel.tarotdeck.support.monthly.2999",
    "com.krazel.tarotdeck.support.monthly.50"
)
$manifestIDs = @($manifest.products | ForEach-Object { $_.productID })
if ($manifestIDs.Count -ne 7 -or @(Compare-Object $expectedIDs $manifestIDs).Count -ne 0 -or
    @($manifestIDs | Select-Object -Unique).Count -ne 7) {
    throw "Exactly seven canonical monthly product IDs are required."
}
foreach ($productID in $expectedIDs) {
    if ($store -cnotmatch [regex]::Escape('"' + $productID + '"')) {
        throw "SupporterStore is missing product ID $productID."
    }
}

if (@($manifest.territories) -join "," -cne "ALL_CURRENT_APP_STORE_TERRITORIES" -or
    $manifest.territoryCountAtConfiguration -ne 175 -or
    $manifest.availableInNewTerritories -ne $true) {
    throw "Subscriptions must be available in all 175 current App Store territories and future territories."
}

$expectedPrices = @('0.99', '2.99', '4.99', '9.99', '14.99', '29.99', '49.99')
$manifestPrices = @($manifest.products | ForEach-Object { ([decimal]$_.priceEUR).ToString('0.00', [Globalization.CultureInfo]::InvariantCulture) })
if (@(Compare-Object $expectedPrices $manifestPrices).Count -ne 0 -or
    @($manifestPrices).Count -ne 7) {
    throw "The seven approved base EUR prices are not exact."
}
if ($manifest.subscriptionGroup.referenceName -cne 'Tarot Deck Support' -or
    $manifest.subscriptionGroup.period -cne 'ONE_MONTH' -or
    $manifest.subscriptionGroup.groupLevel -ne 1 -or
    @($manifest.productLocalizations.PSObject.Properties.Name | Sort-Object) -join ',' -cne 'en-US,es-ES') {
    throw "Subscription group, monthly period, level, or EN/ES product localization is invalid."
}

if ($project -cnotmatch [regex]::Escape('SupporterStore.swift in Sources') -or
    ([regex]::Matches($project, 'SupporterStore\.swift in Sources')).Count -ne 2) {
    throw "SupporterStore.swift must appear exactly once as a build file and once in the Sources phase."
}

$masterHashes = @{
    'design/tarot-deck/settings-monthly-support-v2-spanish-a-ceremonial-obsidian.png' = '281251C279C6C4D7E0D0F10B88B433E8B7F5C26F41BCF8B1DD29DD0132CAD7C2'
    'design/tarot-deck/settings-monthly-support-v2-english-a-ceremonial-obsidian.png' = '25013A9049221F86F752E56E6047A9EEB5BF504C33F400D478606BCFCC574212'
    'design/tarot-deck/support-the-app-seven-levels-v1-spanish-a-ceremonial-obsidian.png' = 'BE58CB9C7E0BEEA0C87DA61205EAC7284A9E7CBCA86395EA1980010DC6FF29E6'
    'design/tarot-deck/support-the-app-seven-levels-v1-english-a-ceremonial-obsidian.png' = '67B486722A3398631CE7AAC079E5738EF77C5A512DA23DDF62A6A88C29DA3024'
}
foreach ($relativePath in $masterHashes.Keys) {
    $path = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing approved support master: $relativePath"
    }
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
    if ($actualHash -cne $masterHashes[$relativePath]) {
        throw "Approved support master hash mismatch: $relativePath"
    }
}
if ($manifest.benefits.coreAppRemainsFree -ne $true -or
    $manifest.benefits.allLevelsEquivalent -ne $true -or
    $manifest.benefits.supporterStatusInSettings -ne $true -or
    $manifest.benefits.adsRemoved -ne $false) {
    throw "Support benefits do not match the approved free-app contract."
}

$storeContracts = @(
    "import StoreKit",
    "Product.products",
    "Transaction.currentEntitlements",
    "Transaction.updates",
    "AppStore.sync()",
    "product.purchase()",
    "await transaction.finish()",
    "revocationDate == nil"
)
foreach ($contract in $storeContracts) {
    if ($store -cnotmatch [regex]::Escape($contract)) {
        throw "StoreKit verification contract is missing: $contract"
    }
}

$settingsContracts = @(
    "Support the App",
    "Every level offers the same supporter status.",
    "product.displayPrice",
    "per month",
    "auto-renewable subscription",
    "Restore Purchases",
    "Manage Subscription",
    "Privacy",
    "Terms",
    "The full app stays free"
)
foreach ($contract in $settingsContracts) {
    if ($settings -cnotmatch [regex]::Escape($contract)) {
        throw "Support UI disclosure is missing: $contract"
    }
}
if ($settings -match '(?i)donation|donate|premium|best value|free trial|remove ads') {
    throw "Support UI contains prohibited donation, pressure, or invented-benefit copy."
}
if ($settings -match '"\s*\$\s*\d|[€£]\s*\d|\d+[\.,]\d{2}\s*[€£$]') {
    throw "Runtime support UI must not hard-code a price or currency."
}

$workflowContracts = @(
    "workflow_dispatch:",
    "CREATE_TAROT_MONTHLY_SUPPORT_PRODUCTS",
    "environment: app-store-production",
    "permissions:",
    "contents: read",
    "persist-credentials: false",
    "APP_STORE_CONNECT_API_KEY_BASE64",
    "configure-support-products.rb"
)
foreach ($contract in $workflowContracts) {
    if ($workflow -cnotmatch [regex]::Escape($contract)) {
        throw "StoreKit workflow boundary is missing: $contract"
    }
}
if ($workflow -match '(?i)testflight|xcodebuild|upload-artifact|submit|appReviewSubmission') {
    throw "StoreKit setup workflow must not build, upload, submit, or trigger review."
}
if ($configure -match '(?m)^\s*startDate:' -or
    $configure -cnotmatch [regex]::Escape('ALL_CURRENT_APP_STORE_TERRITORIES') -or
    $configure -cnotmatch [regex]::Escape('available_in_new_territories') -or
    $configure -cnotmatch [regex]::Escape('limit[availableTerritories]=200') -or
    $configure -cnotmatch [regex]::Escape('Subscription states:')) {
    throw "Initial StoreKit prices must omit startDate and preserve worldwide current/future availability."
}

Write-Host "Validated seven equivalent monthly support products across all 175 current and future App Store territories, verified StoreKit entitlements, live prices, disclosures, restoration, and an explicit production-only setup workflow."
