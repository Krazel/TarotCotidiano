[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$educationRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$canonicalPath = Join-Path (Split-Path -Parent $educationRoot) 'tarot-deck.v1.json'
$meaningsPath = Join-Path $educationRoot 'card-meanings.v1.json'
$guidePath = Join-Path $educationRoot 'beginner-guide.v1.json'
$errors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError {
    param([string]$Message)
    $script:errors.Add($Message)
}

function Test-TextLength {
    param(
        [string]$Value,
        [int]$Minimum,
        [int]$Maximum,
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        Add-ValidationError "$Label is empty."
        return
    }

    if ($Value.Length -lt $Minimum -or $Value.Length -gt $Maximum) {
        Add-ValidationError "$Label length $($Value.Length) is outside $Minimum-$Maximum characters."
    }
}

function Test-EnglishEditorialText {
    param([string]$Value, [string]$Label)

    if ($Value -match '[^\x09\x0A\x0D\x20-\x7E]') {
        Add-ValidationError "$Label contains non-ASCII text; production English copy must use the approved character set."
    }

    $excludedPatterns = @(
        '(?i)\breversed\b',
        '(?i)\bhoroscope\b',
        '(?i)\bzodiac\b',
        '(?i)\bartificial intelligence\b',
        '(?i)\bchatbot\b',
        '(?i)\bdiagnos(?:e|es|ed|ing|is)\b',
        '(?i)\bmedical advice\b',
        '(?i)\blegal advice\b',
        '(?i)\bfinancial advice\b',
        '(?i)\bwill definitely\b',
        '(?i)\bguarantees?\b'
    )

    foreach ($pattern in $excludedPatterns) {
        if ($Value -match $pattern) {
            Add-ValidationError "$Label contains excluded or certainty-based language matching '$pattern'."
        }
    }
}

function Test-ArtworkDescription {
    param([string]$Value, [string]$Label)

    Test-TextLength -Value $Value -Minimum 70 -Maximum 260 -Label $Label
    Test-EnglishEditorialText -Value $Value -Label $Label

    if (-not [string]::IsNullOrWhiteSpace($Value)) {
        $sentenceCount = [regex]::Matches($Value, '[.!?](?:\s|$)').Count
        if ($sentenceCount -lt 1 -or $sentenceCount -gt 2) {
            Add-ValidationError "$Label must contain one or two complete sentences."
        }

        $interpretivePatterns = @(
            '(?i)\bsymboli[sz](?:e|es|ed|ing)\b',
            '(?i)\brepresents?\b',
            '(?i)\bsuggests?\b',
            '(?i)\bindicates?\b',
            '(?i)\bforetells?\b',
            '(?i)\bpredicts?\b'
        )
        foreach ($pattern in $interpretivePatterns) {
            if ($Value -match $pattern) {
                Add-ValidationError "$Label contains interpretive language matching '$pattern'."
            }
        }
    }
}

foreach ($requiredPath in @($canonicalPath, $meaningsPath, $guidePath)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        Add-ValidationError "Missing required file: $requiredPath"
    }
}

if ($errors.Count -eq 0) {
    try { $canonical = Get-Content -Raw -LiteralPath $canonicalPath | ConvertFrom-Json }
    catch { Add-ValidationError "Canonical manifest is invalid JSON: $($_.Exception.Message)" }
    try { $meanings = Get-Content -Raw -LiteralPath $meaningsPath | ConvertFrom-Json }
    catch { Add-ValidationError "Card meanings are invalid JSON: $($_.Exception.Message)" }
    try { $guide = Get-Content -Raw -LiteralPath $guidePath | ConvertFrom-Json }
    catch { Add-ValidationError "Beginner guide is invalid JSON: $($_.Exception.Message)" }
}

