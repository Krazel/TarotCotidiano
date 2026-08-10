param(
    [string]$NativeRoot = (Join-Path $PSScriptRoot ".."),
    [switch]$ReleaseGate
)

$ErrorActionPreference = "Stop"
$native = Resolve-Path -LiteralPath $NativeRoot
$projectFile = Join-Path $native.Path "TarotDeck.xcodeproj/project.pbxproj"
$appRoot = Join-Path $native.Path "TarotDeckApp"
$contentRoot = Join-Path $native.Path "Content"

$deck = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "tarot-deck.v1.json") | ConvertFrom-Json
$meanings = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Education/card-meanings.v1.json") | ConvertFrom-Json
$guide = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Education/beginner-guide.v1.json") | ConvertFrom-Json
$spanishCopy = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Localization/card-copy.es.v1.json") | ConvertFrom-Json
$spanishMeanings = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Localization/card-meanings.es.v1.json") | ConvertFrom-Json
$spanishGuide = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Localization/beginner-guide.es.v1.json") | ConvertFrom-Json

if ($deck.cards.Count -ne 78) { throw "Deck must contain 78 cards." }
if ($meanings.cards.Count -ne 78) { throw "Meanings must contain 78 cards." }
if ($guide.articles.Count -ne 6) { throw "Guide must contain 6 articles." }
if ($spanishCopy.language -cne "es" -or $spanishCopy.cards.Count -ne 78) {
    throw "Spanish card copy must contain exactly 78 records."
}
if ($spanishMeanings.language -cne "es" -or $spanishMeanings.cards.Count -ne 78) {
    throw "Spanish meanings must contain exactly 78 records."
}
if ($spanishGuide.language -cne "es" -or $spanishGuide.articles.Count -ne 6) {
    throw "Spanish guide must contain exactly 6 articles."
}

$missingArtworkDescriptions = @($meanings.cards | Where-Object {
    [string]::IsNullOrWhiteSpace([string]$_.artworkDescription)
})
if ($missingArtworkDescriptions.Count -gt 0) {
    throw "Artwork descriptions are missing for: $($missingArtworkDescriptions.cardID -join ', ')"
}

$deckIDs = @($deck.cards.id | Sort-Object)
$meaningIDs = @($meanings.cards.cardID | Sort-Object)
if (Compare-Object $deckIDs $meaningIDs) {
    throw "Deck and meaning identifiers differ."
}
$spanishCopyIDs = @($spanishCopy.cards.cardID | Sort-Object)
$spanishMeaningIDs = @($spanishMeanings.cards.cardID | Sort-Object)
if (@(Compare-Object $deckIDs $spanishCopyIDs).Count -gt 0 -or
    @(Compare-Object $deckIDs $spanishMeaningIDs).Count -gt 0) {
    throw "Spanish content identifiers differ from the canonical deck."
}

$project = Get-Content -Raw -LiteralPath $projectFile
$requiredSources = @(
    "TarotDeckInternalApp.swift",
    "TarotContent.swift",
    "TarotArtworkView.swift",
    "TarotDeckMainShell.swift",
    "ReadFlowModel.swift",
    "ReadViews.swift",
    "LearnViews.swift",
    "CardsViews.swift",
    "SettingsView.swift",
    "AppLocalization.swift",
    "CeremonialMotion.swift",
    "FavoriteCardsStore.swift"
)
$requiredResources = @(
    "tarot-deck.v1.json in Resources",
    "card-meanings.v1.json in Resources",
    "beginner-guide.v1.json in Resources",
    "Localizable.xcstrings in Resources",
    "card-copy.es.v1.json in Resources",
    "card-meanings.es.v1.json in Resources",
    "beginner-guide.es.v1.json in Resources"
)

foreach ($source in $requiredSources) {
    if ($project -notmatch [regex]::Escape("$source in Sources")) {
        throw "$source is missing from the app target Sources phase."
    }
}
foreach ($resource in $requiredResources) {
    if ($project -notmatch [regex]::Escape($resource)) {
        throw "$resource is missing from the app target Resources phase."
    }
}
if ($project -match [regex]::Escape("ProvisionalApprovedReadingHarness.swift in Sources")) {
    throw "The superseded provisional reading harness remains in the app target."
}
if ($project -notmatch '(?s)knownRegions\s*=\s*\([^\)]*\bes\s*,') {
    throw "The Xcode project does not declare Spanish as a known region."
}

