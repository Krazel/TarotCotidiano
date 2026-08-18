[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$localizationRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$contentRoot = Split-Path -Parent $localizationRoot
$deckPath = Join-Path $contentRoot 'tarot-deck.v1.json'
$copyPath = Join-Path $localizationRoot 'card-copy.es.v1.json'
$meaningsPath = Join-Path $localizationRoot 'card-meanings.es.v1.json'
$guidePath = Join-Path $localizationRoot 'beginner-guide.es.v1.json'

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Read-StrictUtf8Json {
    param([string]$Path)

    Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) "Missing required file: $Path"
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)

    try {
        $text = $strictUtf8.GetString($bytes)
    }
    catch {
        throw "File is not valid UTF-8: $Path"
    }

    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) {
        $text = $text.Substring(1)
    }

    try {
        return $text | ConvertFrom-Json
    }
    catch {
        throw "File is not valid JSON: $Path`n$($_.Exception.Message)"
    }
}

function Assert-Text {
    param(
        [object]$Value,
        [string]$Field
    )

    Assert-True ($null -ne $Value) "$Field is missing."
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$Value)) "$Field is empty."
}

function Assert-Unique {
    param(
        [object[]]$Values,
        [string]$Field
    )

    $duplicates = @($Values | Group-Object | Where-Object { $_.Count -gt 1 })
    Assert-True ($duplicates.Count -eq 0) "$Field contains duplicates: $($duplicates.Name -join ', ')"
}

$deck = Read-StrictUtf8Json $deckPath
$copy = Read-StrictUtf8Json $copyPath
$meanings = Read-StrictUtf8Json $meaningsPath
$guide = Read-StrictUtf8Json $guidePath

$expectedCards = @($deck.cards | Sort-Object order)
Assert-True ($expectedCards.Count -eq 78) 'The canonical deck must contain exactly 78 cards.'

$majorNames = @{
    'major-00-the-fool' = 'El Loco'
    'major-01-the-magician' = 'El Mago'
    'major-02-the-high-priestess' = 'La Sacerdotisa'
    'major-03-the-empress' = 'La Emperatriz'
    'major-04-the-emperor' = 'El Emperador'
    'major-05-the-hierophant' = 'El Hierofante'
    'major-06-the-lovers' = 'Los Enamorados'
    'major-07-the-chariot' = 'El Carro'
    'major-08-strength' = 'La Fuerza'
    'major-09-the-hermit' = "El Ermita$([char]0x00F1)o"
    'major-10-wheel-of-fortune' = 'La Rueda de la Fortuna'
    'major-11-justice' = 'La Justicia'
    'major-12-the-hanged-man' = 'El Colgado'
    'major-13-death' = 'La Muerte'
    'major-14-temperance' = 'La Templanza'
    'major-15-the-devil' = 'El Diablo'
    'major-16-the-tower' = 'La Torre'
    'major-17-the-star' = 'La Estrella'
    'major-18-the-moon' = 'La Luna'
    'major-19-the-sun' = 'El Sol'
    'major-20-judgement' = 'El Juicio'
    'major-21-the-world' = 'El Mundo'
}

$rankNames = @{
    'ace' = 'As'
    'two' = 'Dos'
    'three' = 'Tres'
    'four' = 'Cuatro'
    'five' = 'Cinco'
    'six' = 'Seis'
    'seven' = 'Siete'
    'eight' = 'Ocho'
    'nine' = 'Nueve'
    'ten' = 'Diez'
    'page' = 'Sota'
    'knight' = 'Caballero'
    'queen' = 'Reina'
    'king' = 'Rey'
}

$suitNames = @{
    'wands' = 'Bastos'
    'cups' = 'Copas'
    'swords' = 'Espadas'
    'pentacles' = 'Oros'
}

Assert-True ([int]$copy.schemaVersion -eq 1) 'card-copy schemaVersion must be 1.'
Assert-True ([string]$copy.language -eq 'es') 'card-copy language must be es.'
Assert-True ([int]$copy.cardCount -eq 78) 'card-copy cardCount must be 78.'
Assert-True (@($copy.cards).Count -eq 78) 'card-copy must contain exactly 78 cards.'

Assert-True ([int]$meanings.schemaVersion -eq 1) 'card-meanings schemaVersion must be 1.'
Assert-True ([string]$meanings.language -eq 'es') 'card-meanings language must be es.'
Assert-True ([string]$meanings.orientationPolicy -eq 'uprightOnly') 'Spanish meanings must remain uprightOnly.'
Assert-True ([int]$meanings.cardCount -eq 78) 'card-meanings cardCount must be 78.'
Assert-True (@($meanings.cards).Count -eq 78) 'card-meanings must contain exactly 78 cards.'

$userFacingText = New-Object System.Collections.Generic.List[string]
$artworkDescriptions = New-Object System.Collections.Generic.List[string]

