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
    "required-interface-keys.v1.json in Resources"
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
foreach ($entry in $catalogEntries) {
    $sourceFormatTypes = @(
        [regex]::Matches([string]$entry.Name, '%(?:\d+\$)?[@d]') |
            ForEach-Object { $_.Value.Substring($_.Value.Length - 1) } |
            Sort-Object
    )
    $spanishValue = [string]$entry.Value.localizations.es.stringUnit.value
    $spanishFormatTypes = @(
        [regex]::Matches($spanishValue, '%(?:\d+\$)?[@d]') |
            ForEach-Object { $_.Value.Substring($_.Value.Length - 1) } |
            Sort-Object
    )
    if (@(Compare-Object $sourceFormatTypes $spanishFormatTypes).Count -gt 0) {
        throw "String Catalog printf placeholders differ for: $($entry.Name)"
    }
}
$interfaceManifestPath = Join-Path $appRoot "Resources/required-interface-keys.v1.json"
$interfaceManifest = Get-Content -Raw -LiteralPath $interfaceManifestPath | ConvertFrom-Json
$manifestKeys = @($interfaceManifest.keys | Sort-Object)
$catalogKeys = @($catalogEntries.Name | Sort-Object)
if ([int]$interfaceManifest.schemaVersion -ne 1 -or
    @($interfaceManifest.keys | Group-Object | Where-Object Count -ne 1).Count -gt 0 -or
    @(Compare-Object $catalogKeys $manifestKeys).Count -gt 0) {
    throw "The runtime interface-key manifest must exactly match every String Catalog key."
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
if ($contentSource -cnotmatch [regex]::Escape("static func load(language: AppLanguage, bundle: Bundle = .main)") -or
    $contentSource -cnotmatch [regex]::Escape("guard language == .spanish else { return english }") -or
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
    $readSource -cnotmatch [regex]::Escape("let railWidth = min(max(size.width * 0.22, 154), 200)") -or
    $readSource -cnotmatch [regex]::Escape("let groupWidth = cardWidth * count + gap * max(count - 1, 0)")) {
    throw "Named spread selection or the approved large landscape table is missing."
}

$motionSourcePath = Join-Path $appRoot "Design/CeremonialMotion.swift"
$motionSpecPath = Join-Path $native.Path "../design/tarot-deck/MOTION_SPEC.md"
$motionStoryboardPath = Join-Path $native.Path "../design/tarot-deck/reading-table-professional-motion-storyboard-v2-a-ceremonial-obsidian.png"
if (-not (Test-Path -LiteralPath $motionSourcePath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $motionSpecPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $motionStoryboardPath -PathType Leaf)) {
    throw "The approved motion source, specification, and storyboard must all be present."
}
$motionSource = Get-Content -Raw -LiteralPath $motionSourcePath
$motionContracts = @(
    "CeremonialShufflingDeck",
    "CeremonialDeckButtonStyle",
    "CeremonialDealGeometryEffect: GeometryEffect",
    "CeremonialFlipFaceModifier: AnimatableModifier",
    "var animatableData: CGFloat",
    "shuffleSettleDuration: TimeInterval = 0.20",
    "UIImpactFeedbackGenerator",
    "Animation.timingCurve(0.20, 0.72, 0.18, 1.00, duration: 0.38)",
    "static let reduced"
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
    $readSource -cnotmatch [regex]::Escape("presentationIsCurrent") -or
    $readSource -cnotmatch [regex]::Escape("cancelTransientMotion")) {
    throw "Read motion must respect accessibility and react only to published durable state."
}
if ($motionSource -match '\brepeatForever\b|\bPhaseAnimator\b|\bKeyframeAnimator\b|\bsensoryFeedback\b|shuffleSettle\s*=\s*Animation\.spring') {
    throw "Motion source contains looping or iOS 17-only animation APIs."
}
$expectedMotionStoryboardSHA256 = "937F89E3DF7D2161E6AD2C835A4201135161E6ADED083A4BE52B8773A58190F0"
$actualMotionStoryboardSHA256 = (Get-FileHash -LiteralPath $motionStoryboardPath -Algorithm SHA256).Hash
if ($actualMotionStoryboardSHA256 -cne $expectedMotionStoryboardSHA256) {
    throw "The approved motion storyboard hash changed."
}
$a031VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/read-home-compact-deck-cta-spanish-a-ceremonial-obsidian.png") = "392546D9B7B676E8348B42000206070ACDA5753867AED635DBC8C60C80619E5E"
    (Join-Path $native.Path "../design/tarot-deck/settings-language-spanish-a-ceremonial-obsidian.png") = "559D2E73882A723A24C55EBFF038CEEA9452B1CB62BD4A1C9E4ABF8E20518615"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-deck-tap-ready-spanish-a-ceremonial-obsidian.png") = "C05A106C77884EEA07C28B5E2BA677875F678E4FAD5F97AAAAF553D636082BBD"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-face-down-centered-spanish-a-ceremonial-obsidian.png") = "E2218EC5FFB80986B6A72D72DD0E710F8DFBCEB8D39060637F0A49CA0C26F77E"
    $motionStoryboardPath = $expectedMotionStoryboardSHA256
}
foreach ($entry in $a031VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "An approved A-031 visual reference is absent or changed: $($entry.Key)"
    }
}

$localizationSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Content/AppLocalization.swift")
$languageContracts = @(
    "final class AppLanguageStore: ObservableObject",
    'static let preferenceKey = "tarot.appLanguage.v1"',
    "AppLanguage.resolved(from: preferredLanguages)",
    "AppLocalization.validateInterfaceResources(for: candidate, in: bundle)",
    'forResource: "required-interface-keys.v1"',
    "for key in document.keys",
    'localized.localizedString(forKey: key, value: "", table: nil)',
    "document.keys.allSatisfy",
    "guard activeLanguage == .spanish else { return key }",
    "if language == .english { return }",
    "return spanishBundle(in: bundle)",
    'bundle.path(forResource: AppLanguage.spanish.rawValue, ofType: "lproj")',
    "TarotContentLoader.load(language: candidate, bundle: bundle)",
    "defaults.set(candidate.rawValue, forKey: Self.preferenceKey)",
    "AppLocalization.configure(language: candidate, bundle: bundle)",
    "UIAccessibility.post(notification: .announcement",
    ".environment(\.locale, languageStore.language.locale)",
    ".accessibilityLanguage(languageStore.language.accessibilityCode)"
)
$languageContractSource = "$localizationSource`n$shellSource`n$appSource"
foreach ($contract in $languageContracts) {
    if ($languageContractSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-031 language contract is missing: $contract"
    }
}
if ($localizationSource -match 'bundle\.path\(forResource:\s*(?:language\.rawValue|AppLanguage\.english\.rawValue|"en"),\s*ofType:\s*"lproj"\)') {
    throw "English source localization must validate from the main bundle without requiring en.lproj."
}
$interfaceValidationStart = $localizationSource.IndexOf("static func validateInterfaceResources")
$interfaceValidationEnd = $localizationSource.IndexOf("private static func localizedBundle", $interfaceValidationStart)
if ($interfaceValidationStart -lt 0 -or $interfaceValidationEnd -le $interfaceValidationStart) {
    throw "Interface-language validation source boundaries could not be validated."
}
$interfaceValidationSource = $localizationSource.Substring(
    $interfaceValidationStart,
    $interfaceValidationEnd - $interfaceValidationStart
)
$englishSourceReturn = $interfaceValidationSource.IndexOf("if language == .english { return }")
$spanishBundleLookup = $interfaceValidationSource.IndexOf("guard let localized = spanishBundle(in: bundle)")
$spanishLocalizedLookup = $interfaceValidationSource.IndexOf('localized.localizedString(forKey: key, value: "", table: nil)')
if ($englishSourceReturn -lt 0 -or $spanishBundleLookup -le $englishSourceReturn -or
    $spanishLocalizedLookup -le $spanishBundleLookup -or
    $interfaceValidationSource.Substring(0, $englishSourceReturn) -match '\.localizedString\(') {
    throw "English must validate source keys from the main manifest and return before Spanish localized lookup."
}
$candidateLoad = $localizationSource.IndexOf("let candidateContent = try TarotContentLoader.load")
$preferenceCommit = $localizationSource.IndexOf("defaults.set(candidate.rawValue")
$statePublish = $localizationSource.IndexOf("state = State(language: candidate")
if ($candidateLoad -lt 0 -or $preferenceCommit -lt 0 -or $statePublish -lt 0 -or
    $candidateLoad -gt $preferenceCommit -or $preferenceCommit -gt $statePublish) {
    throw "Language selection must validate content before persisting and publishing one snapshot."
}
if ($languageContractSource -match '\bAppleLanguages\b|method_exchangeImplementations|swizzle') {
    throw "Language selection must not mutate AppleLanguages or swizzle localization behavior."
}
if (([regex]::Matches($appSource, 'AppLanguageStore\(\)')).Count -ne 1 -or
    $localizationSource -match '\b(ReadFlowModel|FavoriteCardsStore)\b') {
    throw "Language selection must use one app-owned store and remain independent of readings and favorites."
}

$settingsSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Screens/Settings/SettingsView.swift")
$settingsLanguageContracts = @(
    "@ObservedObject var languageStore: AppLanguageStore",
    'settingsSection(title: "Language")',
    "ForEach(AppLanguage.allCases)",
    ".pickerStyle(.segmented)",
    "languageStore.select",
    "Language Couldn't Be Changed"
)
foreach ($contract in $settingsLanguageContracts) {
    if ($settingsSource -cnotmatch [regex]::Escape($contract)) {
        throw "Settings language selector contract is missing: $contract"
    }
}

$homeStart = $readSource.IndexOf("private struct ReadHomeView")
$homeEnd = $readSource.IndexOf("private struct LayoutChoiceView")
if ($homeStart -lt 0 -or $homeEnd -le $homeStart) {
    throw "Read Home source boundaries could not be validated."
}
$homeSource = $readSource.Substring($homeStart, $homeEnd - $homeStart)
$emptyStart = $homeSource.IndexOf("private var emptyHome")
$activeStart = $homeSource.IndexOf("private func activeHome")
if ($emptyStart -lt 0 -or $activeStart -le $emptyStart -or
    $homeSource -cnotmatch [regex]::Escape('Button(action: openSettings)') -or
    $homeSource -cnotmatch [regex]::Escape('homeControlClearance: CGFloat = 64') -or
    $homeSource -cnotmatch [regex]::Escape('width: homeControlClearance') -or
    $homeSource -cnotmatch [regex]::Escape('height: homeControlClearance') -or
    $homeSource -cnotmatch [regex]::Escape('if dynamicTypeSize.isAccessibilitySize') -or
    $homeSource -cnotmatch [regex]::Escape('ViewThatFits(in: .vertical)') -or
    $homeSource -cnotmatch [regex]::Escape('emptyHomeComposition(deckWidth:') -or
    $homeSource -cnotmatch [regex]::Escape('Text("Tap the deck to begin")') -or
    $homeSource -cnotmatch [regex]::Escape('.accessibilityLabel("Start a Reading")') -or
    $homeSource -match [regex]::Escape('.accessibilityLabel("Complete 78-card tarot deck")')) {
    throw "V-044 Home must keep a fitted non-scrolling normal state, an accessibility-safe fallback, an overlaid gear, and one deck CTA."
}
$homeClearanceBand = $homeSource.IndexOf("width: homeControlClearance")
$homeAccessibilityScroll = $homeSource.IndexOf("ScrollView", $homeSource.IndexOf("if dynamicTypeSize.isAccessibilitySize"))
if ($homeClearanceBand -lt 0 -or $homeAccessibilityScroll -le $homeClearanceBand) {
    throw "V-044 must reserve its 64-point top-trailing control band before scrollable content."
}