$catalogPath = Join-Path $appRoot "Resources/Localizable.xcstrings"
$catalogRaw = Get-Content -Raw -LiteralPath $catalogPath
$catalog = $catalogRaw | ConvertFrom-Json
$catalogKeyMatches = [regex]::Matches(
    $catalogRaw,
    '(?m)^\s{4}"((?:[^"\\]|\\.)+)"\s*:\s*\{\s*"localizations"'
)
$duplicateCatalogKeys = @(
    $catalogKeyMatches |
        ForEach-Object { $_.Groups[1].Value } |
        Group-Object |
        Where-Object Count -gt 1
)
if ($duplicateCatalogKeys.Count -gt 0) {
    throw "The String Catalog contains duplicate keys: $($duplicateCatalogKeys.Name -join ', ')"
}
$catalogEntries = @($catalog.strings.PSObject.Properties)
if ($catalogEntries.Count -lt 100 -or
    @($catalogEntries | Where-Object { [string]::IsNullOrWhiteSpace([string]$_.Value.localizations.es.stringUnit.value) }).Count -gt 0) {
    throw "The String Catalog must contain complete Spanish values for the app UI contract."
}

$artworkIntegrationChecks = @(
    @{ Path = "Content/TarotContent.swift"; Snippet = "let artworkDescription: String" },
    @{ Path = "Components/TarotArtworkView.swift"; Snippet = "var artworkDescription: String?" },
    @{ Path = "Screens/Read/ReadViews.swift"; Snippet = "artworkDescription: meaning.artworkDescription" },
    @{ Path = "Screens/Cards/CardsViews.swift"; Snippet = "artworkDescription: meaning.artworkDescription" }
)
foreach ($check in $artworkIntegrationChecks) {
    $integrationSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot $check.Path)
    if ($integrationSource -cnotmatch [regex]::Escape($check.Snippet)) {
        throw "Artwork descriptions are not integrated in $($check.Path)."
    }
}

$contentSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Content/TarotContent.swift")
if ($contentSource -cnotmatch [regex]::Escape("AppLocalization.isSpanish(bundle: bundle)") -or
    $contentSource -cnotmatch [regex]::Escape("throw TarotContentLoadError.invalidLocalizedContent") -or
    ([regex]::Matches($contentSource, [regex]::Escape("return english"))).Count -ne 1) {
    throw "Spanish loading must be bundle-aware, atomic, and fail rather than mix languages."
}

$sourceText = Get-ChildItem -LiteralPath $appRoot -Recurse -File -Filter *.swift |
    Get-Content -Raw
$forbidden = @("StoreKit", "Zodiac", "Android")
foreach ($term in $forbidden) {
    if ($sourceText -match [regex]::Escape($term)) {
        throw "Out-of-scope app source term found: $term"
    }
}
if ($sourceText -match '\brwsTheMoon\b' -or $sourceText -match [regex]::Escape('rws-the-moon')) {
    throw "Obsolete duplicate The Moon runtime asset name remains in Swift source."
}
$obsoleteMoonImageSet = Join-Path $appRoot "Resources/Assets.xcassets/rws-the-moon.imageset"
if (Test-Path -LiteralPath $obsoleteMoonImageSet) {
    throw "Obsolete duplicate The Moon runtime image set is still bundled."
}

