param(
    [string]$NativeRoot = (Join-Path $PSScriptRoot ".."),
    [switch]$ReleaseGate,
    [switch]$InternalTestFlightGate
)

$ErrorActionPreference = "Stop"
if ($ReleaseGate -and $InternalTestFlightGate) {
    throw "ReleaseGate and InternalTestFlightGate are mutually exclusive."
}
$native = Resolve-Path -LiteralPath $NativeRoot
$projectFile = Join-Path $native.Path "TarotDeck.xcodeproj/project.pbxproj"
$appRoot = Join-Path $native.Path "TarotDeckApp"
$contentRoot = Join-Path $native.Path "Content"

function Get-PngMetadata {
    param([Parameter(Mandatory = $true)][string]$Path)

    $bytes = [IO.File]::ReadAllBytes($Path)
    $signature = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
    if ($bytes.Length -lt 33) { throw "PNG is too short: $Path" }
    for ($index = 0; $index -lt $signature.Length; $index++) {
        if ($bytes[$index] -ne $signature[$index]) { throw "Invalid PNG signature: $Path" }
    }

    $readUInt32BE = {
        param([byte[]]$Data, [int]$Offset)
        return [uint32](
            ([uint32]$Data[$Offset] -shl 24) -bor
            ([uint32]$Data[$Offset + 1] -shl 16) -bor
            ([uint32]$Data[$Offset + 2] -shl 8) -bor
            [uint32]$Data[$Offset + 3]
        )
    }

    $chunks = [Collections.Generic.List[string]]::new()
    $offset = 8
    while ($offset -le $bytes.Length - 12) {
        $length = [int](& $readUInt32BE $bytes $offset)
        if ($length -lt 0 -or $offset + 12 + $length -gt $bytes.Length) {
            throw "Invalid PNG chunk length: $Path"
        }
        $type = [Text.Encoding]::ASCII.GetString($bytes, $offset + 4, 4)
        $chunks.Add($type)
        $offset += 12 + $length
        if ($type -ceq "IEND") { break }
    }
    if ($chunks.Count -eq 0 -or $chunks[0] -cne "IHDR" -or $chunks[$chunks.Count - 1] -cne "IEND") {
        throw "PNG chunk structure is incomplete: $Path"
    }

    return [pscustomobject]@{
        Width = [int](& $readUInt32BE $bytes 16)
        Height = [int](& $readUInt32BE $bytes 20)
        BitDepth = [int]$bytes[24]
        ColorType = [int]$bytes[25]
        Chunks = @($chunks)
    }
}

function Get-PlistDictionaryValueNode {
    param(
        [Parameter(Mandatory = $true)][Xml.XmlElement]$Dictionary,
        [Parameter(Mandatory = $true)][string]$Key
    )

    $elements = @($Dictionary.ChildNodes | Where-Object {
        $_.NodeType -eq [Xml.XmlNodeType]::Element
    })
    for ($index = 0; $index -lt $elements.Count; $index++) {
        if ($elements[$index].LocalName -ceq "key" -and $elements[$index].InnerText -ceq $Key) {
            if ($index + 1 -ge $elements.Count) {
                throw "Privacy manifest key has no value: $Key"
            }
            return $elements[$index + 1]
        }
    }
    throw "Privacy manifest key is missing: $Key"
}

$deck = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "tarot-deck.v1.json") | ConvertFrom-Json
$meanings = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Education/card-meanings.v1.json") | ConvertFrom-Json
$guide = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Education/beginner-guide.v1.json") | ConvertFrom-Json
$spanishCopy = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Localization/card-copy.es.v1.json") | ConvertFrom-Json
$spanishMeanings = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Localization/card-meanings.es.v1.json") | ConvertFrom-Json
$spanishGuide = Get-Content -Raw -LiteralPath (Join-Path $contentRoot "Localization/beginner-guide.es.v1.json") | ConvertFrom-Json

