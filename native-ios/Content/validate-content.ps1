param(
    [string]$DeckManifestPath = (Join-Path $PSScriptRoot "tarot-deck.v1.json"),
    [string]$ProvenanceManifestPath = (Join-Path $PSScriptRoot "provenance.v2.json"),
    [string]$LocalCandidateManifestPath = (Join-Path $PSScriptRoot "CandidateRWS\local-evidence.v2.json")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$validationErrors = [System.Collections.Generic.List[string]]::new()
$deckManifest = Get-Content -Raw -LiteralPath $DeckManifestPath | ConvertFrom-Json
$provenanceManifest = Get-Content -Raw -LiteralPath $ProvenanceManifestPath | ConvertFrom-Json
$cards = @($deckManifest.cards)
$evidenceRecords = @($provenanceManifest.assetEvidence)

function Add-ValidationError {
    param([string]$Message)
    $validationErrors.Add($Message)
}

function Get-JpegDimensions {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    if ($Bytes.Length -lt 4 -or
        $Bytes[0] -ne 0xFF -or $Bytes[1] -ne 0xD8 -or
        $Bytes[$Bytes.Length - 2] -ne 0xFF -or $Bytes[$Bytes.Length - 1] -ne 0xD9) {
        throw "The file does not have a complete JPEG signature."
    }

    $startOfFrameMarkers = @(0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF)
    $offset = 2

    while ($offset -lt $Bytes.Length) {
        while ($offset -lt $Bytes.Length -and $Bytes[$offset] -eq 0xFF) {
            $offset++
        }
        if ($offset -ge $Bytes.Length) {
            break
        }

        $marker = [int]$Bytes[$offset]
        $offset++

        if ($marker -eq 0xD9) {
            break
        }
        if ($marker -eq 0x01 -or ($marker -ge 0xD0 -and $marker -le 0xD8)) {
            continue
        }
        if ($offset + 1 -ge $Bytes.Length) {
            throw "The JPEG contains a truncated segment length."
        }

        $segmentLength = ([int]$Bytes[$offset] -shl 8) -bor [int]$Bytes[$offset + 1]
        if ($segmentLength -lt 2 -or $offset + $segmentLength -gt $Bytes.Length) {
            throw "The JPEG contains an invalid segment length."
        }

        if ($startOfFrameMarkers -contains $marker) {
            if ($segmentLength -lt 7) {
                throw "The JPEG start-of-frame segment is too short."
            }
            $height = ([int]$Bytes[$offset + 3] -shl 8) -bor [int]$Bytes[$offset + 4]
            $width = ([int]$Bytes[$offset + 5] -shl 8) -bor [int]$Bytes[$offset + 6]
            if ($width -le 0 -or $height -le 0) {
                throw "The JPEG dimensions are invalid."
            }
            return [pscustomobject]@{
                Width = $width
                Height = $height
            }
        }

        $offset += $segmentLength
    }

    throw "The JPEG does not contain a supported start-of-frame segment."
}

if ($deckManifest.schemaVersion -ne 1) { Add-ValidationError "Deck schemaVersion must be 1." }
if ($deckManifest.manifestVersion -ne "1.0.0") { Add-ValidationError "Deck manifestVersion must be 1.0.0." }
if ($deckManifest.language -ne "en") { Add-ValidationError "Deck language must be en." }
if ($deckManifest.orientationPolicy -ne "uprightOnly") { Add-ValidationError "Orientation policy must be uprightOnly." }
if ($deckManifest.cardCount -ne 78 -or $cards.Count -ne 78) { Add-ValidationError "Deck must contain exactly 78 cards." }

$cardIDs = @($cards | ForEach-Object { $_.id })
if (@($cardIDs | Sort-Object -Unique).Count -ne 78) { Add-ValidationError "Every card id must be unique." }

$orders = @($cards | ForEach-Object { [int]$_.order })
if (@($orders | Sort-Object -Unique).Count -ne 78) { Add-ValidationError "Every card order must be unique." }
$expectedOrders = @(0..77)
if (@(Compare-Object $expectedOrders ($orders | Sort-Object)).Count -ne 0) { Add-ValidationError "Card orders must be exactly 0 through 77." }

$majorCards = @($cards | Where-Object { $_.arcana -eq "major" })
$minorCards = @($cards | Where-Object { $_.arcana -eq "minor" })
if ($majorCards.Count -ne 22) { Add-ValidationError "Deck must contain exactly 22 Major Arcana." }
if ($minorCards.Count -ne 56) { Add-ValidationError "Deck must contain exactly 56 Minor Arcana." }

$majorNumbers = @($majorCards | ForEach-Object { [int]$_.majorNumber } | Sort-Object)
if (@(Compare-Object @(0..21) $majorNumbers).Count -ne 0) { Add-ValidationError "Major numbers must be exactly 0 through 21." }
foreach ($card in $majorCards) {
    if ($null -ne $card.suit -or $null -ne $card.rank) {
        Add-ValidationError "Major card $($card.id) must have null suit and rank."
    }
}

$expectedSuits = @("wands", "cups", "swords", "pentacles")
$expectedRanks = @("ace", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "page", "knight", "queen", "king")
foreach ($suit in $expectedSuits) {
    $suitCards = @($minorCards | Where-Object { $_.suit -eq $suit })
    if ($suitCards.Count -ne 14) { Add-ValidationError "Suit $suit must contain exactly 14 cards." }
    $actualRanks = @($suitCards | ForEach-Object { $_.rank } | Sort-Object)
    if (@(Compare-Object ($expectedRanks | Sort-Object) $actualRanks).Count -ne 0) {
        Add-ValidationError "Suit $suit must contain each expected rank exactly once."
    }
}
foreach ($card in $minorCards) {
    if ($null -ne $card.majorNumber) {
        Add-ValidationError "Minor card $($card.id) must have null majorNumber."
    }
    if ($expectedSuits -notcontains $card.suit) {
        Add-ValidationError "Minor card $($card.id) has an invalid suit."
    }
    if ($expectedRanks -notcontains $card.rank) {
        Add-ValidationError "Minor card $($card.id) has an invalid rank."
    }
}

$requiredStringFields = @("id", "name", "arcana", "artworkAsset", "artworkStatus", "accessibilityLabel", "provenanceID")
foreach ($card in $cards) {
    foreach ($field in $requiredStringFields) {
        $value = $card.$field
        if ($null -eq $value -or [string]::IsNullOrWhiteSpace([string]$value)) {
            Add-ValidationError "Card $($card.id) has a missing or empty $field."
        }
    }
}

$provenanceIDs = @($provenanceManifest.records | ForEach-Object { $_.id })
foreach ($card in $cards) {
    if ($provenanceIDs -notcontains $card.provenanceID) {
        Add-ValidationError "Card $($card.id) references unknown provenanceID $($card.provenanceID)."
    }
}

if ($provenanceManifest.schemaVersion -ne 2) { Add-ValidationError "Provenance schemaVersion must be 2." }
if ($provenanceManifest.manifestVersion -ne "2.0.0") { Add-ValidationError "Provenance manifestVersion must be 2.0.0." }
if ($evidenceRecords.Count -ne 78) { Add-ValidationError "Provenance must contain exactly 78 asset evidence records." }

$uniqueEvidenceFields = @(
    "evidenceID",
    "cardID",
    "commonsPageID",
    "descriptionPageURL",
    "originalFileURL",
    "sourceSHA1"
)
foreach ($field in $uniqueEvidenceFields) {
    $values = @($evidenceRecords | ForEach-Object { $_.$field })
    if (@($values | Sort-Object -Unique).Count -ne 78) {
        Add-ValidationError "Every evidence $field must be present and unique."
    }
}

$evidenceCardIDs = @($evidenceRecords | ForEach-Object { $_.cardID } | Sort-Object)
if (@(Compare-Object ($cardIDs | Sort-Object) $evidenceCardIDs).Count -ne 0) {
    Add-ValidationError "Evidence card IDs must map one-to-one to all 78 deck cards."
}

$candidateCardIDs = @("major-17-the-star", "major-18-the-moon", "major-19-the-sun")
foreach ($evidence in $evidenceRecords) {
    $card = $cards | Where-Object { $_.id -eq $evidence.cardID } | Select-Object -First 1
    if ($null -eq $card) {
        Add-ValidationError "Evidence $($evidence.evidenceID) does not map to a deck card."
        continue
    }
    if ($evidence.artworkAsset -ne $card.artworkAsset) {
        Add-ValidationError "Evidence $($evidence.evidenceID) has an artworkAsset mismatch."
    }
    if ($evidence.provenanceID -ne $card.provenanceID) {
        Add-ValidationError "Evidence $($evidence.evidenceID) has a provenanceID mismatch."
    }
    if ($evidence.creator -ne "Pamela Colman Smith" -or $evidence.sourceDate -ne "1910") {
        Add-ValidationError "Evidence $($evidence.evidenceID) has unexpected creator or source date."
    }
    if ([int]$evidence.pixelWidth -le 0 -or [int]$evidence.pixelHeight -le 0 -or [int]$evidence.byteSize -le 0) {
        Add-ValidationError "Evidence $($evidence.evidenceID) has invalid file dimensions or size."
    }
    if ($evidence.mimeType -ne "image/jpeg") {
        Add-ValidationError "Evidence $($evidence.evidenceID) must point to a JPEG source."
    }
    if ($evidence.licenseShortName -ne "Public domain" -or $evidence.licenseCode -ne "pd") {
        Add-ValidationError "Evidence $($evidence.evidenceID) lacks the expected Commons public-domain metadata."
    }
    if (@($evidence.publicDomainMarks) -notcontains "CC-PD-Mark" -or @($evidence.publicDomainMarks) -notcontains "PD-old-80-expired") {
        Add-ValidationError "Evidence $($evidence.evidenceID) lacks the expected public-domain marks."
    }
    if ($candidateCardIDs -contains $evidence.cardID) {
        if ($evidence.downloaded -ne $true -or [string]::IsNullOrWhiteSpace([string]$evidence.localSHA256)) {
            Add-ValidationError "Candidate evidence $($evidence.evidenceID) must record its controlled local download and SHA-256."
        }
        if ($evidence.localIntegrityStatus -ne "sha1-dimensions-mime-verified") {
            Add-ValidationError "Candidate evidence $($evidence.evidenceID) must record successful source integrity checks."
        }
        if ($evidence.pixelReviewStatus -ne "source-file-integrity-verified-final-art-review-pending") {
            Add-ValidationError "Candidate evidence $($evidence.evidenceID) must remain pending final-art review."
        }
    } else {
        if ($evidence.downloaded -ne $false -or $null -ne $evidence.localSHA256) {
            Add-ValidationError "Non-candidate evidence $($evidence.evidenceID) must remain metadata-only."
        }
        if ($evidence.pixelReviewStatus -ne "not-reviewed-file-not-downloaded") {
            Add-ValidationError "Non-candidate evidence $($evidence.evidenceID) must remain pending file review."
        }
    }
    if ($evidence.territorialRightsReviewStatus -ne "pending" -or $evidence.distributionApproved -ne $false) {
        Add-ValidationError "Evidence $($evidence.evidenceID) must remain territorially pending and not distribution-approved."
    }
}

foreach ($record in @($provenanceManifest.records)) {
    if ($record.distributionApproved -ne $false) {
        Add-ValidationError "Provenance record $($record.id) cannot be distribution-approved in the metadata-only pass."
    }
}

$sourceSet = @($provenanceManifest.sourceSets | Where-Object { $_.id -eq "wikimedia-commons-taionwc-pam-a-78" })
if ($sourceSet.Count -ne 1 -or $sourceSet[0].observedFileCount -ne 78 -or $sourceSet[0].mappedCardCount -ne 78) {
    Add-ValidationError "The TaionWC source set must be present and complete at 78 mapped files."
}
if ($sourceSet.Count -eq 1 -and $sourceSet[0].distributionApproved -ne $false) {
    Add-ValidationError "The TaionWC source set must not be distribution-approved."
}
if ($sourceSet.Count -eq 1 -and $sourceSet[0].downloadStatus -ne "three-candidate-files-downloaded-not-production-bundled") {
    Add-ValidationError "The TaionWC source set must report exactly three non-production candidate downloads."
}

$downloadedEvidence = @($evidenceRecords | Where-Object { $_.downloaded -eq $true })
if ($downloadedEvidence.Count -ne 3) {
    Add-ValidationError "Exactly three provenance records must have controlled candidate downloads."
}
if (@(Compare-Object ($candidateCardIDs | Sort-Object) @($downloadedEvidence.cardID | Sort-Object)).Count -ne 0) {
    Add-ValidationError "The controlled downloads must be The Star, The Moon, and The Sun."
}

$localEvidencePath = Join-Path $PSScriptRoot "CandidateRWS\local-evidence.v1.json"
if (-not (Test-Path -LiteralPath $localEvidencePath)) {
    Add-ValidationError "CandidateRWS local evidence manifest is missing."
} else {
    $localManifest = Get-Content -Raw -LiteralPath $localEvidencePath | ConvertFrom-Json
    $localRecords = @($localManifest.records)
    if ($localManifest.artworkStatus -ne "provisional" -or $localManifest.distributionApproved -ne $false) {
        Add-ValidationError "CandidateRWS must remain provisional and not distribution-approved."
    }
    if ($localRecords.Count -ne 3 -or @($localRecords.cardID | Sort-Object -Unique).Count -ne 3) {
        Add-ValidationError "CandidateRWS must contain exactly three unique local evidence records."
    }
    if (@(Compare-Object ($candidateCardIDs | Sort-Object) @($localRecords.cardID | Sort-Object)).Count -ne 0) {
        Add-ValidationError "CandidateRWS local records must map to The Star, The Moon, and The Sun."
    }

    foreach ($localRecord in $localRecords) {
        $sourceEvidence = $evidenceRecords | Where-Object { $_.cardID -eq $localRecord.cardID } | Select-Object -First 1
        $candidatePath = Join-Path $PSScriptRoot $localRecord.localRelativePath
        if (-not (Test-Path -LiteralPath $candidatePath)) {
            Add-ValidationError "Candidate file is missing for $($localRecord.cardID)."
            continue
        }
        if ($localRecord.finalAsset -ne $false -or $localRecord.distributionApproved -ne $false) {
            Add-ValidationError "Candidate $($localRecord.cardID) must not be final or distribution-approved."
        }
        if ((Get-Item -LiteralPath $candidatePath).Length -ne [long]$sourceEvidence.byteSize) {
            Add-ValidationError "Candidate $($localRecord.cardID) byte size differs from Commons."
        }
        $actualSHA1 = (Get-FileHash -Algorithm SHA1 -LiteralPath $candidatePath).Hash.ToLowerInvariant()
        $actualSHA256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $candidatePath).Hash.ToLowerInvariant()
        if ($actualSHA1 -ne $sourceEvidence.sourceSHA1 -or $actualSHA1 -ne $localRecord.verifiedLocalSHA1) {
            Add-ValidationError "Candidate $($localRecord.cardID) SHA-1 differs from Commons."
        }
        if ($actualSHA256 -ne $sourceEvidence.localSHA256 -or $actualSHA256 -ne $localRecord.localSHA256) {
            Add-ValidationError "Candidate $($localRecord.cardID) SHA-256 differs from local evidence."
        }
        $headerBytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $candidatePath))
        if ($headerBytes.Length -lt 2 -or $headerBytes[0] -ne 0xFF -or $headerBytes[1] -ne 0xD8) {
            Add-ValidationError "Candidate $($localRecord.cardID) lacks a JPEG signature."
        }
        try {
            $dimensions = Get-JpegDimensions -Bytes $headerBytes
            if ($dimensions.Width -ne [int]$sourceEvidence.pixelWidth -or $dimensions.Height -ne [int]$sourceEvidence.pixelHeight) {
                Add-ValidationError "Candidate $($localRecord.cardID) dimensions differ from Commons."
            }
        } catch {
            Add-ValidationError "Candidate $($localRecord.cardID) is not a structurally valid JPEG: $($_.Exception.Message)"
        }
    }
}