$evidence = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "CandidateRWS/local-evidence.v2.json") | ConvertFrom-Json
if ([int]$evidence.schemaVersion -ne 2) {
    throw "Artwork integration requires local-evidence.v2.json schema version 2."
}
$verifiedRecords = @($evidence.records | Where-Object {
    $_.sha1MatchesSource -and $_.byteSizeMatchesSource -and $_.dimensionMatchesSource
})
if ([int]$evidence.verifiedCardCount -ne $verifiedRecords.Count) {
    throw "Evidence verifiedCardCount does not match its verified records."
}
if (@($verifiedRecords.cardID | Group-Object | Where-Object Count -ne 1).Count -gt 0) {
    throw "Evidence contains duplicate verified card identifiers."
}
foreach ($record in $verifiedRecords) {
    $manifestCard = @($deck.cards | Where-Object id -CEQ $record.cardID)
    if ($manifestCard.Count -ne 1) {
        throw "Verified evidence does not map to one deck card: $($record.cardID)"
    }
    if ([string]$manifestCard[0].artworkAsset -cne [string]$record.artworkAsset) {
        throw "Artwork asset mismatch for verified candidate: $($record.cardID)"
    }
    $imageSet = Join-Path $appRoot "Resources/Assets.xcassets/$($record.artworkAsset).imageset"
    $candidateAsset = Join-Path $imageSet "candidate.jpg"
    $assetMetadata = Join-Path $imageSet "Contents.json"
    if (-not (Test-Path -LiteralPath $candidateAsset -PathType Leaf)) {
        throw "Verified candidate is not bundled: $($record.cardID)"
    }
    if (-not (Test-Path -LiteralPath $assetMetadata -PathType Leaf)) {
        throw "Asset metadata is missing: $($record.cardID)"
    }
    $assetSHA1 = (Get-FileHash -LiteralPath $candidateAsset -Algorithm SHA1).Hash.ToLowerInvariant()
    if ($assetSHA1 -cne ([string]$record.verifiedLocalSHA1).ToLowerInvariant()) {
        throw "Bundled candidate hash differs from verified evidence: $($record.cardID)"
    }
    $contents = Get-Content -Raw -LiteralPath $assetMetadata | ConvertFrom-Json
    if (@($contents.images | Where-Object filename -CEQ "candidate.jpg").Count -ne 1) {
        throw "Asset metadata does not reference candidate.jpg exactly once: $($record.cardID)"
    }
}

$readSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Screens/Read/ReadViews.swift")
$readModelSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Internal/ReadFlowModel.swift")
if ("$readSource`n$readModelSource" -match '\b(print|debugPrint|NSLog|Logger|os_log)\s*\(') {
    throw "Read implementation contains logging that could expose session state."
}
if ($readModelSource -match 'catch\s*\{\s*\}') {
    throw "Read implementation contains a silent empty catch block."
}
$requiredRecoveryContracts = @(
    "case restoring",
    "surface: Surface = .restoring",
    "static func ready",
    "record.phase == .readyToShuffle",
    "restored.drawnCards.isEmpty",
    "Set(candidate.shuffledCardIDs) == canonicalCardIDs",
    "knownCardIDs == canonicalCardIDs",
    "presentIssue",
    "retryIssue",
    "requestThreeCardReadingFromLearn"
    "case spreadChoice"
    "enum ThreeCardSpread"
    "case pastPresentFuture"
    "case situationChallengeAdvice"
    "case relationship"
    "case open"
)
foreach ($contract in $requiredRecoveryContracts) {
    if ($readModelSource -cnotmatch [regex]::Escape($contract)) {
        throw "Read recovery contract is missing: $contract"
    }
}
$readyWrite = $readModelSource.IndexOf("try self.continuityStore.save(.ready(layout, spread: self.spread))")
$sessionWrite = $readModelSource.IndexOf("self.coordinator.startSession()")
if ($readyWrite -lt 0 -or $sessionWrite -lt 0 -or $readyWrite -gt $sessionWrite) {
    throw "The ready continuity record must be persisted before startSession."
}
$shellSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "App/TarotDeckMainShell.swift")
$appSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "App/TarotDeckInternalApp.swift")
if ($shellSource -cnotmatch [regex]::Escape("startThreeCardReading()") -or
    $appSource -cnotmatch [regex]::Escape("readModel.requestThreeCardReadingFromLearn()")) {
    throw "The Learn three-card CTA is not connected to ReadFlowModel."
}
if ($readModelSource -match '\bUserDefaults\b' -or
    $readModelSource -cnotmatch [regex]::Escape("options: .atomic") -or
    $appSource -cnotmatch [regex]::Escape('active-session.v1.json') -or
    $appSource -cnotmatch [regex]::Escape('reading-continuity.v1.json')) {
    throw "Reading continuity must use a distinct atomic JSON sidecar next to the active session."
}
if ($readModelSource -cnotmatch [regex]::Escape("pendingReplacementLayout = .threeCards") -or
    $readModelSource -cnotmatch [regex]::Escape("layout == .threeCards")) {
    throw "The Learn CTA does not distinguish resumable Three Cards from confirmed replacement."
}
if ($readSource -cnotmatch [regex]::Escape("ThreeCardSpreadChoiceView") -or
    $readSource -cnotmatch [regex]::Escape("let railWidth = min(max(size.width * 0.21, 148), 190)") -or
    $readSource -cnotmatch [regex]::Escape("positions(showLabels: model.layout == .threeCards)")) {
    throw "Named spread selection or the approved large landscape table is missing."
}