if ($null -ne $meanings) {
    if ($meanings.schemaVersion -ne 1) { Add-ValidationError 'Card meanings schemaVersion must be 1.' }
    if ($meanings.language -ne 'en') { Add-ValidationError 'Card meanings language must be en.' }
    if ($meanings.orientationPolicy -ne 'uprightOnly') { Add-ValidationError 'Card meanings orientationPolicy must be uprightOnly.' }
    if ($meanings.cardCount -ne 78) { Add-ValidationError 'Card meanings cardCount must be 78.' }

    $meaningFields = @($meanings.cards[0].PSObject.Properties.Name)
    if ($meaningFields -contains 'reversed' -or $meaningFields -contains 'reversedMeaning') {
        Add-ValidationError 'Reversed meaning fields are not allowed.'
    }

    if (@($meanings.cards).Count -ne 78) {
        Add-ValidationError "Expected 78 meaning records; found $(@($meanings.cards).Count)."
    }

    $artworkDescriptions = @($meanings.cards.artworkDescription)
    if ($artworkDescriptions.Count -ne 78) {
        Add-ValidationError "Expected 78 artwork descriptions; found $($artworkDescriptions.Count)."
    }
    if (@($artworkDescriptions | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique).Count -ne 78) {
        Add-ValidationError 'Artwork descriptions must be non-empty and unique across all 78 cards.'
    }

    $duplicateIDs = @($meanings.cards | Group-Object cardID | Where-Object Count -ne 1)
    if ($duplicateIDs.Count -gt 0) {
        Add-ValidationError "Duplicate or invalid cardID values: $($duplicateIDs.Name -join ', ')."
    }

    $count = [Math]::Min(@($canonical.cards).Count, @($meanings.cards).Count)
    for ($index = 0; $index -lt $count; $index++) {
        $source = $canonical.cards[$index]
        $entry = $meanings.cards[$index]
        $label = "cards[$index]"

        $allowedFields = @('cardID', 'canonicalName', 'keywords', 'uprightMeaning', 'inAReading', 'artworkDescription')
        foreach ($field in @($entry.PSObject.Properties.Name)) {
            if ($field -notin $allowedFields) { Add-ValidationError "$label has unexpected field '$field'." }
        }
        foreach ($field in $allowedFields) {
            if ($field -notin @($entry.PSObject.Properties.Name)) { Add-ValidationError "$label is missing '$field'." }
        }

        if ($entry.cardID -cne $source.id) { Add-ValidationError "$label cardID '$($entry.cardID)' does not match '$($source.id)'." }
        if ($entry.canonicalName -cne $source.name) { Add-ValidationError "$label canonicalName '$($entry.canonicalName)' does not match '$($source.name)'." }

        $keywords = @($entry.keywords)
        if ($keywords.Count -lt 3 -or $keywords.Count -gt 5) {
            Add-ValidationError "$label must have 3-5 keywords; found $($keywords.Count)."
        }
        if (@($keywords | Sort-Object -Unique).Count -ne $keywords.Count) {
            Add-ValidationError "$label contains duplicate keywords."
        }
        foreach ($keyword in $keywords) {
            Test-TextLength -Value $keyword -Minimum 2 -Maximum 32 -Label "$label keyword"
            Test-EnglishEditorialText -Value $keyword -Label "$label keyword"
        }

        Test-TextLength -Value $entry.uprightMeaning -Minimum 80 -Maximum 240 -Label "$label uprightMeaning"
        Test-TextLength -Value $entry.inAReading -Minimum 60 -Maximum 220 -Label "$label inAReading"
        Test-ArtworkDescription -Value $entry.artworkDescription -Label "$label artworkDescription"
        Test-EnglishEditorialText -Value $entry.canonicalName -Label "$label canonicalName"
        Test-EnglishEditorialText -Value $entry.uprightMeaning -Label "$label uprightMeaning"
        Test-EnglishEditorialText -Value $entry.inAReading -Label "$label inAReading"
    }
}