if ($deck.cards.Count -ne 78) { throw "Deck must contain 78 cards." }
if ($meanings.cards.Count -ne 78) { throw "Meanings must contain 78 cards." }
if ($guide.articles.Count -ne 12) { throw "Guide must contain 4 foundations and 8 reading tutorials." }
if ($spanishCopy.language -cne "es" -or $spanishCopy.cards.Count -ne 78) {
    throw "Spanish card copy must contain exactly 78 records."
}
if ($spanishMeanings.language -cne "es" -or $spanishMeanings.cards.Count -ne 78) {
    throw "Spanish meanings must contain exactly 78 records."
}
if ($spanishGuide.language -cne "es" -or $spanishGuide.articles.Count -ne 12) {
    throw "Spanish guide must contain exactly 4 foundations and 8 reading tutorials."
}
$expectedGuideIDs = @(
    "how-to-read-tarot",
    "shuffle-and-draw",
    "symbols-and-patterns",
    "build-your-interpretation",
    "one-card-focus",
    "past-present-possible-direction",
    "situation-challenge-guidance",
    "you-other-person-connection",
    "yes-or-no-with-context",
    "freeform-reading",
    "six-card-guidance",
    "create-custom-spread"
)
if (@(Compare-Object $expectedGuideIDs @($guide.articles.id)).Count -gt 0 -or
    @(Compare-Object @($guide.articles.id) @($spanishGuide.articles.id)).Count -gt 0 -or
    (@($guide.articles.readingPresetID) -join '|') -cne (@($spanishGuide.articles.readingPresetID) -join '|')) {
    throw "English and Spanish tutorial IDs or preset mappings are incomplete or inconsistent."
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
$privacyManifestPath = Join-Path $appRoot "Resources/PrivacyInfo.xcprivacy"
if (-not (Test-Path -LiteralPath $privacyManifestPath -PathType Leaf)) {
    throw "The app privacy manifest is missing."
}

[xml]$privacyManifest = Get-Content -Raw -LiteralPath $privacyManifestPath
$plistRoot = $privacyManifest.DocumentElement
$rootElements = @($plistRoot.ChildNodes | Where-Object {
    $_.NodeType -eq [Xml.XmlNodeType]::Element
})
if ($plistRoot.LocalName -cne "plist" -or $rootElements.Count -ne 1 -or
    $rootElements[0].LocalName -cne "dict") {
    throw "PrivacyInfo.xcprivacy must contain one root plist dictionary."
}
$privacyRoot = [Xml.XmlElement]$rootElements[0]
$privacyRootElements = @($privacyRoot.ChildNodes | Where-Object {
    $_.NodeType -eq [Xml.XmlNodeType]::Element
})
$rootKeys = @($privacyRoot.ChildNodes | Where-Object {
    $_.NodeType -eq [Xml.XmlNodeType]::Element -and $_.LocalName -ceq "key"
} | ForEach-Object { $_.InnerText })
$expectedPrivacyRootKeys = @(
    "NSPrivacyTracking",
    "NSPrivacyCollectedDataTypes",
    "NSPrivacyAccessedAPITypes"
)
if ($privacyRootElements.Count -ne 6 -or $rootKeys.Count -ne $expectedPrivacyRootKeys.Count -or
    @(Compare-Object $expectedPrivacyRootKeys $rootKeys).Count -gt 0) {
    throw "PrivacyInfo.xcprivacy must contain only tracking, collected-data, and accessed-API declarations."
}

$trackingNode = Get-PlistDictionaryValueNode -Dictionary $privacyRoot -Key "NSPrivacyTracking"
if ($trackingNode.LocalName -cne "false") {
    throw "The app privacy manifest must declare NSPrivacyTracking=false."
}
$collectedDataNode = Get-PlistDictionaryValueNode -Dictionary $privacyRoot -Key "NSPrivacyCollectedDataTypes"
$collectedDataElements = @($collectedDataNode.ChildNodes | Where-Object {
    $_.NodeType -eq [Xml.XmlNodeType]::Element
})
if ($collectedDataNode.LocalName -cne "array" -or $collectedDataElements.Count -ne 0) {
    throw "The current app privacy manifest must declare an empty collected-data array."
}
$accessedAPIsNode = Get-PlistDictionaryValueNode -Dictionary $privacyRoot -Key "NSPrivacyAccessedAPITypes"
$accessedAPIDictionaries = @($accessedAPIsNode.ChildNodes | Where-Object {
    $_.NodeType -eq [Xml.XmlNodeType]::Element
})
if ($accessedAPIsNode.LocalName -cne "array" -or $accessedAPIDictionaries.Count -ne 1 -or
    $accessedAPIDictionaries[0].LocalName -cne "dict") {
    throw "The privacy manifest must declare exactly one required-reason API category."
}
$accessedAPIDictionary = [Xml.XmlElement]$accessedAPIDictionaries[0]
$accessedAPIElements = @($accessedAPIDictionary.ChildNodes | Where-Object {
    $_.NodeType -eq [Xml.XmlNodeType]::Element
})
$accessedAPIType = Get-PlistDictionaryValueNode -Dictionary $accessedAPIDictionary -Key "NSPrivacyAccessedAPIType"
$accessedAPIReasons = Get-PlistDictionaryValueNode -Dictionary $accessedAPIDictionary -Key "NSPrivacyAccessedAPITypeReasons"
$reasonElements = @($accessedAPIReasons.ChildNodes | Where-Object {
    $_.NodeType -eq [Xml.XmlNodeType]::Element
})
if ($accessedAPIElements.Count -ne 4 -or $accessedAPIType.LocalName -cne "string" -or
    $accessedAPIType.InnerText -cne "NSPrivacyAccessedAPICategoryUserDefaults" -or
    $accessedAPIReasons.LocalName -cne "array" -or $reasonElements.Count -ne 1 -or
    $reasonElements[0].LocalName -cne "string" -or $reasonElements[0].InnerText -cne "CA92.1") {
    throw "UserDefaults must be the only required-reason API and must use Apple reason CA92.1."
}

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
    "Assets.xcassets in Resources",
    "tarot-deck.v1.json in Resources",
    "card-meanings.v1.json in Resources",
    "beginner-guide.v1.json in Resources",
    "Localizable.xcstrings in Resources",
    "card-copy.es.v1.json in Resources",
    "card-meanings.es.v1.json in Resources",
    "beginner-guide.es.v1.json in Resources"
    "required-interface-keys.v1.json in Resources"
    "PrivacyInfo.xcprivacy in Resources"
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
if ([regex]::Matches($project, [regex]::Escape("PrivacyInfo.xcprivacy in Resources")).Count -ne 2 -or
    [regex]::Matches($project, 'PBXFileReference; lastKnownFileType = text\.xml; path = PrivacyInfo\.xcprivacy;').Count -ne 1) {
    throw "PrivacyInfo.xcprivacy must have one file reference and one target Resources membership."
}
if ([regex]::Matches($project, '(?m)^\s*ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\s*$').Count -ne 2) {
    throw "Debug and Release must both select the AppIcon asset catalog set."
}

$approvedIconSource = Join-Path $native.Path "../design/tarot-deck/app-icon-concepts/app-icon-d-three-card-fan.png"
$appIconMaster = Join-Path $native.Path "../design/tarot-deck/app-icon-masters/app-icon-d-three-card-fan-1024.png"
$appIconSet = Join-Path $appRoot "Resources/Assets.xcassets/AppIcon.appiconset"
$appIconAsset = Join-Path $appIconSet "AppIcon-1024.png"
$appIconContentsPath = Join-Path $appIconSet "Contents.json"
$approvedIconSourceSHA256 = "7F2DC4CE3A0A70DC9626D1C5FE9CF482CCB336DBD0971B7E8255771167031163"
$appIconSHA256 = "FFB38A413D8A99433A7A13E8626143A4FED96AD41AAB774D5D2C520C20BE200E"
foreach ($iconPath in @($approvedIconSource, $appIconMaster, $appIconAsset, $appIconContentsPath)) {
    if (-not (Test-Path -LiteralPath $iconPath -PathType Leaf)) {
        throw "Required approved AppIcon file is missing: $iconPath"
    }
}
if ((Get-FileHash -LiteralPath $approvedIconSource -Algorithm SHA256).Hash -cne $approvedIconSourceSHA256) {
    throw "The approved D icon concept changed."
}
foreach ($rendition in @($appIconMaster, $appIconAsset)) {
    if ((Get-FileHash -LiteralPath $rendition -Algorithm SHA256).Hash -cne $appIconSHA256) {
        throw "The prepared D AppIcon rendition hash changed: $rendition"
    }
    $png = Get-PngMetadata -Path $rendition
    if ($png.Width -ne 1024 -or $png.Height -ne 1024 -or $png.BitDepth -ne 8 -or $png.ColorType -ne 2) {
        throw "AppIcon must be a 1024x1024 8-bit opaque RGB PNG: $rendition"
    }
    if ($png.Chunks -notcontains "sRGB" -or $png.Chunks -contains "tRNS") {
        throw "AppIcon must declare sRGB and contain no transparency: $rendition"
    }
}
$appIconContents = Get-Content -Raw -LiteralPath $appIconContentsPath | ConvertFrom-Json
$appIconImages = @($appIconContents.images)
if ($appIconImages.Count -ne 1 -or
    [string]$appIconImages[0].filename -cne "AppIcon-1024.png" -or
    [string]$appIconImages[0].idiom -cne "universal" -or
    [string]$appIconImages[0].platform -cne "ios" -or
    [string]$appIconImages[0].size -cne "1024x1024" -or
    [string]$appIconContents.info.author -cne "xcode" -or
    [int]$appIconContents.info.version -ne 1) {
    throw "AppIcon Contents.json does not define the single universal 1024x1024 iOS rendition."
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
    $contentSource -cnotmatch [regex]::Escape("private static let expectedGuideIDs") -or
    $contentSource -cnotmatch [regex]::Escape("guideIsValid(spanishGuide.articles)") -or
    $contentSource -cnotmatch [regex]::Escape("throw TarotContentLoadError.invalidLocalizedContent") -or
    ([regex]::Matches($contentSource, [regex]::Escape("return english"))).Count -ne 1) {
    throw "Spanish loading must be bundle-aware, atomic, and fail rather than mix languages."
}

$sourceText = Get-ChildItem -LiteralPath $appRoot -Recurse -File -Filter *.swift |
    Get-Content -Raw
$allAppSource = $sourceText -join "`n"
$forbidden = @("StoreKit", "Zodiac", "Android")
foreach ($term in $forbidden) {
    if ($allAppSource -match [regex]::Escape($term)) {
        throw "Out-of-scope app source term found: $term"
    }
}
if ($allAppSource -match '(?m)^\s*import\s+(Network|WebKit|StoreKit|AdSupport|AppTrackingTransparency|UserNotifications|CoreLocation|AVFoundation|Photos|Contacts|EventKit|HealthKit|CoreBluetooth)\b' -or
    $allAppSource -match '\b(URLSession|URLRequest|NWConnection|NWPathMonitor|WKWebView|openURL|UIApplication\.shared\.open)\b' -or
    $allAppSource -match 'https?://' -or
    $allAppSource -match '\b(requestAuthorization|requestAccess|ATTrackingManager|UNUserNotificationCenter|CLLocationManager|AVCaptureDevice|PHPhotoLibrary|CNContactStore|EKEventStore|HKHealthStore|CBCentralManager)\b' -or
    $allAppSource -match '\b(Firebase|GoogleMobileAds|GADMobileAds|Sentry|Crashlytics|Mixpanel|Amplitude)\b') {
    throw "App source contains unauthorized network, permission, or third-party SDK integration."
}
$packageSource = Get-Content -Raw -LiteralPath (Join-Path $native.Path "Package.swift")
if ($packageSource -match '\.package\s*\(' -or $project -match 'XCRemoteSwiftPackageReference|repositoryURL' -or
    $project -match 'INFOPLIST_KEY_NS[A-Za-z]+UsageDescription|CODE_SIGN_ENTITLEMENTS') {
    throw "The app target contains an external package, permission usage description, or entitlement file."
}
$entitlementFiles = @(Get-ChildItem -LiteralPath $native.Path -Recurse -File -Filter *.entitlements)
if ($entitlementFiles.Count -gt 0) {
    throw "The current app must not bundle entitlement files."
}
$frameworkNames = @([regex]::Matches($project, '(?m)^\s*[A-F0-9]+ /\* (.+?) in Frameworks \*/') |
    ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
if ($frameworkNames.Count -ne 1 -or $frameworkNames[0] -cne "TarotDeckCore") {
    throw "The app target must link only the local TarotDeckCore product."
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
$activeReadSource = [regex]::Replace($readSource, '(?s)#if false.*?#endif', '')
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
    "requestReadingFromLearn",
    "enum ThreeCardSpread",
    "enum ReadingPreset",
    "case resetting",
    "case shuffling",
    "selectedPreset: ReadingPreset = .pastPresentFuture",
    "startSelectedPreset",
    "func leaveTable()",
    "func resetReading()",
    "canPrepareAnotherReading",
    "canShuffleDeck",
    "func canPlaceCard(at slotIndex: Int)",
    "func placeNextCard(at slotIndex: Int)",
    "coordinator.draw(into: slotIndex)",
    "drawnCard(atPosition: slotIndex)",
    "case sixCards",
    "case customCards",
    "activeDefinition: SpreadDefinitionSnapshot?",
    "JSONCustomSpreadStore",
    "selectedCustomSpreadID",
    "activeCardCount"
)
foreach ($contract in $requiredRecoveryContracts) {
    if ($readModelSource -cnotmatch [regex]::Escape($contract)) {
        throw "Read recovery contract is missing: $contract"
    }
}
$deckEngineSource = Get-Content -Raw -LiteralPath (Join-Path $native.Path "Sources/TarotDeckCore/DeckEngine.swift")
$coordinatorSource = Get-Content -Raw -LiteralPath (Join-Path $native.Path "Sources/TarotDeckCore/DeckSessionCoordinator.swift")
$deckSessionSource = Get-Content -Raw -LiteralPath (Join-Path $native.Path "Sources/TarotDeckCore/DeckSession.swift")
$atomicPlacementContracts = @(
    'currentSchemaVersion = 2',
    'positionIndex: Int',
    'storedSchemaVersion == 1',
    'restoredCards[index].positionIndex = index',
    'public func draw(',
    'into positionIndex: Int',
    'positionAlreadyOccupied',
    'var candidate = session',
    'let drawnCard = try engine.draw(into: positionIndex, from: &candidate, at: date)',
    'try commit(candidate)'
)
foreach ($contract in $atomicPlacementContracts) {
    if ("$deckSessionSource`n$deckEngineSource`n$coordinatorSource" -cnotmatch [regex]::Escape($contract)) {
        throw "Atomic slot-placement contract is missing: $contract"
    }
}
$engineTestsSource = Get-Content -Raw -LiteralPath (Join-Path $native.Path "Tests/TarotDeckCoreTests/DeckEngineTests.swift")
$coordinatorTestsSource = Get-Content -Raw -LiteralPath (Join-Path $native.Path "Tests/TarotDeckCoreTests/DeckSessionCoordinatorTests.swift")
$storeTestsSource = Get-Content -Raw -LiteralPath (Join-Path $native.Path "Tests/TarotDeckCoreTests/DeckSessionStoreTests.swift")
$placementTestContracts = @(
    'let requestedPositions = [2, 0, 1]',
    'for count in 1...12',
    'testConcurrentPlacementIntoSamePositionCommitsExactlyOnce',
    'testConcurrentPlacementIntoDistinctPositionsSerializesDeckOrder',
    'testFailedPlacementSavePreservesPreviousMemoryAndStorage',
    'testSchemaOneSessionMigratesSequentialPositionsWithoutChangingCards'
)
foreach ($contract in $placementTestContracts) {
    if ("$engineTestsSource`n$coordinatorTestsSource`n$storeTestsSource" -cnotmatch [regex]::Escape($contract)) {
        throw "A-054 Core test contract is missing: $contract"
    }
}
if ($activeReadSource -match [regex]::Escape('stagedPreset != .oneCard') -or
    $activeReadSource -cnotmatch [regex]::Escape('stagedPreset?.layout == .threeCards') -or
    $activeReadSource -cnotmatch [regex]::Escape('if stagedPreset == .oneCard { stagedPreset = nil }')) {
    throw "Entering Three Cards from One Card must leave all five styles visually unselected."
}
$readyWrite = $readModelSource.IndexOf(".ready(layout, spread: self.spread, definition: self.activeDefinition)")
$sessionWrite = $readModelSource.IndexOf("self.coordinator.startSession()")
if ($readyWrite -lt 0 -or $sessionWrite -lt 0 -or $readyWrite -gt $sessionWrite) {
    throw "The ready continuity record must be persisted before startSession."
}
$leaveStart = $readModelSource.IndexOf("func leaveTable()")
$leaveSessionClear = $readModelSource.IndexOf("try await self.coordinator.clearSession()", $leaveStart)
$leaveContinuityClear = $readModelSource.IndexOf("try self.continuityStore.clear()", $leaveSessionClear)
$leavePublishHome = $readModelSource.IndexOf("self.resetToHome()", $leaveContinuityClear)
if ($leaveStart -lt 0 -or $leaveSessionClear -lt 0 -or $leaveContinuityClear -lt 0 -or
    $leavePublishHome -lt 0 -or $leaveSessionClear -gt $leaveContinuityClear -or
    $leaveContinuityClear -gt $leavePublishHome) {
    throw "Back must clear durable session/continuity before publishing Home."
}
$resetStart = $readModelSource.IndexOf("func resetReading()")
$resetIntent = $readModelSource.IndexOf(".resetting(", $resetStart)
$resetSessionClear = $readModelSource.IndexOf("try await self.coordinator.clearSession()", $resetIntent)
$resetReady = $readModelSource.IndexOf(".ready(layout, spread: currentSpread, definition: currentDefinition)", $resetSessionClear)
$resetPublish = $readModelSource.IndexOf("self.session = nil", $resetReady)
if ($resetStart -lt 0 -or $resetIntent -lt 0 -or $resetSessionClear -lt 0 -or
    $resetReady -lt 0 -or $resetPublish -lt 0 -or $resetIntent -gt $resetSessionClear -or
    $resetSessionClear -gt $resetReady -or $resetReady -gt $resetPublish) {
    throw "Reset must persist intent, clear the session, persist ready state, then publish UI."
}
$shellSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "App/TarotDeckMainShell.swift")
$appSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "App/TarotDeckInternalApp.swift")
if ($appSource -match '#if\s+DEBUG|EmptyView\(\)' -or
    $readModelSource -match '#if\s+DEBUG' -or
    $activeReadSource -match '#if\s+DEBUG') {
    throw "The real Tarot UI and read flow must compile in Release without DEBUG-only gates."
}
$projectReleaseContracts = @(
    'MARKETING_VERSION = 0.7.2;',
    'CURRENT_PROJECT_VERSION = 1;',
    'PRODUCT_BUNDLE_IDENTIFIER = com.krazel.tarotdeck;',
    'INFOPLIST_KEY_CFBundleDisplayName = "Tarot Deck";',
    'INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;',
    'IPHONEOS_DEPLOYMENT_TARGET = 16.0;',
    'CODE_SIGN_STYLE = Automatic;'
)
foreach ($contract in $projectReleaseContracts) {
    if ($project -cnotmatch [regex]::Escape($contract)) {
        throw "TestFlight project contract is missing: $contract"
    }
}
if ([regex]::Matches($project, [regex]::Escape('MARKETING_VERSION = 0.7.2;')).Count -ne 2 -or
    [regex]::Matches($project, [regex]::Escape('CURRENT_PROJECT_VERSION = 1;')).Count -ne 2 -or
    [regex]::Matches($project, [regex]::Escape('INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;')).Count -ne 2 -or
    [regex]::Matches($project, [regex]::Escape('PRODUCT_BUNDLE_IDENTIFIER = com.krazel.tarotdeck.internal.provisional;')).Count -ne 1 -or
    [regex]::Matches($project, [regex]::Escape('PRODUCT_BUNDLE_IDENTIFIER = com.krazel.tarotdeck;')).Count -ne 1 -or
    $project -match '(?m)^\s*DEVELOPMENT_TEAM\s*=') {
    throw "Debug and Release identity/version/signing contracts are not separated exactly as required."
}
if ($shellSource -cnotmatch [regex]::Escape("startReading(presetID)") -or
    $appSource -cnotmatch [regex]::Escape("readModel.requestReadingFromLearn(preset)")) {
    throw "Learn preset CTAs are not connected to ReadFlowModel."
}
if ($readModelSource -cnotmatch [regex]::Escape("else if layout == nil") -or
    $readModelSource -cnotmatch [regex]::Escape("selectedPreset = preset") -or
    $readModelSource -match 'requestReadingFromLearn(?s).*?(layoutChoice|spreadChoice)') {
    throw "Learn CTAs must preselect an existing preset or prepare it directly without a choice screen."
}
if ($readModelSource -cnotmatch [regex]::Escape("options: .atomic") -or
    $appSource -cnotmatch [regex]::Escape('active-session.v1.json') -or
    $appSource -cnotmatch [regex]::Escape('reading-continuity.v1.json')) {
    throw "Reading continuity must use a distinct atomic JSON sidecar next to the active session."
}