# local-evidence.v1.json remains the historical three-file snapshot above.
# local-evidence.v2.json is the current complete local source-integrity snapshot.
if (-not (Test-Path -LiteralPath $LocalCandidateManifestPath)) {
    Add-ValidationError "CandidateRWS local evidence v2 manifest is missing."
} else {
    $localV2 = Get-Content -Raw -LiteralPath $LocalCandidateManifestPath | ConvertFrom-Json
    $localV2Records = @($localV2.records)
    $localV2Failures = @($localV2.failures)

    if ($localV2.schemaVersion -ne 2 -or $localV2.manifestVersion -ne "2.0.0") {
        Add-ValidationError "CandidateRWS local evidence v2 must use schemaVersion 2 and manifestVersion 2.0.0."
    }
    if ($localV2.status -ne "candidate-integrity-verified-78-of-78-not-production") {
        Add-ValidationError "CandidateRWS local evidence v2 must report the complete 78/78 candidate status."
    }
    if ($localV2.requestedCardCount -ne 78 -or $localV2.verifiedCardCount -ne 78 -or $localV2.failureCount -ne 0 -or $localV2Failures.Count -ne 0) {
        Add-ValidationError "CandidateRWS local evidence v2 must report exactly 78 requested, 78 verified, and zero failures."
    }
    if ($localV2.artworkStatus -ne "provisional" -or $localV2.candidateOnly -ne $true -or $localV2.finalAsset -ne $false) {
        Add-ValidationError "CandidateRWS local evidence v2 must remain provisional, candidate-only, and not final."
    }
    if ($localV2.territorialRightsReviewStatus -ne "pending" -or $localV2.distributionApproved -ne $false) {
        Add-ValidationError "CandidateRWS local evidence v2 must remain territorially pending and not distribution-approved."
    }
    if ($localV2Records.Count -ne 78 -or @($localV2Records.cardID | Sort-Object -Unique).Count -ne 78) {
        Add-ValidationError "CandidateRWS local evidence v2 must contain exactly 78 unique card records."
    }
    if (@(Compare-Object ($cardIDs | Sort-Object) @($localV2Records.cardID | Sort-Object)).Count -ne 0) {
        Add-ValidationError "CandidateRWS local evidence v2 must map one-to-one to all 78 deck cards."
    }

    foreach ($uniqueLocalField in @("localRelativePath", "sourceURL", "verifiedLocalSHA1", "localSHA256")) {
        $localValues = @($localV2Records | ForEach-Object { $_.$uniqueLocalField })
        if (@($localValues | Where-Object { [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0 -or
            @($localValues | Sort-Object -Unique).Count -ne 78) {
            Add-ValidationError "Every CandidateRWS v2 $uniqueLocalField must be present and unique."
        }
    }

    $candidateDirectory = Join-Path $PSScriptRoot "CandidateRWS"
    $candidateDirectoryFullPath = [System.IO.Path]::GetFullPath($candidateDirectory).TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $manifestCandidatePaths = [System.Collections.Generic.List[string]]::new()
    foreach ($localRecord in $localV2Records) {
        $sourceEvidence = $evidenceRecords | Where-Object { $_.cardID -eq $localRecord.cardID } | Select-Object -First 1
        if ($null -eq $sourceEvidence) {
            Add-ValidationError "CandidateRWS v2 record $($localRecord.cardID) lacks source evidence."
            continue
        }
        if ($localRecord.sourceEvidenceID -ne $sourceEvidence.evidenceID -or
            $localRecord.artworkAsset -ne $sourceEvidence.artworkAsset -or
            $localRecord.sourceURL -ne $sourceEvidence.originalFileURL) {
            Add-ValidationError "CandidateRWS v2 record $($localRecord.cardID) differs from its exact provenance mapping."
        }
        if ($localRecord.artworkStatus -ne "provisional" -or
            $localRecord.pixelReviewStatus -ne "source-file-integrity-verified-final-art-review-pending" -or
            $localRecord.territorialRightsReviewStatus -ne "pending" -or
            $localRecord.finalAsset -ne $false -or
            $localRecord.distributionApproved -ne $false) {
            Add-ValidationError "CandidateRWS v2 record $($localRecord.cardID) has an opened production or review gate."
        }
        if ($localRecord.sha1MatchesSource -ne $true -or
            $localRecord.byteSizeMatchesSource -ne $true -or
            $localRecord.dimensionMatchesSource -ne $true -or
            $localRecord.mimeType -ne "image/jpeg" -or
            $localRecord.expectedMimeType -ne "image/jpeg") {
            Add-ValidationError "CandidateRWS v2 record $($localRecord.cardID) does not declare complete source-integrity matches."
        }

        $candidatePath = Join-Path $PSScriptRoot $localRecord.localRelativePath
        $candidateFullPath = [System.IO.Path]::GetFullPath($candidatePath)
        if (-not $candidateFullPath.StartsWith($candidateDirectoryFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            Add-ValidationError "CandidateRWS v2 record $($localRecord.cardID) points outside CandidateRWS."
            continue
        }
        if (-not (Test-Path -LiteralPath $candidateFullPath)) {
            Add-ValidationError "CandidateRWS v2 file is missing for $($localRecord.cardID)."
            continue
        }
        $manifestCandidatePaths.Add($candidateFullPath)

        $file = Get-Item -LiteralPath $candidateFullPath
        if ($file.Length -ne [long]$sourceEvidence.byteSize -or
            $file.Length -ne [long]$localRecord.byteSize -or
            [long]$localRecord.expectedByteSize -ne [long]$sourceEvidence.byteSize) {
            Add-ValidationError "CandidateRWS v2 file $($localRecord.cardID) byte size differs from evidence."
        }

        $actualSHA1 = (Get-FileHash -Algorithm SHA1 -LiteralPath $candidateFullPath).Hash.ToLowerInvariant()
        $actualSHA256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $candidateFullPath).Hash.ToLowerInvariant()
        if ($actualSHA1 -ne $sourceEvidence.sourceSHA1 -or
            $actualSHA1 -ne $localRecord.expectedSourceSHA1 -or
            $actualSHA1 -ne $localRecord.verifiedLocalSHA1) {
            Add-ValidationError "CandidateRWS v2 file $($localRecord.cardID) SHA-1 differs from the exact source evidence."
        }
        if ($actualSHA256 -ne $localRecord.localSHA256) {
            Add-ValidationError "CandidateRWS v2 file $($localRecord.cardID) SHA-256 differs from local evidence."
        }

        $fileBytes = [System.IO.File]::ReadAllBytes($candidateFullPath)
        if ($fileBytes.Length -lt 4 -or
            $fileBytes[0] -ne 0xFF -or $fileBytes[1] -ne 0xD8 -or
            $fileBytes[$fileBytes.Length - 2] -ne 0xFF -or $fileBytes[$fileBytes.Length - 1] -ne 0xD9) {
            Add-ValidationError "CandidateRWS v2 file $($localRecord.cardID) lacks a complete JPEG signature."
        }

        try {
            $dimensions = Get-JpegDimensions -Bytes $fileBytes
            if ($dimensions.Width -ne [int]$sourceEvidence.pixelWidth -or
                $dimensions.Height -ne [int]$sourceEvidence.pixelHeight -or
                $dimensions.Width -ne [int]$localRecord.pixelWidth -or
                $dimensions.Height -ne [int]$localRecord.pixelHeight -or
                [int]$localRecord.expectedPixelWidth -ne [int]$sourceEvidence.pixelWidth -or
                [int]$localRecord.expectedPixelHeight -ne [int]$sourceEvidence.pixelHeight) {
                Add-ValidationError "CandidateRWS v2 file $($localRecord.cardID) dimensions differ from evidence."
            }
        } catch {
            Add-ValidationError "CandidateRWS v2 file $($localRecord.cardID) is not a structurally valid JPEG: $($_.Exception.Message)"
        }
    }

    $actualCandidateFiles = @(Get-ChildItem -LiteralPath $candidateDirectory -File -Filter "*.jpg")
    if ($actualCandidateFiles.Count -ne 78) {
        Add-ValidationError "CandidateRWS must contain exactly 78 JPEG source files."
    }
    $actualCandidatePaths = @($actualCandidateFiles | ForEach-Object { $_.FullName } | Sort-Object)
    if (@(Compare-Object @($manifestCandidatePaths | Sort-Object) $actualCandidatePaths).Count -ne 0) {
        Add-ValidationError "CandidateRWS JPEG files must match the 78 v2 manifest paths exactly."
    }
    if (@(Get-ChildItem -LiteralPath $candidateDirectory -Recurse -File -Filter "*.partial").Count -ne 0) {
        Add-ValidationError "CandidateRWS contains unfinished partial downloads."
    }
}

if ($validationErrors.Count -gt 0) {
    $validationErrors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Content validation passed: 78 cards, 78 unique TaionWC records, historical v1 evidence preserved, and 78/78 local v2 candidates verified by SHA-1, SHA-256, bytes, JPEG format, and dimensions; distribution remains unapproved."