$motionSourcePath = Join-Path $appRoot "Design/CeremonialMotion.swift"
$motionSpecPath = Join-Path $native.Path "../design/tarot-deck/MOTION_SPEC.md"
$motionStoryboardPath = Join-Path $native.Path "../design/tarot-deck/reading-table-motion-storyboard-a-ceremonial-obsidian.png"
if (-not (Test-Path -LiteralPath $motionSourcePath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $motionSpecPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $motionStoryboardPath -PathType Leaf)) {
    throw "The approved motion source, specification, and storyboard must all be present."
}
$motionSource = Get-Content -Raw -LiteralPath $motionSourcePath
$motionContracts = @(
    "CeremonialShufflingDeck",
    "UIImpactFeedbackGenerator",
    "ceremonialCardReveal",
    "CeremonialMotion.reduced"
)
foreach ($contract in $motionContracts) {
    if ($motionSource -cnotmatch [regex]::Escape($contract)) {
        throw "Professional motion contract is missing: $contract"
    }
}
if ($readSource -cnotmatch [regex]::Escape("accessibilityReduceMotion") -or
    $readSource -cnotmatch [regex]::Escape("accessibilityVoiceOverEnabled") -or
    $readSource -cnotmatch [regex]::Escape("AccessibilityFocusState") -or
    $readSource -cnotmatch [regex]::Escape("respondToDurableStateChange") -or
    $readSource -cnotmatch [regex]::Escape("guard scenePhase == .active else { return }") -or
    $readSource -cnotmatch [regex]::Escape("cancelTransientMotion")) {
    throw "Read motion must respect accessibility and react only to published durable state."
}
if ($motionSource -match '\brepeatForever\b|\bPhaseAnimator\b|\bKeyframeAnimator\b|\bsensoryFeedback\b') {
    throw "Motion source contains looping or iOS 17-only animation APIs."
}
$expectedMotionStoryboardSHA256 = "30D49233D041893FAC2783D72F90A9C737BA49F74A25EE547EC022D31CBC3E64"
$actualMotionStoryboardSHA256 = (Get-FileHash -LiteralPath $motionStoryboardPath -Algorithm SHA256).Hash
if ($actualMotionStoryboardSHA256 -cne $expectedMotionStoryboardSHA256) {
    throw "The approved motion storyboard hash changed."
}