$presetPreferenceContracts = @(
    'private static let presetPreferenceKey = "tarot.readingPreset.v1"',
    'private static let fallbackPreset: ReadingPreset = .pastPresentFuture',
    '@Published private(set) var selectedPreset: ReadingPreset = .pastPresentFuture',
    'private let preferences: UserDefaults',
    'private var homePresetPreference: ReadingPreset',
    'preferences: UserDefaults = .standard',
    'let homePresetPreference = Self.loadHomePresetPreference(from: preferences)',
    'self.selectedPreset = homePresetPreference',
    'private static func loadHomePresetPreference(from preferences: UserDefaults)',
    'preferences.object(forKey: presetPreferenceKey)',
    'ReadingPreset(rawValue: rawValue)',
    'preferences.removeObject(forKey: presetPreferenceKey)',
    'selectedPreset = homePresetPreference'
)
foreach ($contract in $presetPreferenceContracts) {
    if ($readModelSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-043 saved Home preset contract is missing: $contract"
    }
}
$loadPresetPreferenceStart = $readModelSource.IndexOf('private static func loadHomePresetPreference')
$loadCustomPreferenceStart = $readModelSource.IndexOf('private static func loadCustomSelectionPreference', $loadPresetPreferenceStart)
if ($loadPresetPreferenceStart -lt 0 -or $loadCustomPreferenceStart -le $loadPresetPreferenceStart) {
    throw "A-056 Home default preference source boundaries could not be validated."
}
$loadPresetPreferenceSource = $readModelSource.Substring(
    $loadPresetPreferenceStart,
    $loadCustomPreferenceStart - $loadPresetPreferenceStart
)
if ($loadPresetPreferenceSource -cnotmatch [regex]::Escape('guard let storedValue = preferences.object(forKey: presetPreferenceKey) else {') -or
    ([regex]::Matches($loadPresetPreferenceSource, [regex]::Escape('return fallbackPreset'))).Count -ne 2 -or
    $loadPresetPreferenceSource -match 'preferences\.set\(') {
    throw "A-056 must default a fresh install to Past/Present/Possible Direction without writing over an explicit saved preference."
}
$selectPresetStart = $readModelSource.IndexOf('func selectPreset(_ preset: ReadingPreset)')
$startSelectedPresetStart = $readModelSource.IndexOf('func startSelectedPreset()', $selectPresetStart)
if ($selectPresetStart -lt 0 -or $startSelectedPresetStart -le $selectPresetStart) {
    throw "A-043 selectPreset source boundaries could not be validated."
}
$selectPresetSource = $readModelSource.Substring(
    $selectPresetStart,
    $startSelectedPresetStart - $selectPresetStart
)
$presetSelectionGuard = $selectPresetSource.IndexOf('guard !isBusy, surface == .home, layout == nil, session == nil else { return }')
$presetPreferenceWrite = $selectPresetSource.IndexOf('preferences.set(preset.rawValue, forKey: Self.presetPreferenceKey)')
$presetMemoryWrite = $selectPresetSource.IndexOf('homePresetPreference = preset')
$presetPublication = $selectPresetSource.IndexOf('selectedPreset = preset')
if ($presetSelectionGuard -lt 0 -or $presetPreferenceWrite -le $presetSelectionGuard -or
    $presetMemoryWrite -le $presetPreferenceWrite -or $presetPublication -le $presetMemoryWrite -or
    [regex]::Matches(
        $readModelSource,
        [regex]::Escape('preferences.set(preset.rawValue, forKey: Self.presetPreferenceKey)')
    ).Count -ne 1) {
    throw "A-043 must write the validated explicit Home selection before publishing it, exactly once."
}
$resetToHomeStart = $readModelSource.IndexOf('private func resetToHome()')
$presentRecoveryStart = $readModelSource.IndexOf('private func presentRecovery', $resetToHomeStart)
if ($resetToHomeStart -lt 0 -or $presentRecoveryStart -le $resetToHomeStart -or
    $readModelSource.Substring($resetToHomeStart, $presentRecoveryStart - $resetToHomeStart) -cnotmatch
        [regex]::Escape('selectedPreset = homePresetPreference')) {
    throw "A-043 must return Home to the saved explicit preference after ending or discarding a session."
}
$storagePreparationCall = $appSource.IndexOf("storageDirectoryURL = try Self.prepareStorageDirectory()")
$firstPersistencePath = $appSource.IndexOf('appendingPathComponent("active-session.v1.json"')
$storageContracts = @(
    "private static func prepareStorageDirectory(",
    'appendingPathComponent("TarotDeckInternal", isDirectory: true)',
    "try fileManager.createDirectory(",
    "resourceValues.isExcludedFromBackup = true",
    "try storageDirectoryURL.setResourceValues(resourceValues)",
    "forKeys: [.isExcludedFromBackupKey]",
    "guard verifiedValues.isExcludedFromBackup == true",
    'preconditionFailure("Private app storage could not be prepared:'
)
foreach ($contract in $storageContracts) {
    if ($appSource -cnotmatch [regex]::Escape($contract)) {
        throw "Private storage preparation contract is missing: $contract"
    }
}
if ($storagePreparationCall -lt 0 -or $firstPersistencePath -lt 0 -or
    $storagePreparationCall -gt $firstPersistencePath -or
    [regex]::Matches($allAppSource, [regex]::Escape("isExcludedFromBackup = true")).Count -ne 1) {
    throw "The shared persistence directory must be excluded from backup exactly once before stores receive file URLs."
}
if ($readModelSource -match 'case\s+(layoutChoice|spreadChoice)\b|pendingReplacement|showsReplace|showsEndReading|requestEndReading|confirmEndReading' -or
    $activeReadSource -match 'LayoutChoiceView|ThreeCardSpreadChoiceView|activeHome|End Reading|Start a new reading\?') {
    throw "A-033 retired setup, replacement, active-Home, or End Reading behavior is still user-facing."
}
if ($activeReadSource -cnotmatch [regex]::Escape("ReadingChoiceOverlay") -or
    $activeReadSource -cnotmatch [regex]::Escape("let definition = model.activeDefinition") -or
    $activeReadSource -cnotmatch [regex]::Escape("ReadingStageLayoutMetrics.make(") -or
    $activeReadSource -cnotmatch [regex]::Escape("minimumVisibleGap: 14") -or
    $activeReadSource -cnotmatch [regex]::Escape("private var landscapeHeader") -or
    $activeReadSource -cnotmatch [regex]::Escape("let deckWidth = min(max(size.width * 0.18, 140), 160)")) {
    throw "The progressive visual reading selector or normalized portrait/landscape table is missing."
}

