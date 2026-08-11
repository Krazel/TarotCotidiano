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
if ($guide.articles.Count -ne 8) { throw "Guide must contain 8 tutorials." }
if ($spanishCopy.language -cne "es" -or $spanishCopy.cards.Count -ne 78) {
    throw "Spanish card copy must contain exactly 78 records."
}
if ($spanishMeanings.language -cne "es" -or $spanishMeanings.cards.Count -ne 78) {
    throw "Spanish meanings must contain exactly 78 records."
}
if ($spanishGuide.language -cne "es" -or $spanishGuide.articles.Count -ne 8) {
    throw "Spanish guide must contain exactly 8 tutorials."
}
$expectedGuideIDs = @(
    "prepare-a-reading",
    "one-card-focus",
    "past-present-possible-direction",
    "situation-challenge-guidance",
    "you-other-person-connection",
    "yes-or-no-with-context",
    "open-three-cards",
    "read-symbols-whole-spread"
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
    "selectedPreset: ReadingPreset = .pastPresentFuture",
    "startSelectedPreset",
    "func leaveTable()",
    "func resetReading()",
    "canPrepareAnotherReading"
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
$resetReady = $readModelSource.IndexOf("try self.continuityStore.save(.ready(layout, spread: currentSpread))", $resetSessionClear)
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
    'MARKETING_VERSION = 0.2.2;',
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
if ([regex]::Matches($project, [regex]::Escape('MARKETING_VERSION = 0.2.2;')).Count -ne 2 -or
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
    $activeReadSource -cnotmatch [regex]::Escape("let railWidth = min(max(size.width * 0.22, 154), 200)") -or
    $activeReadSource -cnotmatch [regex]::Escape("let groupWidth = cardWidth * count + gap * max(count - 1, 0)")) {
    throw "The progressive visual reading selector or the approved large landscape table is missing."
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
    $homeSource -cnotmatch [regex]::Escape('ThreeCardStyleGlyph') -or
    $homeSource -cnotmatch [regex]::Escape('compactSelectorButton') -or
    $homeSource -cnotmatch [regex]::Escape('private func chooseCount') -or
    $homeSource -cnotmatch [regex]::Escape('private func chooseStyle') -or
    $homeSource -cnotmatch [regex]::Escape('stagedPreset = model.selectedPreset') -or
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
    throw "V-058-V-063 Home must keep its top-aligned hero deck, progressive visual selector, accessibility, overlaid gear, and one deck CTA."
}
if ($homeSource -match '\bMenu\s*\{|\bList\s*\{|ReadingPresetCarousel|pageIndicator|homeControlClearance|DragGesture\s*\(' -or
    $homeSource -match 'ScrollView\s*\(\s*\.vertical' -or
    $homeSource -match 'max\(size\.width\s*-.*?,\s*236\)|max\(size\.width\s*\*\s*0\.20,\s*176\)|stage\s*==\s*\.count\s*\?\s*300\s*:\s*390') {
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
    "Tap the deck to draw.",
    "Tap the deck for another reading.",
    "model.canPrepareAnotherReading",
    "model.resetReading()",
    "cancelTransientMotion(establishing: visualState)",
    ".frame(width: 44, height: 44)",
    "Reset Reading"
)
foreach ($contract in $readingContracts) {
    if ($readingTableSource -cnotmatch [regex]::Escape($contract)) {
        throw "V-048 reading-table contract is missing: $contract"
    }
}
if ($readingTableSource -match '\bprimaryTitle\b|Button\("Shuffle Deck"|Button\("Draw Card"|Button\("End Reading"|requestEndReading') {
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
    'fallbackVersion = "0.2.2"'
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
    "article.readingPresetID",
    "Try This Reading",
    "startReading(readingPresetID)",
    "Example card %d of %d, face down",
    "Selects this reading preset or returns to the current reading"
)
foreach ($contract in $requiredLearnContracts) {
    if ($learnSource -cnotmatch [regex]::Escape($contract)) {
        throw "A-034 Learn integration contract is missing: $contract"
    }
}
if ($learnSource -match 'Try a Three-Card Reading|article\.id\s*==\s*"read-three-cards"') {
    throw "Learn still contains the retired generic three-card tutorial CTA."
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
    "Selects one card",
    "Opens four visual three-card styles",
    "Reset Reading",
    "Clears the cards and keeps this reading preset",
    "Ends this reading and returns to Read home",
    "Complete deck, ready for another reading",
    "Starts another reading with the same preset",
    "Tap the deck for another reading."
)
foreach ($copy in $requiredReadCopy) {
    if ($activeReadSource -cnotmatch [regex]::Escape($copy)) {
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
Write-Host "Validated internal app snapshot 0.2.2 (1): owner-selected opaque sRGB AppIcon D, atomic English/Spanish selection, complete localized UI/content and printf parity, V-058-V-063 progressive visual selector, exact table restoration, transactional Back/reset, quick restart, centered portrait and large landscape tables, V-048 post-commit motion/accessibility contracts, local atomic favorites, 78 cards and 8 practical tutorials per language, approved visual hashes, scope boundaries, $($verifiedRecords.Count)/78 bundled hash-verified provisional artwork candidates, and $placeholderCount explicit placeholders. This snapshot is not release-ready."