$readingTableStart = $readSource.IndexOf("private struct ReadingTableView")
$readingTableEnd = $readSource.IndexOf("private enum ReadingMotionAnchor")
$readingTableSource = $readSource.Substring($readingTableStart, $readingTableEnd - $readingTableStart)
$readingContracts = @(
    "ReadingMotionAnchorPreferenceKey",
    "anchorPreference",
    "runShuffleChoreography",
    "runDeal(to:",
    "runFlip(at:",
    "dealOverlay(anchors:",
    "CeremonialDealGeometryEffect(",
    "CeremonialFlipFaceModifier(",
    "presentationLocked",
    "scenePhase == .active",
    "CeremonialHaptics.drawn()",
    "visualBaseline = target",
    "if dealingPosition != nil { return true }",
    "visualBaseline?.drawnCardIDs.count",
    ".disabled(interactionLocked || !canUseDeck)",
    "proxy.size.height * 0.34",
    "Tap the deck to shuffle.",
    "Tap the deck to draw."
)
foreach ($contract in $readingContracts) {
    if ($readingTableSource -cnotmatch [regex]::Escape($contract)) {
        throw "V-048 reading-table contract is missing: $contract"
    }
}
if ($readingTableSource -match '\bprimaryTitle\b|Button\("Shuffle Deck"|Button\("Draw Card"') {
    throw "The reading table still contains a duplicate primary shuffle/draw CTA."
}
if ($readingTableSource -match 'sin\(\.pi \* dealProgress\)|let firstHalf = min\(progress \* 2') {
    throw "Deal and two-sided flip progress must interpolate inside animatable effects."
}
$normalShuffleStart = $readingTableSource.IndexOf("withAnimation(CeremonialMotion.cut)")
$shuffleSettle = $readingTableSource.IndexOf("withAnimation(CeremonialMotion.shuffleSettle)", $normalShuffleStart)
$shuffleSettleWait = $readingTableSource.IndexOf("Task.sleep(nanoseconds: 200_000_000)", $shuffleSettle)
$shuffleFinish = $readingTableSource.IndexOf("finishPresentation(token)", $shuffleSettleWait)
$shuffleHaptic = $readingTableSource.IndexOf("CeremonialHaptics.shuffled()", $shuffleFinish)
if ($normalShuffleStart -lt 0 -or $shuffleSettle -lt 0 -or $shuffleSettleWait -lt 0 -or
    $shuffleFinish -lt 0 -or $shuffleHaptic -lt 0) {
    throw "Shuffle haptics must follow the complete fixed-duration settle phase."
}
$hapticDraw = $readingTableSource.IndexOf("CeremonialHaptics.drawn()")
$dealLanding = $readingTableSource.IndexOf("visualBaseline = target", $readingTableSource.IndexOf("private func runDeal"))
if ($dealLanding -lt 0 -or $hapticDraw -lt 0 -or $hapticDraw -lt $dealLanding) {
    throw "Draw haptics must occur only after the committed deal lands."
}

$cardsSourceForMeaning = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Screens/Cards/CardsViews.swift")
if ($cardsSourceForMeaning -cnotmatch [regex]::Escape('AppLocalization.text("Upright meaning")') -or
    $cardsSourceForMeaning -match [regex]::Escape('Label("Upright"')) {
    throw "Upright must be an editorial meaning heading, not a pseudo-button capsule."
}
if ($shellSource -cnotmatch [regex]::Escape("appearance.configureWithOpaqueBackground()") -or
    $shellSource -cnotmatch [regex]::Escape("UITabBar.appearance().standardAppearance = appearance") -or
    $shellSource -cnotmatch [regex]::Escape("UITabBar.appearance().scrollEdgeAppearance = appearance")) {
    throw "The tab bar must use one opaque UIKit appearance for standard and scroll-edge states."
}

$requiredA031CatalogKeys = @(
    "Language",
    "App Language",
    "Changes the app language immediately.",
    "Language changed to %@.",
    "Language Couldn't Be Changed",
    "The complete language content couldn't be loaded. Nothing was changed.",
    "Tap the deck to begin",
    "Tap the deck to shuffle.",
    "Tap the deck to draw.",
    "Shuffles the deck",
    "Draws the next card",
    "Upright meaning"
    "Start a Reading"
)
foreach ($key in $requiredA031CatalogKeys) {
    if ($null -eq $catalog.strings.PSObject.Properties[$key] -or
        [string]::IsNullOrWhiteSpace([string]$catalog.strings.$key.localizations.es.stringUnit.value)) {
        throw "A-031 catalog key or Spanish translation is missing: $key"
    }
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
Write-Host "Validated internal app snapshot: atomic English/Spanish selection, complete localized UI/content and printf parity, compact Home, opaque tab bar, one deck CTA, centered portrait and large landscape tables, V-048 post-commit motion/accessibility contracts, upright editorial heading, local atomic favorites, 78 cards and 6 guide articles per language, approved A-031 visual hashes, scope boundaries, $($verifiedRecords.Count)/78 bundled hash-verified provisional artwork candidates, and $placeholderCount explicit placeholders. This snapshot is not release-ready."