$favoritesSourcePath = Join-Path $appRoot "Internal/FavoriteCardsStore.swift"
$cardsSourcePath = Join-Path $appRoot "Screens/Cards/CardsViews.swift"
$favoriteDetailReference = Join-Path $native.Path "../design/tarot-deck/card-detail-library-favorite-saved-a-ceremonial-obsidian.png"
$favoritesEmptyReference = Join-Path $native.Path "../design/tarot-deck/cards-library-favorites-empty-a-ceremonial-obsidian.png"
if (-not (Test-Path -LiteralPath $favoritesSourcePath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $favoriteDetailReference -PathType Leaf) -or
    -not (Test-Path -LiteralPath $favoritesEmptyReference -PathType Leaf)) {
    throw "Favorites source and both approved visual references must be present."
}
$favoritesSource = Get-Content -Raw -LiteralPath $favoritesSourcePath
$cardsSource = Get-Content -Raw -LiteralPath $cardsSourcePath
$favoriteContracts = @(
    "FavoriteCardsStore: ObservableObject",
    "schemaVersion: 1",
    "decodedIDs.isSubset(of: knownCardIDs)",
    "options: .atomic",
    "isExcludedFromBackup = true",
    'appendingPathComponent("favorites.v1.json"',
    'case favorites = "Favorites"',
    "No favorites yet",
    "favoriteStore.toggle(card.id)",
    "dismissWhenRemovedFromFavorites",
    "onChange(of: favoriteStore.cardIDs)"
)
$favoriteContractSource = "$favoritesSource`n$cardsSource`n$appSource"
foreach ($contract in $favoriteContracts) {
    if ($favoriteContractSource -cnotmatch [regex]::Escape($contract)) {
        throw "Favorites contract is missing: $contract"
    }
}
$favoriteWrite = $favoritesSource.IndexOf("try save(candidate)")
$favoritePublish = $favoritesSource.IndexOf("cardIDs = candidate")
if ($favoriteWrite -lt 0 -or $favoritePublish -lt 0 -or $favoriteWrite -gt $favoritePublish -or
    $favoritesSource -cnotmatch [regex]::Escape("write(to: fileURL, options: .atomic)")) {
    throw "Favorites must persist atomically before publishing the changed set."
}
if (([regex]::Matches($shellSource, "favoriteStore: favoriteStore")).Count -lt 2) {
    throw "Read and Cards must share the single app-owned FavoriteCardsStore."
}
if ("$favoritesSource`n$cardsSource" -match '\bContentUnavailableView\b|@Observable\b|\.symbolEffect\b') {
    throw "Favorites contains an API unavailable on iOS 16."
}
$favoriteVisualHashes = @{
    $favoriteDetailReference = "5794D4C345BAF1BB52F783DE9C3D49D7D64DAA31BDA4083770AF3E2B8A957389"
    $favoritesEmptyReference = "62AED89CC28393E7FD2BC9B06F99240D576EA61FC90F39C8511DBDBA11FFCA87"
}
foreach ($entry in $favoriteVisualHashes.GetEnumerator()) {
    if ((Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "An approved Favorites visual reference hash changed: $($entry.Key)"
    }
}
$requiredFavoriteCatalogKeys = @(
    "Favorites",
    "No favorites yet",
    "Open a card and tap the heart to save it here.",
    "Add %@ to Favorites",
    "Remove %@ from Favorites",
    "Favorite",
    "Not favorite",
    "Favorites Unavailable",
    "Favorites couldn't be updated. Nothing was changed.",
    "Selected filter",
    "Your cards are still available. Add a favorite to start a new list."
)
foreach ($key in $requiredFavoriteCatalogKeys) {
    if ($null -eq $catalog.strings.PSObject.Properties[$key] -or
        [string]::IsNullOrWhiteSpace([string]$catalog.strings.$key.localizations.es.stringUnit.value)) {
        throw "Favorites catalog key or Spanish translation is missing: $key"
    }
}
$settingsSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Screens/Settings/SettingsView.swift")
$requiredSettingsCopy = @(
    "Support the App",
    "Restore Purchases",
    "Rate the App",
    "Privacy",
    "Terms",
    "Support isn't available right now. You can keep using the full app.",
    "Restore Unavailable",
    "Restore Purchases isn't available in this internal build. You can keep using the full app.",
    'fallbackVersion = "0.0.1"'
)
foreach ($copy in $requiredSettingsCopy) {
    if ($settingsSource -cnotmatch [regex]::Escape($copy)) {
        throw "Required Settings contract is missing: $copy"
    }
}
if ($settingsSource -match '\b(StoreKit|Product\.products|purchase\s*\(|Transaction\.|AppStore\.)\b' -or
    $settingsSource -match 'https?://' -or
    $settingsSource -match '\bURL\s*\(') {
    throw "Settings contains unauthorized commerce or external destination integration."
}
if ($settingsSource -match '(?s)Button[^\{]*\{\s*\}' -or
    $settingsSource -match '(?s)Button\([^\)]*\)\s*\{\s*\}') {
    throw "Settings contains an active button with an empty callback."
}
if ($readSource -cnotmatch [regex]::Escape('openSettings: { showsSettings = true }') -or
    $readSource -cnotmatch [regex]::Escape('.sheet(isPresented: $showsSettings)') -or
    $readSource -cnotmatch [regex]::Escape('accessibilityLabel("Settings")')) {
    throw "Settings is not reachable from every Read Home state."
}
if ($settingsSource -match '\bReadFlowModel\b') {
    throw "Settings must not own or mutate the active reading model."
}
$learnSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Screens/Learn/LearnViews.swift")
if ($learnSource -match '\.font\(\.system\(size:\s*52\b' -or
    $learnSource -cnotmatch [regex]::Escape("lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)")) {
    throw "Learn Dynamic Type adaptations are missing."
}
$artworkSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Components/TarotArtworkView.swift")
if ($readSource -match '\.font\(\.system\(size:\s*50\b' -or
    $artworkSource -cnotmatch [regex]::Escape("lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)")) {
    throw "Read or artwork Dynamic Type adaptations are missing."
}
$requiredReadCopy = @(
    "Start a new reading?",
    "Your current reading will be cleared.",
    "Start New Reading",
    "Keep Current Reading",
    "End this reading?",
    "The cards will return to the deck. This reading won't be saved.",
    "End Reading",
    "Keep Reading"
)
foreach ($copy in $requiredReadCopy) {
    if ($readSource -cnotmatch [regex]::Escape($copy)) {
        throw "Required approved Read copy is missing: $copy"
    }
}

if ($ReleaseGate) {
    if ($verifiedRecords.Count -ne 78 -or [int]$evidence.failureCount -ne 0) {
        throw "Release artwork gate blocked: requires 78/78 verified records and zero failures; found $($verifiedRecords.Count)/78 with $($evidence.failureCount) failures."
    }
    $expectedRuntimeImageSets = @(
        "ceremonial-card-back"
        $deck.cards | ForEach-Object { [string]$_.artworkAsset }
    ) | Sort-Object -Unique
    $actualRuntimeImageSets = @(
        Get-ChildItem -LiteralPath (Join-Path $appRoot "Resources/Assets.xcassets") -Directory -Filter "*.imageset" |
            ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_.Name) }
    ) | Sort-Object -Unique
    $runtimeAssetDifference = @(Compare-Object $expectedRuntimeImageSets $actualRuntimeImageSets)
    if ($expectedRuntimeImageSets.Count -ne 79 -or $runtimeAssetDifference.Count -gt 0) {
        $details = $runtimeAssetDifference | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" }
        throw "Release artwork gate blocked: runtime image-set allowlist differs from 78 canonical faces plus ceremonial-card-back. $($details -join '; ')"
    }
    if ($evidence.candidateOnly -ne $false -or
        $evidence.finalAsset -ne $true -or
        $evidence.distributionApproved -ne $true -or
        [string]$evidence.territorialRightsReviewStatus -cne "approved" -or
        @($verifiedRecords | Where-Object {
            $_.finalAsset -ne $true -or
            $_.distributionApproved -ne $true -or
            [string]$_.territorialRightsReviewStatus -cne "approved"
        }).Count -gt 0) {
        throw "Release artwork gate blocked: candidateOnly, finalAsset, distributionApproved, or territorial rights review is still pending."
    }

    Write-Host "Validated release artwork gate: 78/78 final assets are verified, bundled, and distribution-approved."
    exit 0
}

$placeholderCount = 78 - $verifiedRecords.Count
Write-Host "Validated internal app snapshot: 78 English and 78 Spanish card records, 6 guide articles per language, Read/Learn/Cards/Settings target membership, local atomic favorites with approved detail/empty states, named three-card spreads, large landscape table, approved Read alert copy, safe internal Settings feedback, scope boundaries, $($verifiedRecords.Count)/78 bundled hash-verified provisional artwork candidates, and $placeholderCount explicit placeholders. This snapshot is not release-ready."