$motionSourcePath = Join-Path $appRoot "Design/CeremonialMotion.swift"
$motionSpecPath = Join-Path $native.Path "../design/tarot-deck/MOTION_SPEC.md"
$motionStoryboardPath = Join-Path $native.Path "../design/tarot-deck/reading-table-manual-placement-motion-storyboard-v4-a-ceremonial-obsidian.png"
if (-not (Test-Path -LiteralPath $motionSourcePath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $motionSpecPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $motionStoryboardPath -PathType Leaf)) {
    throw "The approved motion source, specification, and storyboard must all be present."
}
$motionSource = Get-Content -Raw -LiteralPath $motionSourcePath
$motionContracts = @(
    "CeremonialShufflingDeck",
    "CeremonialDeckButtonStyle",
    "CeremonialPlacementGeometryEffect: GeometryEffect",
    "CeremonialFlipFaceModifier: AnimatableModifier",
    "var animatableData: CGFloat",
    "static let riffle",
    "shuffleSettleDuration: TimeInterval = 0.20",
    "outgoingTopZIndex",
    "incomingTopOpacity",
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
$expectedMotionStoryboardSHA256 = "9286DB57DAFA170C87376634289BC5F311F108CFC3F9531A5B2164067DEA25B0"
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

$a054VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-shuffled-tap-position-v1-spanish-a-ceremonial-obsidian.png") = "1CEB2D510ABB6652EF60BEC0B9984E843F3DB8B632C088430E78167D9B3FDF0B"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-partial-middle-first-v1-spanish-a-ceremonial-obsidian.png") = "A7F3B0604708E7858AD7864D2912B0436BFC0D5211436D22F35CB63A333D1481"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-partial-middle-first-landscape-v1-spanish-a-ceremonial-obsidian.png") = "73BFC33AEC64E89D60932E5D4A30B59CDAFFBAD953380A56C970E7A6EADECF26"
    $motionStoryboardPath = $expectedMotionStoryboardSHA256
    (Join-Path $native.Path "../design/tarot-deck/reading-table-six-card-partial-action-first-v1-spanish-a-ceremonial-obsidian.png") = "EE3D40472A08DD8878C403AE022C233879F1740C626230216337F7BB11B203D5"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-custom-seven-partial-v1-landscape-spanish-a-ceremonial-obsidian.png") = "805ED5688AEF2E5C5841DEEF8539C4FBF8D59226E6BC3825F2224EFAFDA9878E"
}
foreach ($entry in $a054VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "A-054 approved visual reference is missing or changed: $($entry.Key)"
    }
}

$a055VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-card-shuffled-compact-landscape-v1-spanish-a-ceremonial-obsidian.png") = "0F8A809716E64A3B2EF6F177CE2FAFD676A8413F903C8EAF9F01F4960B69EB20"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-card-partial-compact-landscape-v1-spanish-a-ceremonial-obsidian.png") = "245B43A48017D8DDBC7D1F2CEECF1FF6EC94F3B0D0058FF3AF3C99E4F79929D5"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-card-complete-compact-landscape-v1-spanish-a-ceremonial-obsidian.png") = "8551828AD92F4661C73011147F66080596B818A2DF0EEFB334260B33363F05B8"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-card-portrait-orientation-hint-v1-spanish-a-ceremonial-obsidian.png") = "1C3286E78D7E55FEDC6ADE3F9917B9793589739A33B3AAE9A2AC99FA4DB0C47A"
}
foreach ($entry in $a055VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "A-055 approved visual reference is missing or changed: $($entry.Key)"
    }
}