for ($index = 0; $index -lt 78; $index++) {
    $deckCard = $expectedCards[$index]
    $copyCard = @($copy.cards)[$index]
    $meaningCard = @($meanings.cards)[$index]

    $expectedName = if ([string]$deckCard.arcana -eq 'major') {
        [string]$majorNames[[string]$deckCard.id]
    }
    else {
        '{0} de {1}' -f $rankNames[[string]$deckCard.rank], $suitNames[[string]$deckCard.suit]
    }

    Assert-Text $expectedName "Expected Spanish name at index $index"
    Assert-True ([string]$copyCard.cardID -ceq [string]$deckCard.id) "card-copy ID/order mismatch at index $index."
    Assert-True ([string]$meaningCard.cardID -ceq [string]$deckCard.id) "card-meanings ID/order mismatch at index $index."
    Assert-True ([string]$copyCard.name -ceq $expectedName) "Unexpected Spanish name for $($deckCard.id): $($copyCard.name)"
    Assert-True ([string]$meaningCard.canonicalName -ceq $expectedName) "Meaning name mismatch for $($deckCard.id)."

    $arcanaLabel = if ([string]$deckCard.arcana -eq 'major') { 'Arcano Mayor' } else { 'Arcano Menor' }
    $expectedLabel = "$arcanaLabel, $expectedName."
    Assert-True ([string]$copyCard.accessibilityLabel -ceq $expectedLabel) "Accessibility label mismatch for $($deckCard.id)."

    $keywords = @($meaningCard.keywords)
    Assert-True ($keywords.Count -eq 4) "$($deckCard.id) must have exactly four keywords."
    foreach ($keyword in $keywords) {
        Assert-Text $keyword "$($deckCard.id).keywords"
        $userFacingText.Add([string]$keyword)
    }
    Assert-Unique $keywords "$($deckCard.id).keywords"

    foreach ($field in @('uprightMeaning', 'inAReading', 'artworkDescription')) {
        $value = [string]$meaningCard.$field
        Assert-Text $value "$($deckCard.id).$field"
        $userFacingText.Add($value)
    }

    $userFacingText.Add([string]$copyCard.name)
    $userFacingText.Add([string]$copyCard.accessibilityLabel)
    $artworkDescriptions.Add([string]$meaningCard.artworkDescription)
}

Assert-Unique @($copy.cards | ForEach-Object { [string]$_.cardID }) 'card-copy cardID'
Assert-Unique @($copy.cards | ForEach-Object { [string]$_.name }) 'card-copy name'
Assert-Unique @($copy.cards | ForEach-Object { [string]$_.accessibilityLabel }) 'card-copy accessibilityLabel'
Assert-Unique @($meanings.cards | ForEach-Object { [string]$_.cardID }) 'card-meanings cardID'
Assert-Unique $artworkDescriptions.ToArray() 'card-meanings artworkDescription'

Assert-True ([int]$guide.schemaVersion -eq 1) 'beginner-guide schemaVersion must be 1.'
Assert-True ([string]$guide.language -eq 'es') 'beginner-guide language must be es.'
$expectedArticleIDs = @(
    'how-to-read-tarot',
    'shuffle-and-draw',
    'symbols-and-patterns',
    'build-your-interpretation',
    'one-card-focus',
    'past-present-possible-direction',
    'situation-challenge-guidance',
    'you-other-person-connection',
    'yes-or-no-with-context',
    'freeform-reading',
    'six-card-guidance',
    'create-custom-spread'
)
$expectedPresetIDs = @(
    $null,
    $null,
    $null,
    $null,
    'oneCard',
    'pastPresentFuture',
    'situationChallengeAdvice',
    'relationship',
    'open',
    'freeform',
    'sixCardGuidance',
    'customSpread'
)
$articles = @($guide.articles)
Assert-True ($articles.Count -eq 12) 'beginner-guide must contain exactly twelve articles.'
Assert-Text $guide.title 'beginner-guide.title'
Assert-Text $guide.introduction 'beginner-guide.introduction'
$userFacingText.Add([string]$guide.title)
$userFacingText.Add([string]$guide.introduction)

for ($index = 0; $index -lt 12; $index++) {
    $article = $articles[$index]
    Assert-True ([string]$article.id -ceq $expectedArticleIDs[$index]) "Article ID/order mismatch at index $index."
    Assert-True ([int]$article.order -eq ($index + 1)) "Article order mismatch for $($article.id)."
    if ($null -eq $expectedPresetIDs[$index]) {
        Assert-True ($null -eq $article.readingPresetID) "$($article.id) must not launch a reading preset."
    }
    else {
        Assert-True ([string]$article.readingPresetID -ceq [string]$expectedPresetIDs[$index]) "$($article.id) reading preset mismatch."
    }
    Assert-Text $article.title "$($article.id).title"
    Assert-Text $article.summary "$($article.id).summary"
    Assert-True (@($article.sections).Count -eq 3) "$($article.id) must have exactly three concise sections."
    $userFacingText.Add([string]$article.title)
    $userFacingText.Add([string]$article.summary)

    foreach ($section in @($article.sections)) {
        Assert-Text $section.heading "$($article.id).section.heading"
        Assert-Text $section.body "$($article.id).section.body"
        $userFacingText.Add([string]$section.heading)
        $userFacingText.Add([string]$section.body)
    }
}

