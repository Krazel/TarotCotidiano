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

if ($deck.cards.Count -ne 78) { throw "Deck must contain 78 cards." }
if ($meanings.cards.Count -ne 78) { throw "Meanings must contain 78 cards." }
if ($guide.articles.Count -ne 6) { throw "Guide must contain 6 articles." }

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
    "SettingsView.swift"
)
$requiredResources = @(
    "tarot-deck.v1.json in Resources",
    "card-meanings.v1.json in Resources",
    "beginner-guide.v1.json in Resources"
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
)
foreach ($contract in $requiredRecoveryContracts) {
    if ($readModelSource -cnotmatch [regex]::Escape($contract)) {
        throw "Read recovery contract is missing: $contract"
    }
}
$readyWrite = $readModelSource.IndexOf("try self.continuityStore.save(.ready(layout))")
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
Write-Host "Validated internal app snapshot: 78 cards, 78 meanings with artwork descriptions, 6 articles, Read/Learn/Cards/Settings target membership, approved Read alert copy, safe internal Settings feedback, scope boundaries, $($verifiedRecords.Count)/78 bundled hash-verified provisional artwork candidates, and $placeholderCount explicit placeholders. This snapshot is not release-ready."