$a033VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/read-home-visual-preset-carousel-spanish-a-ceremonial-obsidian.png") = "8D02A2AF9BFB395B8DE9998FC55203C9B571A9CBE7E2C7A36C93A3B16E1B1682"
    (Join-Path $native.Path "../design/tarot-deck/read-home-visual-preset-carousel-landscape-spanish-a-ceremonial-obsidian.png") = "F454660DDB68388A1FCC408806A86762F15283C71CAC30548B151D63F2F4040A"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-quick-restart-all-revealed-spanish-a-ceremonial-obsidian.png") = "D30E951A91CE53049D5871E964DB05D4E9215B59BCECED12C159CA63E4E777E9"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-quick-restart-landscape-spanish-a-ceremonial-obsidian.png") = "1A7749728BA62E51D1E2F75463B077329E9397AA04E30C856998E04FE242FE10"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-one-card-quick-restart-spanish-a-ceremonial-obsidian.png") = "EDFCDC1C87D5F9D32194A58B7AD2F82862DAE9080467E4B44612DC2041628BF4"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-one-card-quick-restart-landscape-spanish-a-ceremonial-obsidian.png") = "B6591843EB4670CACEBE297D8D8836411C8FF9CAD52321120B6795CA1DC9A7FB"
}
foreach ($entry in $a033VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "An approved A-033 visual reference is absent or changed: $($entry.Key)"
    }
}

$a042VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/read-home-compact-selector-spanish-a-ceremonial-obsidian.png") = "9C0D453917EFC6D16DE3A6013E6B3BD3F45949F48D229F688C77A26E6FAA0C29"
    (Join-Path $native.Path "../design/tarot-deck/read-home-reading-count-selector-spanish-a-ceremonial-obsidian.png") = "07C576509A7D1EAD797AEC45F70E4BE9846104CBBC439473FF92DE57EA6B02A4"
    (Join-Path $native.Path "../design/tarot-deck/read-home-three-card-style-selector-spanish-a-ceremonial-obsidian.png") = "27C88125F761A813EF3D69FCFFF8D63CD70AE9688B7B0E4CA1CC871250BCC33F"
    (Join-Path $native.Path "../design/tarot-deck/read-home-compact-selector-landscape-spanish-a-ceremonial-obsidian.png") = "C1E3AB1BCBC9E8F15E1D19D1C0E1F6BC51A85CF23D5A8A4C00BFF05F5E67879D"
    (Join-Path $native.Path "../design/tarot-deck/read-home-reading-count-selector-landscape-spanish-a-ceremonial-obsidian.png") = "E8DC2B15607B4E7F762B12F76BFAB7DDA6D51C40125D9692885CB4DBA4BD5973"
    (Join-Path $native.Path "../design/tarot-deck/read-home-three-card-style-selector-landscape-spanish-a-ceremonial-obsidian.png") = "9E984B16F97181A8189CF851E66F94667394600F212BE0BF34BBE2701D62A944"
}
foreach ($entry in $a042VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "An approved A-042 visual reference is absent or changed: $($entry.Key)"
    }
}

$a044VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/read-shell-translucent-tabbar-spanish-a-ceremonial-obsidian.png") = "C76D9D579AD0341E95C717DD0B834A8D29A609BB70DDCFEFCA2C9AF853E1AB9D"
}
foreach ($entry in $a044VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "The approved A-044 tab bar reference is absent or changed: $($entry.Key)"
    }
}

$a045VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/read-home-three-card-style-selector-yes-no-spanish-a-ceremonial-obsidian.png") = "96B3F2DF08B1668AAB57219904C91C87851E37F76B6290AC7CF70B3DC787E071"
    (Join-Path $native.Path "../design/tarot-deck/read-home-three-card-style-selector-yes-no-landscape-spanish-a-ceremonial-obsidian.png") = "04316D9C557A8E530BFC622FC31158F6AF5AC9DB9D4466779C2D0302B1FFD0F7"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-yes-no-face-down-spanish-a-ceremonial-obsidian.png") = "E5B084EF0D98A1E5E9A7D79F49714A8FC8A98366149D0564A813A9F95D611574"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-yes-no-all-revealed-spanish-a-ceremonial-obsidian.png") = "96A99F433CB0AC959AF43DABFA78F935B8263CC19D61DC20407EA2F2E82FE7C9"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-yes-no-all-revealed-landscape-spanish-a-ceremonial-obsidian.png") = "EB02233108B1CAEAAB77FDFF5EE2D4242930F7671FE6CE14F6F7D09866E8E24D"
}
foreach ($entry in $a045VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "An approved A-045 Yes or No visual reference is absent or changed: $($entry.Key)"
    }
}

$a048VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/learn-index-foundations-with-tutorials-spanish-a-ceremonial-obsidian.png") = "4A189CAF9A748D7ADF91C1E5B86A79B6CD7525CF79B34A8A105BD9064A4F80C6"
    (Join-Path $native.Path "../design/tarot-deck/learn-reading-tutorials-index-spanish-a-ceremonial-obsidian.png") = "75A1B78C069CD8FB5FB5DDB7931F949BE9BDCD5AFA6D5D374F3331370B73FF28"
    (Join-Path $native.Path "../design/tarot-deck/read-home-reading-count-selector-info-spanish-a-ceremonial-obsidian.png") = "8AD118426B2D1B7BDA0F00F4012EF59DF85A2152791510F4E8BC41BDFAECA576"
    (Join-Path $native.Path "../design/tarot-deck/read-home-reading-count-selector-info-landscape-spanish-a-ceremonial-obsidian.png") = "77BCD0B4FA279E5A92E18D2B27B1E332E3788E5412B0EEE3BE7E28B515EAE943"
    (Join-Path $native.Path "../design/tarot-deck/read-home-three-card-style-selector-free-info-spanish-a-ceremonial-obsidian.png") = "95057F7A6F6BAE859088D7D2EE806130EFBB88B8635A05DADDD455466DD6E503"
    (Join-Path $native.Path "../design/tarot-deck/read-home-three-card-style-selector-free-info-landscape-spanish-a-ceremonial-obsidian.png") = "B8F5598D312B7587CE31A2F3D86AD92246A4FB7DB0546E8A305B4701CF192FBE"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-free-three-cards-face-down-spanish-a-ceremonial-obsidian.png") = "06A7E6172BBB0118C450E70CBB7B1D0AFFF26049C8AD0DC8E65B34415B2F3F64"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-free-three-cards-face-down-landscape-spanish-a-ceremonial-obsidian.png") = "237339897355BBA5CF0B985EE5D9536A8F0444AC03C773D89A0F33CDBFE82E3B"
}
foreach ($entry in $a048VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "An approved A-048 visual reference is absent or changed: $($entry.Key)"
    }
}

$a052VisualReferences = @{
    (Join-Path $native.Path "../design/tarot-deck/read-home-reading-count-selector-info-small-v2-spanish-a-ceremonial-obsidian.png") = "8FFA3087C0AE2102C3E138926242AFA7EE6E1A802C730037375B84B0603D46E5"
    (Join-Path $native.Path "../design/tarot-deck/read-home-three-card-style-selector-grid-five-neutral-v4-spanish-a-ceremonial-obsidian.png") = "5A5B0D1F6206C6F0575646F44BB11991D5AC1C397DCDEDFD4D1E9342F0E87230"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-ready-to-shuffle-controls-v1-spanish-a-ceremonial-obsidian.png") = "AFD4E9E6333C5A304F7D4D3E976440BF2C97B1C1E15914F2FED90D5AB667D4B9"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-ready-to-shuffle-controls-landscape-v1-spanish-a-ceremonial-obsidian.png") = "A9C1705BCB052D7DB05C75D4290715600500812057C89BB82B5E3A05E5860E22"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-shuffled-ready-deal-controls-v3-spanish-a-ceremonial-obsidian.png") = "008D26EC5D6D7C64237B5F333B7D99B8F250AAB97D4623AAF8F487BB4B25C547"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-three-cards-shuffled-ready-deal-controls-landscape-v3-spanish-a-ceremonial-obsidian.png") = "77AF66B4D7E537EBCFFC1B075B81FA1BA89CEC00F509BB0F743A56EE63813437"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-yes-no-all-revealed-info-v2-spanish-a-ceremonial-obsidian.png") = "C295B0F6C197FFFAE23B89BE3EED2B3D888F57BF1E568500BCAF334ACB955E2B"
    (Join-Path $native.Path "../design/tarot-deck/reading-table-yes-no-all-revealed-info-landscape-v2-spanish-a-ceremonial-obsidian.png") = "580079082489E69CA459AB598A976751A8403600E46EF0C15B6272A076BED89A"
    (Join-Path $native.Path "../design/tarot-deck/read-contextual-tutorial-yes-no-v2-spanish-a-ceremonial-obsidian.png") = "BEB6283ED6AD8FCCCA2F5F880F1AABC10FDC743608564A8D33E200DED39D0F31"
    $motionStoryboardPath = $expectedMotionStoryboardSHA256
}
foreach ($entry in $a052VisualReferences.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Key -PathType Leaf) -or
        (Get-FileHash -LiteralPath $entry.Key -Algorithm SHA256).Hash -cne $entry.Value) {
        throw "An approved A-052 visual reference is absent or changed: $($entry.Key)"
    }
}