$yesNoArticle = $articles | Where-Object { $_.id -eq 'yes-or-no-with-context' }
$expectedYesNoHeadings = @(
    ('Carta 1 ' + [char]0x2014 + ' A favor'),
    ('Carta 2 ' + [char]0x2014 + ' En contra'),
    ('Carta 3 ' + [char]0x2014 + ' Destino')
)
Assert-True ((@($yesNoArticle.sections | ForEach-Object { [string]$_.heading }) -join "`n") -ceq ($expectedYesNoHeadings -join "`n")) 'El tutorial Sí/No debe usar la secuencia exacta Carta 1 A favor, Carta 2 En contra, Carta 3 Destino.'
$yesNoText = @(
    [string]$yesNoArticle.title
    [string]$yesNoArticle.summary
    @($yesNoArticle.sections | ForEach-Object { [string]$_.heading; [string]$_.body })
) -join ' '
foreach ($requiredYesNoCopy in @(
    [regex]::Unescape('qu\u00E9 favorece el s\u00ED'),
    [regex]::Unescape('resistencias u obst\u00E1culos que favorecen el no'),
    [regex]::Unescape('qu\u00E9 depara el Destino'),
    'respuesta final considerando las cartas A favor y En contra'
)) {
    Assert-True ($yesNoText.Contains($requiredYesNoCopy)) "Yes-or-no tutorial is missing required context: $requiredYesNoCopy"
}
Assert-True ($yesNoText -notmatch '(?i)\b(resultado|probable|certeza)\b') 'El tutorial Sí/No debe usar Destino sin copy anterior ni disclaimers de certeza.'

$situationArticle = $articles | Where-Object { $_.id -eq 'situation-challenge-guidance' }
$situationText = @(
    [string]$situationArticle.summary
    @($situationArticle.sections | ForEach-Object { [string]$_.heading; [string]$_.body })
) -join ' '
foreach ($requiredSituationCopy in @(
    [regex]::Unescape('entender qu\u00E9 est\u00E1 pasando'),
    [regex]::Unescape('reto que debes afrontar'),
    [regex]::Unescape('aconsejan las cartas')
)) {
    Assert-True ($situationText.Contains($requiredSituationCopy)) "Situation-Challenge-Guidance tutorial is missing its purpose: $requiredSituationCopy"
}

$freeformArticle = $articles | Where-Object { $_.id -eq 'freeform-reading' }
$freeformText = @($freeformArticle.sections | ForEach-Object { [string]$_.body }) -join ' '
foreach ($requiredFreeformCopy in @(
    'sin asignarles funciones fijas',
    'Carta 1, la Carta 2 y la Carta 3'
)) {
    Assert-True ($freeformText.Contains($requiredFreeformCopy)) "Freeform tutorial is missing required context: $requiredFreeformCopy"
}

$sixCardArticle = $articles | Where-Object { $_.id -eq 'six-card-guidance' }
Assert-True ([string]$sixCardArticle.sourceCredit -ceq 'Katalin Jett Koda, Reading Tarot Cards: Divining Our Life Path, Llewellyn Worldwide (2015)') 'Six-card tutorial credit does not match the approved source.'
Assert-True ([string]$sixCardArticle.sourceURL -ceq 'https://www.llewellyn.com/journal/article/2506') 'Six-card tutorial must link to the cited Llewellyn article.'

$tutorialText = @(
    [string]$guide.introduction
    @($articles | ForEach-Object {
        [string]$_.summary
        @($_.sections | ForEach-Object { [string]$_.heading; [string]$_.body })
    })
) -join ' '
$disclaimerPattern = '(?i)\b(oficial|certeza|ciencia|prueba|privacidad|consentimiento|profesional|cualificada|salud|legal|jur[ií]dic[oa]|finanzas|seguridad|predice|inmutable)\b'
Assert-True ($tutorialText -notmatch $disclaimerPattern) 'Tutorial copy contains an editorial disclaimer or tangent instead of only the practical method.'
Assert-True ($tutorialText -notmatch '(?i)significado al derecho') 'Tutorial copy must use the visible heading Significado, not significado al derecho.'

$englishPattern = '(?i)\b(the|and|with|card|reading|question|future|present|past|situation|challenge|guidance|relationship|other person|you)\b'
$predictivePattern = '(?i)\b(ocurrir\u00E1|suceder\u00E1|pasar\u00E1|garantiza|predice|inevitable|inevitablemente)\b|sin duda|certeza absoluta|tienes que'

foreach ($value in $userFacingText) {
    Assert-True ($value -notmatch $englishPattern) "Obvious English copy found in Spanish user-facing text: $value"
    Assert-True ($value -notmatch $predictivePattern) "Strong predictive language found in Spanish user-facing text: $value"
}

Write-Output 'Localization validation passed.'
Write-Output 'Card copy: 78/78 IDs, names and accessibility labels.'
Write-Output 'Card meanings: 78/78 records, upright-only, four keywords each.'
Write-Output 'Foundations: 4/4; practical tutorials: 8/8; seven built-in Read presets plus custom creation mapped, cited six-card method included.'