if ($null -ne $guide) {
    if ($guide.schemaVersion -ne 1) { Add-ValidationError 'Guide schemaVersion must be 1.' }
    if ($guide.language -ne 'en') { Add-ValidationError 'Guide language must be en.' }
    Test-TextLength -Value $guide.title -Minimum 5 -Maximum 60 -Label 'Guide title'
    Test-TextLength -Value $guide.introduction -Minimum 100 -Maximum 400 -Label 'Guide introduction'

    $expectedArticles = @(
        @{ id = 'prepare-a-reading'; title = 'Prepare a Reading'; preset = $null },
        @{ id = 'one-card-focus'; title = 'One Card Focus'; preset = 'oneCard' },
        @{ id = 'past-present-possible-direction'; title = 'Past, Present, Possible Direction'; preset = 'pastPresentFuture' },
        @{ id = 'situation-challenge-guidance'; title = 'Situation, Challenge, Guidance'; preset = 'situationChallengeAdvice' },
        @{ id = 'you-other-person-connection'; title = 'You, Other Person, Connection'; preset = 'relationship' },
        @{ id = 'yes-or-no-with-context'; title = 'A Yes-or-No Question, With Context'; preset = 'open' },
        @{ id = 'open-three-cards'; title = 'Open Three Cards'; preset = 'open' },
        @{ id = 'read-symbols-whole-spread'; title = 'Read Symbols and the Whole Spread'; preset = $null }
    )

    $rootFields = @($guide.PSObject.Properties.Name)
    $allowedRootFields = @('schemaVersion', 'contentVersion', 'language', 'title', 'introduction', 'articles')
    foreach ($field in $rootFields) {
        if ($field -notin $allowedRootFields) { Add-ValidationError "Guide has unexpected root field '$field'." }
    }

    if (@($guide.articles).Count -ne $expectedArticles.Count) {
        Add-ValidationError "Guide must have exactly $($expectedArticles.Count) articles."
    }

    $articleCount = [Math]::Min(@($guide.articles).Count, $expectedArticles.Count)
    for ($index = 0; $index -lt $articleCount; $index++) {
        $article = $guide.articles[$index]
        $expected = $expectedArticles[$index]
        $label = "guide.articles[$index]"
        $allowedArticleFields = @('id', 'order', 'title', 'summary', 'readingPresetID', 'sections')
        foreach ($field in @($article.PSObject.Properties.Name)) {
            if ($field -notin $allowedArticleFields) { Add-ValidationError "$label has unexpected field '$field'." }
        }
        foreach ($field in $allowedArticleFields) {
            if ($field -notin @($article.PSObject.Properties.Name)) { Add-ValidationError "$label is missing '$field'." }
        }

        if ($article.id -cne $expected.id) { Add-ValidationError "$label has unexpected id '$($article.id)'; expected '$($expected.id)'." }
        if ($article.title -cne $expected.title) { Add-ValidationError "$label has unexpected title '$($article.title)'; expected '$($expected.title)'." }
        if ($article.order -ne ($index + 1)) { Add-ValidationError "$label order must be $($index + 1)." }
        if ($null -eq $expected.preset) {
            if ($null -ne $article.readingPresetID) { Add-ValidationError "$label must not launch a reading preset." }
        }
        elseif ([string]$article.readingPresetID -cne [string]$expected.preset) {
            Add-ValidationError "$label must map to reading preset '$($expected.preset)'."
        }
        Test-TextLength -Value $article.summary -Minimum 40 -Maximum 180 -Label "$label summary"
        Test-EnglishEditorialText -Value $article.title -Label "$label title"
        Test-EnglishEditorialText -Value $article.summary -Label "$label summary"

        if (@($article.sections).Count -ne 4) {
            Add-ValidationError "$label must contain exactly four ordered sections covering purpose/positions, steps, synthesis, and limits."
        }

        for ($sectionIndex = 0; $sectionIndex -lt @($article.sections).Count; $sectionIndex++) {
            $section = $article.sections[$sectionIndex]
            $sectionLabel = "$label.sections[$sectionIndex]"
            $sectionFields = @($section.PSObject.Properties.Name)
            if (@($sectionFields).Count -ne 2 -or 'heading' -notin $sectionFields -or 'body' -notin $sectionFields) {
                Add-ValidationError "$sectionLabel must contain only heading and body."
            }
            Test-TextLength -Value $section.heading -Minimum 4 -Maximum 80 -Label "$sectionLabel heading"
            Test-TextLength -Value $section.body -Minimum 100 -Maximum 600 -Label "$sectionLabel body"
            Test-EnglishEditorialText -Value $section.heading -Label "$sectionLabel heading"
            Test-EnglishEditorialText -Value $section.body -Label "$sectionLabel body"
        }
    }

    Test-EnglishEditorialText -Value $guide.title -Label 'Guide title'
    Test-EnglishEditorialText -Value $guide.introduction -Label 'Guide introduction'

    $yesNoArticle = @($guide.articles | Where-Object id -CEQ 'yes-or-no-with-context')[0]
    $yesNoText = @($yesNoArticle.sections | ForEach-Object { [string]$_.body }) -join ' '
    foreach ($requiredYesNoCopy in @(
        'What supports a yes',
        'What supports a no or a pause',
        'What to consider before deciding',
        'Open Three Cards',
        'leans yes if',
        'leans no or not yet because',
        'unclear - more information is needed',
        'does not classify the cards or calculate a verdict'
    )) {
        if (-not $yesNoText.Contains($requiredYesNoCopy)) {
            Add-ValidationError "Yes-or-no tutorial is missing required context: $requiredYesNoCopy"
        }
    }
    if ($yesNoText -match '(?i)universal yes or no values?[^.]*assign|automatic verdict|draw again until') {
        Add-ValidationError 'Yes-or-no tutorial introduces card classification, an automatic verdict, or answer-seeking redraws.'
    }
}

if ($errors.Count -gt 0) {
    Write-Error ("Education content validation failed:`n - " + ($errors -join "`n - "))
    exit 1
}

Write-Output 'Education content validation passed.'
Write-Output 'Canonical card IDs and names: 78/78 exact and ordered.'
Write-Output 'Upright meanings and unique artwork descriptions: 78/78; practical tutorials: 8/8; language: en.'
exit 0