$yesNoModelContracts = @(
    'case open',
    'case .open: return "Yes or No"',
    'return AppLocalization.text("For, against, and destiny.")',
    'return ["For", "Against", "Destiny"]',
    'case .open: return ThreeCardSpread.open.summary'
)
foreach ($contract in $yesNoModelContracts) {
    if ($readModelSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-045 Yes or No model contract is missing: $contract"
    }
}
if ($readModelSource -cmatch '(?i)For, against, and the likely outcome|\["For", "Against", "Outcome"\]' -or
    $activeReadSource -cnotmatch [regex]::Escape('AppLocalization.format("%@, face down", positionTitle(at: index))') -or
    $activeReadSource -cnotmatch [regex]::Escape('Text(preset.selectorDetail)') -or
    $activeReadSource -cnotmatch [regex]::Escape('.accessibilityValue(preset == .open ? preset.selectorDetail : "")')) {
    throw "A-050 must remove legacy Outcome copy and route the Destiny position through the shared visible and VoiceOver label."
}

$freeformModelContracts = @(
    'case freeform',
    'case .freeform: return "Freeform"',
    'return AppLocalization.text("Three cards without assigned positions.")',
    'return ["Card 1", "Card 2", "Card 3"]',
    'case .freeform: return .freeform',
    'case .open: return .open'
)
foreach ($contract in $freeformModelContracts) {
    if ($readModelSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-048 Freeform migration contract is missing: $contract"
    }
}
if ([regex]::Matches($readModelSource, [regex]::Escape('spread ?? .freeform')).Count -lt 2 -or
    $readModelSource -cmatch [regex]::Escape('spread ?? .open')) {
    throw "A-048 continuity migration must resolve exactly two missing three-card spreads to Freeform while preserving explicit open."
}

