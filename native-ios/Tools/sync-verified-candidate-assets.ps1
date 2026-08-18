param(
    [string]$EvidencePath = (Join-Path $PSScriptRoot "../Content/CandidateRWS/local-evidence.v2.json"),
    [string]$AssetCatalogPath = (Join-Path $PSScriptRoot "../TarotDeckApp/Resources/Assets.xcassets")
)

$ErrorActionPreference = "Stop"

$evidenceFile = Resolve-Path -LiteralPath $EvidencePath
$assetCatalog = Resolve-Path -LiteralPath $AssetCatalogPath
$candidateDirectory = Split-Path -Parent $evidenceFile.Path
$evidence = Get-Content -Raw -LiteralPath $evidenceFile.Path | ConvertFrom-Json
if ([int]$evidence.schemaVersion -ne 2) {
    throw "Candidate synchronization requires local-evidence.v2.json schema version 2."
}
if ([string]$evidence.status -cne "integrity-verified-78-of-78-visual-final-territory-limited" -or
    [string]$evidence.artworkStatus -cne "final" -or
    $evidence.candidateOnly -ne $false -or
    $evidence.finalAsset -ne $true -or
    $evidence.distributionApproved -ne $false -or
    $evidence.distributionApprovedForDeclaredTerritories -ne $true -or
    $evidence.worldwideDistributionApproved -ne $false -or
    (@($evidence.approvedTerritories) -join ',') -cne 'US,GB,ES' -or
    [int]$evidence.verifiedCardCount -ne 78 -or
    [int]$evidence.failureCount -ne 0 -or
    @($evidence.records).Count -ne 78) {
    throw "Asset synchronization requires the complete final snapshot cleared only for US/GB/ES and never worldwide."
}

$synced = 0
foreach ($record in $evidence.records) {
    if ([string]$record.artworkStatus -cne "final" -or
        [string]$record.pixelReviewStatus -cne "source-file-integrity-verified-owner-approved-visual-final" -or
        [string]$record.territorialRightsReviewStatus -cne "approved-for-declared-territories" -or
        $record.finalAsset -ne $true -or
        $record.distributionApproved -ne $false -or
        $record.distributionApprovedForDeclaredTerritories -ne $true -or
        -not $record.sha1MatchesSource -or
        -not $record.byteSizeMatchesSource -or
        -not $record.dimensionMatchesSource) {
        throw "Record $($record.cardID) does not preserve the final US/GB/ES-only release state."
    }
    if ([string]$record.artworkAsset -cnotmatch '^[a-z0-9_]+$') {
        throw "Unsafe artwork asset name for $($record.cardID)."
    }

    $relativeFile = Split-Path -Leaf $record.localRelativePath
    $sourceFile = Join-Path $candidateDirectory $relativeFile
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        throw "Verified evidence points to a missing local file: $sourceFile"
    }

    $actualSHA1 = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA1).Hash.ToLowerInvariant()
    if ($actualSHA1 -cne $record.expectedSourceSHA1.ToLowerInvariant() -or
        $actualSHA1 -cne $record.verifiedLocalSHA1.ToLowerInvariant()) {
        throw "SHA-1 mismatch for $($record.cardID)."
    }

    $imageSet = Join-Path $assetCatalog.Path "$($record.artworkAsset).imageset"
    New-Item -ItemType Directory -Path $imageSet -Force | Out-Null
    Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $imageSet "candidate.jpg") -Force

    $contents = @{
        images = @(
            @{
                filename = "candidate.jpg"
                idiom = "universal"
                scale = "1x"
            }
        )
        info = @{
            author = "xcode"
            version = 1
        }
        properties = @{
            "preserves-vector-representation" = $false
        }
    }
    $contentsJSON = $contents | ConvertTo-Json -Depth 6
    $utf8WithoutBOM = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText(
        (Join-Path $imageSet "Contents.json"),
        $contentsJSON,
        $utf8WithoutBOM
    )
    $synced += 1
}

if ($synced -ne $evidence.verifiedCardCount) {
    throw "Synced $synced assets, but evidence declares $($evidence.verifiedCardCount)."
}

Write-Host "Synced $synced source-integrity-verified final faces for the US/GB/ES-only release snapshot; worldwide clearance remains false."