$guideRuntimeContracts = @(
    'private static let expectedGuidePresetIDs: [String?]',
    'ordered.map(\.readingPresetID) == expectedGuidePresetIDs',
    'Set(ordered.compactMap(\.readingPresetID)).count == 8'
)
foreach ($contract in $guideRuntimeContracts) {
    if ($contentSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-048 exact runtime guide sequence contract is missing: $contract"
    }
}
if ($readModelSource -cmatch [regex]::Escape('AppLocalization.text("Open reading")') -or
    $readModelSource -cmatch [regex]::Escape('AppLocalization.text("No assigned positions.")')) {
    throw "The former open-reading presentation must not remain user-facing after A-045."
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
    ".environment(\.locale, languageStore.language.locale)"
)
$languageContractSource = "$localizationSource`n$shellSource`n$appSource"
foreach ($contract in $languageContracts) {
    if ($languageContractSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-031 language contract is missing: $contract"
    }
}
if ($languageContractSource -match '\.accessibilityLanguage\(|\baccessibilityCode\b') {
    throw "A-031 must not use the nonexistent SwiftUI accessibilityLanguage modifier; explicit locale drives localized Text and announcements on iOS 16."
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

$homeStart = $activeReadSource.IndexOf("private struct ReadHomeView")
$homeEnd = $activeReadSource.IndexOf("private struct ReadingTableView")
if ($homeStart -lt 0 -or $homeEnd -le $homeStart) {
    throw "Read Home source boundaries could not be validated."
}
$homeSource = $activeReadSource.Substring($homeStart, $homeEnd - $homeStart)
$emptyStart = $homeSource.IndexOf("private var emptyHome")
if ($emptyStart -lt 0 -or
    $homeSource -cnotmatch [regex]::Escape('Button(action: openSettings)') -or
    $homeSource -cnotmatch [regex]::Escape('if dynamicTypeSize.isAccessibilitySize') -or
    $homeSource -cnotmatch [regex]::Escape('let isSmallPortrait = proxy.size.height < 620') -or
    $homeSource -cnotmatch [regex]::Escape('let needsSmallPortraitScroll = !isLandscape && isSmallPortrait &&') -or
    $homeSource -cnotmatch [regex]::Escape('(dynamicTypeSize == .xxLarge || dynamicTypeSize == .xxxLarge)') -or
    $homeSource -cnotmatch [regex]::Escape('if dynamicTypeSize.isAccessibilitySize || needsSmallPortraitScroll') -or
    $homeSource -cnotmatch [regex]::Escape('dynamicTypeSize.isAccessibilitySize ? 860 : 640') -or
    $homeSource -cnotmatch [regex]::Escape('ReadingChoiceOverlay') -or
    $homeSource -cnotmatch [regex]::Escape('ReadingCountGlyph') -or
    $homeSource -cnotmatch [regex]::Escape('ReadingKindGlyph') -or
    $homeSource -cnotmatch [regex]::Escape('ForEach([1, 3, 6, 0], id: \.self)') -or
    $homeSource -cnotmatch [regex]::Escape('ReadingKindGlyph(kindCount: count, cardWidth: compact ? 38 : 48)') -or
    $homeSource -cnotmatch [regex]::Escape('private struct SixCardReadingKindGlyph') -or
    $homeSource -cnotmatch [regex]::Escape('ForEach(0..<2, id: \.self)') -or
    $homeSource -cnotmatch [regex]::Escape('ForEach(0..<3, id: \.self)') -or
    $homeSource -cnotmatch [regex]::Escape('private struct CustomReadingKindGlyph') -or
    $homeSource -cnotmatch [regex]::Escape('ThreeCardStyleGlyph') -or
    $homeSource -cnotmatch [regex]::Escape('compactSelectorButton') -or
    $homeSource -cnotmatch [regex]::Escape('private func chooseCount') -or
    $homeSource -cnotmatch [regex]::Escape('private func chooseStyle') -or
    $homeSource -cnotmatch [regex]::Escape('stagedCustomSelected = model.selectedCustomSpreadID != nil') -or
    $homeSource -cnotmatch [regex]::Escape('default: selected = stagedCustomSelected') -or
    $homeSource -cnotmatch [regex]::Escape('frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)') -or
    $homeSource -cnotmatch [regex]::Escape('ScrollView') -or
    $homeSource -cnotmatch [regex]::Escape('.accessibilityAddTraits(selected ? .isSelected : [])') -or
    $homeSource -cnotmatch [regex]::Escape('@AccessibilityFocusState private var headingFocused') -or
    $homeSource -cnotmatch [regex]::Escape('@AccessibilityFocusState private var selectorFocused') -or
    $homeSource -cnotmatch [regex]::Escape('.accessibilityFocused($selectorFocused)') -or
    $homeSource -cnotmatch [regex]::Escape('.accessibilityAddTraits(.isModal)') -or
    $homeSource -cnotmatch [regex]::Escape('dismissChoicesAndRestoreFocus()') -or
    $homeSource -cnotmatch [regex]::Escape('let availableDeckHeight = max(size.height - verticalReservation, 0)') -or
    $homeSource -cnotmatch [regex]::Escape('let landscapeVerticalReservation: CGFloat = 76') -or
    $homeSource -cnotmatch [regex]::Escape('let availableDeckHeight = max(size.height - landscapeVerticalReservation, 0)') -or
    $homeSource -cnotmatch [regex]::Escape('let horizontalDeckLimit = max(size.width - 48, 0)') -or
    $homeSource -cnotmatch [regex]::Escape('.padding(.horizontal, protectsGear ? 48 : 0)') -or
    $homeSource -cnotmatch [regex]::Escape('reduceMotion ? CeremonialMotion.reduced : CeremonialMotion.screen') -or
    $homeSource -cnotmatch [regex]::Escape('model.startSelectedPreset()') -or
    $homeSource -cnotmatch [regex]::Escape('Text(AppLocalization.text(stage == .count ? "Choose Your Reading" : "Choose the Style"))') -or
    $homeSource -cnotmatch [regex]::Escape('Text("Tap the deck to begin")') -or
    $homeSource -cnotmatch [regex]::Escape('.accessibilityLabel("Start a Reading")') -or
    $homeSource -match [regex]::Escape('.accessibilityLabel("Complete 78-card tarot deck")')) {
    throw "The current progressive Home selector must keep its top-aligned hero deck, accessibility, overlaid gear, and one deck CTA."
}
if ($homeSource -match '\bList\s*\{|ReadingPresetCarousel|pageIndicator|homeControlClearance' -or
    $homeSource -match 'ScrollView\s*\(\s*\.vertical' -or
    $homeSource -match 'max\(size\.width\s*-.*?,\s*236\)|max\(size\.width\s*\*\s*0\.20,\s*176\)|stage\s*==\s*\.count\s*\?\s*300\s*:\s*390' -or
    $homeSource -match 'min\(count,\s*3\)') {
    throw "A-042 Home must not retain the carousel, pagination, reserved gear clearance, dropdown, or vertical preset list."
}
$hiddenHomeAndGearCount = [regex]::Matches(
    $homeSource,
    [regex]::Escape('.accessibilityHidden(choiceStage != nil)')
).Count
if ($hiddenHomeAndGearCount -lt 2) {
    throw "A-042 selector must hide both Home content and the overlaid Settings control from VoiceOver while modal."
}
$gearOverlay = $homeSource.IndexOf('.overlay(alignment: .topTrailing)')
$gearButton = $homeSource.IndexOf('Button(action: openSettings)', $gearOverlay)
$heroTopAlignment = $homeSource.IndexOf('frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)')
if ($gearOverlay -lt 0 -or $gearButton -le $gearOverlay -or $heroTopAlignment -lt 0 -or
    $homeSource -cnotmatch [regex]::Escape('.disabled(choiceStage != nil)')) {
    throw "Settings must remain a non-reserving top-trailing overlay while Home content is anchored from the top."
}

$readingTableStart = $activeReadSource.IndexOf("private struct ReadingTableView")
$readingTableEnd = $activeReadSource.IndexOf("private enum ReadingMotionAnchor")
$readingTableSource = $activeReadSource.Substring($readingTableStart, $readingTableEnd - $readingTableStart)
$readingContracts = @(
    "ReadingMotionAnchorPreferenceKey",
    "anchorPreference",
    "runShuffleChoreography",
    "private func runPlacementSequence",
    "runFlip(at:",
    "placementOverlay(anchors:",
    "CeremonialPlacementGeometryEffect(",
    "CeremonialFlipFaceModifier(",
    "presentationLocked",
    "scenePhase == .active",
    "CeremonialHaptics.drawn()",
    "visualBaseline = target",
    "model.placeNextCard(at: index)",
    "model.placedCard(at: index)",
    "ReadingVisualSlot(cardID:",
    ".disabled(interactionLocked)",
    "ReadingStageLayoutMetrics.make(",
    "minimumVisibleGap: 14",
    ".padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 10 : 4)",
    ".frame(minHeight: 72)",
    "withTransaction(settleTransaction)",
    "private var landscapeCue",
    "Turn your iPhone sideways to see the cards better.",
    "Tap the deck to shuffle.",
    "Tap an empty position to place the next card, or tap the deck to shuffle again.",
    "Tap any empty position to place the next card.",
    "Tap a card",
    "Tap a position",
    "Tap for meaning",
    "Tap to shuffle",
    "Turn your iPhone sideways to see the cards better.",
    "model.canShuffleDeck",
    "model.hasEmptyPositions",
    ".accessibilityHidden(!shouldShowDeck)",
    "cancelTransientMotion(establishing: visualState)",
    ".frame(width: 44, height: 44)",
    "Reset Reading"
)
foreach ($contract in $readingContracts) {
    if ($readingTableSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-054 reading-table contract is missing: $contract"
    }
}
if ($readingTableSource -match '\bprimaryTitle\b|Button\("Shuffle Deck"|Button\("Draw Card"|Button\("Deal"|Button\("End Reading"|requestEndReading|model\.drawCard\(\)|model\.dealCards\(\)|Tap the deck for another reading') {
    throw "The reading table still contains a duplicate primary shuffle/draw CTA."
}
$landscapeStart = $readingTableSource.IndexOf("private func landscapeContent")
$landscapeEnd = $readingTableSource.IndexOf("private var landscapeHeader", $landscapeStart)
if ($landscapeStart -lt 0 -or $landscapeEnd -le $landscapeStart) {
    throw "The compact A-055 landscape composition is missing."
}
$landscapeSource = $readingTableSource.Substring($landscapeStart, $landscapeEnd - $landscapeStart)
if ($landscapeSource -match '\brailWidth\b|\bstatusText\b|\bactionArea\b|Text\(model\.readingTitle\)' -or
    $landscapeSource -cnotmatch [regex]::Escape(".frame(width: deckWidth, height: deckHeight)")) {
    throw "Landscape must keep only the compact header, shared stage, explicit large deck and short cue."
}
if ($readingTableSource -match 'rotationEffect\(\.degrees\([^\r\n]*placementProgress') {
    throw "Placement rotation may not consume the A-055 minimum visible slot gap."
}
if ($readingTableSource -match [regex]::Escape('.frame(height: 72)')) {
    throw "The portrait reading header must grow for accessibility Dynamic Type instead of using a fixed height."
}
if ($activeReadSource -cnotmatch [regex]::Escape('private static func compactGridLayout(') -or
    $activeReadSource -cnotmatch [regex]::Escape('let resolvedGap = minimumVisibleGap + 0.5') -or
    $activeReadSource -cnotmatch [regex]::Escape('Compact reading geometry must preserve the visible card gap.')) {
    throw "The deterministic A-055 compact collision fallback is missing."
}

# Exercise the deterministic A-055 fail-safe with the reported near-collision case. At the
# smallest authored-layout card width, x=.50/.55 still cannot provide 14 points, so the compact
# row-major presentation must take over without mutating either stored point.
function Get-A055CompactGridTestGeometry {
    param(
        [Parameter(Mandatory = $true)][int]$Count,
        [Parameter(Mandatory = $true)][double]$CanvasWidth,
        [Parameter(Mandatory = $true)][double]$CanvasHeight,
        [Parameter(Mandatory = $true)][double]$MaximumCardWidth,
        [Parameter(Mandatory = $true)][double]$CardAspectRatio,
        [Parameter(Mandatory = $true)][double]$MinimumVisibleGap
    )

    $labelAreaHeight = 34.0
    $resolvedGap = $MinimumVisibleGap + 0.5
    $bestColumns = 1
    $bestRows = $Count
    $bestCardWidth = 0.0
    for ($columns = 1; $columns -le $Count; $columns += 1) {
        $rows = [int][Math]::Ceiling($Count / [double]$columns)
        $horizontalFit = ($CanvasWidth - 8.0 - ([Math]::Max($columns - 1, 0) * $resolvedGap)) / $columns
        $verticalCardFit = (
            $CanvasHeight - 2.0 - ($rows * $labelAreaHeight) -
            ([Math]::Max($rows - 1, 0) * $resolvedGap)
        ) / $rows
        $candidateWidth = [Math]::Min(
            $MaximumCardWidth,
            [Math]::Min($horizontalFit, $verticalCardFit * $CardAspectRatio)
        )
        if ($candidateWidth -gt $bestCardWidth) {
            $bestColumns = $columns
            $bestRows = $rows
            $bestCardWidth = $candidateWidth
        }
    }

    $centers = @()
    $cardHeight = $bestCardWidth / $CardAspectRatio
    $stackHeight = $cardHeight + $labelAreaHeight
    $totalHeight = ($bestRows * $stackHeight) + ([Math]::Max($bestRows - 1, 0) * $resolvedGap)
    $firstY = [Math]::Max(($CanvasHeight - $totalHeight) / 2.0, 0.0) + ($stackHeight / 2.0)
    for ($row = 0; $row -lt $bestRows; $row += 1) {
        $firstIndex = $row * $bestColumns
        $itemsInRow = [Math]::Min($bestColumns, $Count - $firstIndex)
        if ($itemsInRow -le 0) { continue }
        $rowWidth = ($itemsInRow * $bestCardWidth) + ([Math]::Max($itemsInRow - 1, 0) * $resolvedGap)
        $firstX = (($CanvasWidth - $rowWidth) / 2.0) + ($bestCardWidth / 2.0)
        for ($column = 0; $column -lt $itemsInRow; $column += 1) {
            $centers += [PSCustomObject]@{
                X = $firstX + ($column * ($bestCardWidth + $resolvedGap))
                Y = $firstY + ($row * ($stackHeight + $resolvedGap))
            }
        }
    }

    [PSCustomObject]@{
        CardWidth = $bestCardWidth
        CardHeight = $cardHeight
        Centers = $centers
    }
}

$a055NearPoints = @(0.50, 0.55)
$a055TestCanvasWidth = 481.0
$a055AuthoredMinimumWidth = 16.0
$a055AuthoredGap = (($a055NearPoints[1] - $a055NearPoints[0]) * $a055TestCanvasWidth) - $a055AuthoredMinimumWidth
if ($a055AuthoredGap -ge 14.0) {
    throw "The A-055 x=.50/.55 fixture no longer exercises the compact collision fallback."
}
$a055Compact = Get-A055CompactGridTestGeometry `
    -Count 2 `
    -CanvasWidth $a055TestCanvasWidth `
    -CanvasHeight 277.0 `
    -MaximumCardWidth 190.0 `
    -CardAspectRatio (2.0 / 3.0) `
    -MinimumVisibleGap 14.0
if ($a055Compact.Centers.Count -ne 2) {
    throw "The A-055 compact collision fixture did not preserve both custom positions."
}
$a055ResolvedHorizontalGap = [Math]::Abs(
    $a055Compact.Centers[1].X - $a055Compact.Centers[0].X
) - $a055Compact.CardWidth
$a055ResolvedVerticalGap = [Math]::Abs(
    $a055Compact.Centers[1].Y - $a055Compact.Centers[0].Y
) - $a055Compact.CardHeight
if ($a055ResolvedHorizontalGap -lt (14.0 - 0.001) -and
    $a055ResolvedVerticalGap -lt (14.0 - 0.001)) {
    throw "The A-055 compact collision fixture overlaps or provides less than 14 points of visible gap."
}
if ($readingTableSource -match 'sin\(\.pi \* placementProgress\)|let firstHalf = min\(progress \* 2') {
    throw "Placement and two-sided flip progress must interpolate inside animatable effects."
}
$normalShuffleStart = $readingTableSource.IndexOf("withAnimation(CeremonialMotion.cut)")
$shuffleSettle = $readingTableSource.IndexOf("withAnimation(CeremonialMotion.shuffleSettle)", $normalShuffleStart)
$shuffleSettleWait = $readingTableSource.IndexOf("Task.sleep(nanoseconds: 190_000_000)", $shuffleSettle)
$shuffleFinish = $readingTableSource.IndexOf("finishPresentation(token)", $shuffleSettleWait)
$shuffleHaptic = $readingTableSource.IndexOf("CeremonialHaptics.shuffled()", $shuffleFinish)
if ($normalShuffleStart -lt 0 -or $shuffleSettle -lt 0 -or $shuffleSettleWait -lt 0 -or
    $shuffleFinish -lt 0 -or $shuffleHaptic -lt 0) {
    throw "Shuffle haptics must follow the complete fixed-duration settle phase."
}
$hapticDraw = $readingTableSource.IndexOf("CeremonialHaptics.drawn()")
$placementLanding = $readingTableSource.IndexOf("visualBaseline = target", $readingTableSource.IndexOf("private func runPlacementSequence"))
if ($placementLanding -lt 0 -or $hapticDraw -lt 0 -or $hapticDraw -lt $placementLanding) {
    throw "Draw haptics must occur only after the committed placement lands."
}
if ($readSource -cnotmatch [regex]::Escape('model.surface == .table || model.surface == .restoring ? .hidden : .visible') -or
    $shellSource -cnotmatch [regex]::Escape('selectedDestination = .learn') -or
    $shellSource -cnotmatch [regex]::Escape('selectedDestination = .read')) {
    throw "The contextual tab bar must remain hidden on the table, visible in Learn, and hidden again on return."
}

$cardsSourceForMeaning = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Screens/Cards/CardsViews.swift")
if ($cardsSourceForMeaning -cnotmatch [regex]::Escape('AppLocalization.text("Meaning")') -or
    $cardsSourceForMeaning -match [regex]::Escape('Label("Upright"')) {
    throw "Card detail must show a plain Meaning heading, not an orientation pseudo-button."
}
if ($shellSource -cnotmatch [regex]::Escape("appearance.configureWithTransparentBackground()") -or
    $shellSource -cnotmatch [regex]::Escape("appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)") -or
    $shellSource -cnotmatch [regex]::Escape("appearance.backgroundColor = UIColor(CeremonialObsidianTheme.tabBarTint)") -or
    $shellSource -cnotmatch [regex]::Escape("UITabBar.appearance().isTranslucent = true") -or
    $shellSource -cnotmatch [regex]::Escape("UITabBar.appearance().standardAppearance = appearance") -or
    $shellSource -cnotmatch [regex]::Escape("UITabBar.appearance().scrollEdgeAppearance = appearance")) {
    throw "The tab bar must use one stable dark translucent UIKit appearance for standard and scroll-edge states."
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
    "Tap an empty position to place the next card, or tap the deck to shuffle again.",
    "Tap any empty position to place the next card.",
    "Shuffles all 78 cards again",
    "Places the next card here face down",
    "Meaning"
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
if ($favoritesSource -match 'isExcludedFromBackup|createDirectory\s*\(') {
    throw "FavoriteCardsStore must rely on the single app-composition storage preparation point."
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
    'fallbackVersion = "0.7.2"'
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
$requiredLearnContracts = @(
    'Text("A simple way to read for yourself")',
    'FoundationArticleRow(',
    'Text("BEGIN HERE")',
    'TutorialsPortalRow()',
    'struct ReadingTutorialsView',
    'Text("Reading Tutorials")',
    'TutorialMethodRow(article: article)',
    'readingIllustration(labels: positionLabels(for: readingPresetID))',
    'ThreeCardSpread.open.positionTitle',
    'ThreeCardSpread.freeform.positionTitle',
    "article.readingPresetID",
    "Try This Reading",
    "startReading(readingPresetID)",
    "returnToReading == nil",
    "Previous Tutorial",
    "Next Tutorial",
    "Back to Reading",
    "openTutorial(destination.id)",
    "Example card %d of %d, face down",
    "Selects this reading preset or returns to the current reading"
)
foreach ($contract in $requiredLearnContracts) {
    if ($learnSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-034 Learn integration contract is missing: $contract"
    }
}
if ($shellSource -cnotmatch [regex]::Escape('tutorialReturnsToReading = activeReading') -or
    $shellSource -cnotmatch [regex]::Escape('? [.article(articleID)]') -or
    $shellSource -cnotmatch [regex]::Escape('previousTutorial: previousTutorial') -or
    $shellSource -cnotmatch [regex]::Escape('nextTutorial: nextTutorial') -or
    $shellSource -cnotmatch [regex]::Escape('selectedDestination = .read') -or
    $readingTableSource -cnotmatch [regex]::Escape('model.activeTutorialArticleID') -or
    $readingTableSource -cnotmatch [regex]::Escape('openReadingTutorial(model.activeTutorialArticleID)')) {
    throw "Active Reading tutorial navigation must preserve the session, browse all methods, and return directly to Read."
}
if ($learnSource -match 'Try a Three-Card Reading|article\.id\s*==\s*"read-three-cards"|\bisFirst\b' -or
    $contentSource -cnotmatch [regex]::Escape('article.sections.count == 3')) {
    throw "Learn must keep the approved foundations/tutorial hierarchy and exactly three concise sections per article."
}
$artworkSource = Get-Content -Raw -LiteralPath (Join-Path $appRoot "Components/TarotArtworkView.swift")
if ($readSource -match '\.font\(\.system\(size:\s*50\b' -or
    $artworkSource -cnotmatch [regex]::Escape("lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)")) {
    throw "Read or artwork Dynamic Type adaptations are missing."
}
$requiredReadCopy = @(
    "Start a Reading",
    "Reading preset",
    "Selects this reading preset",
    "Choose Your Reading",
    "Choose the Style",
    "Opens visual reading choices",
    "Closes reading choices without changing the selection",
    "Returns to one or three card choices",
    "Selects this reading type",
    "Opens five visual three-card styles",
    "Learn how to use %@",
    "Opens the matching reading tutorial without changing your selection",
    "Reset Reading",
    "Clears the cards and keeps this reading preset",
    "Ends this reading and returns to Read home",
    "About This Reading"
)
foreach ($copy in $requiredReadCopy) {
    if ($activeReadSource -cnotmatch [regex]::Escape($copy)) {
        throw "Required approved Read copy is missing: $copy"
    }
}

$informationStart = $activeReadSource.IndexOf('private func showCountInformation')
$selectionStart = $activeReadSource.IndexOf('private func chooseStyle')
$informationEnd = $activeReadSource.IndexOf('private func cancelChoices', $informationStart)
if ($informationStart -lt 0 -or $selectionStart -lt 0 -or $informationEnd -le $informationStart) {
    throw "A-048 information navigation source boundaries could not be validated."
}
$informationSource = $activeReadSource.Substring($informationStart, $informationEnd - $informationStart)
if ($informationSource -match 'selectPreset|preferences\.|startSelectedPreset|startPreset|chooseStyle\(' -or
    $activeReadSource -cnotmatch [regex]::Escape('openReadingTutorial(preset.tutorialArticleID)')) {
    throw "Selector information actions must open Learn without selecting, persisting, or starting a preset."
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

if ($InternalTestFlightGate) {
    if ($verifiedRecords.Count -ne 78 -or [int]$evidence.failureCount -ne 0) {
        throw "Internal TestFlight artwork gate blocked: requires 78/78 intact verified candidates and zero failures; found $($verifiedRecords.Count)/78 with $($evidence.failureCount) failures."
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
        throw "Internal TestFlight artwork gate blocked: runtime image-set allowlist differs from 78 canonical faces plus ceremonial-card-back. $($details -join '; ')"
    }
    if ($evidence.candidateOnly -ne $true -or
        $evidence.finalAsset -ne $false -or
        $evidence.distributionApproved -ne $false -or
        [string]$evidence.territorialRightsReviewStatus -cne "pending" -or
        @($verifiedRecords | Where-Object {
            $_.finalAsset -ne $false -or
            $_.distributionApproved -ne $false -or
            [string]$_.territorialRightsReviewStatus -cne "pending"
        }).Count -gt 0) {
        throw "Internal TestFlight artwork gate blocked: candidates must remain explicitly non-final, non-distribution-approved, and territorially pending."
    }

    Write-Host "Validated INTERNAL-ONLY TestFlight artwork gate: 78/78 candidates are intact and the public ReleaseGate remains intentionally unsatisfied."
    exit 0
}

$placeholderCount = 78 - $verifiedRecords.Count
Write-Host "Validated internal app snapshot 0.7.2 (1): English/Spanish UI and content, Three Cards first-install default with persisted-selection and restoration priority, exact 2x3 Six Cards selector glyph, seven built-in tutorials plus Create Your Own Spread, cited Six-Card Guidance, local custom spreads, atomic arbitrary slot placement, restoration, accessibility, 78 cards, approved visual hashes, scope boundaries, $($verifiedRecords.Count)/78 bundled hash-verified provisional artwork candidates, and $placeholderCount explicit placeholders. This snapshot is not release-ready."
