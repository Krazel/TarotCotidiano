param(
    [switch]$DownloadMissing,
    [ValidateRange(1, 78)]
    [int]$MaximumNewDownloads = 10
)

$ErrorActionPreference = 'Stop'

$candidateDirectory = $PSScriptRoot
$contentDirectory = Split-Path -Parent $candidateDirectory
$provenancePath = Join-Path $contentDirectory 'provenance.v2.json'
$manifestPath = Join-Path $candidateDirectory 'local-evidence.v2.json'
$temporaryDirectory = Join-Path $candidateDirectory '.download'

function Get-JpegEvidence {
    param([Parameter(Mandatory = $true)][string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasJpegSignature = $bytes.Length -ge 4 -and
        $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8 -and
        $bytes[$bytes.Length - 2] -eq 0xFF -and $bytes[$bytes.Length - 1] -eq 0xD9

    $width = $null
    $height = $null
    $decodeStatus = 'jpeg-signature-only'

    try {
        Add-Type -AssemblyName System.Drawing
        $image = [System.Drawing.Image]::FromFile($Path)
        try {
            $width = $image.Width
            $height = $image.Height
            $decodeStatus = 'decoded-as-jpeg-by-system-drawing'
        }
        finally {
            $image.Dispose()
        }
    }
    catch {
        if (-not $hasJpegSignature) {
            throw "File is not a decodable JPEG and has no JPEG signature: $Path"
        }
    }

    [PSCustomObject]@{
        width = $width
        height = $height
        hasJpegSignature = $hasJpegSignature
        decodeStatus = $decodeStatus
    }
}

function Invoke-ExactDownload {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$OutFile
    )

    $headers = @{
        'User-Agent' = 'TarotCotidianoCandidateAssetVerifier/1.0 (private development; exact-source integrity download)'
        'Accept' = 'image/jpeg,image/*;q=0.9,*/*;q=0.1'
    }
    $maximumAttempts = 1

    for ($attempt = 1; $attempt -le $maximumAttempts; $attempt++) {
        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -Headers $headers
            return
        }
        catch {
            if ($attempt -eq $maximumAttempts) {
                throw
            }

            $statusCode = $null
            if ($null -ne $_.Exception.Response) {
                try { $statusCode = [int]$_.Exception.Response.StatusCode } catch { $statusCode = $null }
            }
            if ($statusCode -notin @(429, 500, 502, 503, 504)) {
                throw
            }

            $delaySeconds = [Math]::Min(30, [Math]::Pow(2, $attempt))
            Start-Sleep -Seconds $delaySeconds
        }
    }
}

$provenance = Get-Content -LiteralPath $provenancePath -Raw | ConvertFrom-Json
$evidence = @($provenance.assetEvidence)
$releaseDecision = $provenance.projectReleaseDecision
$releaseSourceSet = @($provenance.sourceSets | Where-Object { $_.id -ceq 'wikimedia-commons-taionwc-pam-a-78' })

if ($null -eq $releaseDecision -or
    $releaseDecision.visualFinalApprovedByOwner -ne $true -or
    $releaseDecision.finalAsset -ne $true -or
    $releaseDecision.distributionApprovedForDeclaredTerritories -ne $true -or
    $releaseDecision.worldwideDistributionApproved -ne $false -or
    (@($releaseDecision.approvedTerritories) -join ',') -cne 'US,GB,ES' -or
    $releaseSourceSet.Count -ne 1 -or
    $releaseSourceSet[0].distributionApproved -ne $false -or
    $releaseSourceSet[0].distributionApprovedForDeclaredTerritories -ne $true -or
    $releaseSourceSet[0].worldwideDistributionApproved -ne $false -or
    (@($releaseSourceSet[0].approvedTerritories) -join ',') -cne 'US,GB,ES') {
    throw 'Refusing to regenerate evidence without the exact owner-approved final US/GB/ES-only decision and worldwide=false safeguard.'
}

if ($evidence.Count -ne 78) {
    throw "Expected 78 provenance records, found $($evidence.Count)."
}

$duplicateCardIDs = @($evidence | Group-Object cardID | Where-Object Count -ne 1)
$duplicateURLs = @($evidence | Group-Object originalFileURL | Where-Object Count -ne 1)
if ($duplicateCardIDs.Count -gt 0 -or $duplicateURLs.Count -gt 0) {
    throw 'The provenance manifest must contain 78 unique card IDs and exact original-file URLs.'
}

if ($DownloadMissing) {
    New-Item -ItemType Directory -Path $temporaryDirectory -Force | Out-Null
}

$records = [System.Collections.Generic.List[object]]::new()
$failures = [System.Collections.Generic.List[object]]::new()
$downloadsThisRun = 0

foreach ($source in $evidence) {
    $uri = [Uri]$source.originalFileURL
    $fileName = [Uri]::UnescapeDataString(($uri.Segments | Select-Object -Last 1))
    $localPath = Join-Path $candidateDirectory $fileName
    $relativePath = "CandidateRWS/$fileName"

    if (Test-Path -LiteralPath $localPath) {
        $existingSHA1 = (Get-FileHash -LiteralPath $localPath -Algorithm SHA1).Hash.ToLowerInvariant()
        if ($existingSHA1 -ne $source.sourceSHA1.ToLowerInvariant()) {
            $failures.Add([PSCustomObject]@{
                cardID = $source.cardID
                sourceURL = $source.originalFileURL
                localRelativePath = $relativePath
                reason = 'existing-file-sha1-mismatch-not-overwritten'
                expectedSourceSHA1 = $source.sourceSHA1.ToLowerInvariant()
                actualLocalSHA1 = $existingSHA1
            })
            continue
        }
    }
    elseif ($DownloadMissing) {
        if ($downloadsThisRun -ge $MaximumNewDownloads) {
            $failures.Add([PSCustomObject]@{
                cardID = $source.cardID
                sourceURL = $source.originalFileURL
                localRelativePath = $relativePath
                reason = 'batch-limit-reached-not-attempted'
                expectedSourceSHA1 = $source.sourceSHA1.ToLowerInvariant()
            })
            continue
        }
        $temporaryPath = Join-Path $temporaryDirectory ($fileName + '.partial')
        try {
            Invoke-ExactDownload -Uri $source.originalFileURL -OutFile $temporaryPath
            $downloadedSHA1 = (Get-FileHash -LiteralPath $temporaryPath -Algorithm SHA1).Hash.ToLowerInvariant()
            if ($downloadedSHA1 -ne $source.sourceSHA1.ToLowerInvariant()) {
                throw "SHA-1 mismatch: expected $($source.sourceSHA1), received $downloadedSHA1"
            }
            Move-Item -LiteralPath $temporaryPath -Destination $localPath
            $downloadsThisRun++
            Start-Sleep -Milliseconds 5000
        }
        catch {
            if (Test-Path -LiteralPath $temporaryPath) {
                Remove-Item -LiteralPath $temporaryPath -Force
            }
            $failures.Add([PSCustomObject]@{
                cardID = $source.cardID
                sourceURL = $source.originalFileURL
                localRelativePath = $relativePath
                reason = 'download-or-integrity-failure'
                expectedSourceSHA1 = $source.sourceSHA1.ToLowerInvariant()
                detail = $_.Exception.Message
            })
            continue
        }
    }
    else {
        $failures.Add([PSCustomObject]@{
            cardID = $source.cardID
            sourceURL = $source.originalFileURL
            localRelativePath = $relativePath
            reason = 'missing-download-disabled'
            expectedSourceSHA1 = $source.sourceSHA1.ToLowerInvariant()
        })
        continue
    }

    try {
        $file = Get-Item -LiteralPath $localPath
        $actualSHA1 = (Get-FileHash -LiteralPath $localPath -Algorithm SHA1).Hash.ToLowerInvariant()
        $actualSHA256 = (Get-FileHash -LiteralPath $localPath -Algorithm SHA256).Hash.ToLowerInvariant()
        $imageEvidence = Get-JpegEvidence -Path $localPath
        $dimensionMatches = $null -ne $imageEvidence.width -and
            $imageEvidence.width -eq $source.pixelWidth -and
            $imageEvidence.height -eq $source.pixelHeight
        $byteSizeMatches = $file.Length -eq $source.byteSize
        $mimeMatches = $source.mimeType -eq 'image/jpeg' -and $imageEvidence.hasJpegSignature

        if ($actualSHA1 -ne $source.sourceSHA1.ToLowerInvariant()) {
            throw "Local SHA-1 mismatch after download: expected $($source.sourceSHA1), found $actualSHA1"
        }
        if (-not $byteSizeMatches) {
            throw "Byte-size mismatch: expected $($source.byteSize), found $($file.Length)"
        }
        if (-not $mimeMatches) {
            throw "MIME/signature mismatch: expected $($source.mimeType)"
        }
        if ($null -ne $imageEvidence.width -and -not $dimensionMatches) {
            throw "Dimension mismatch: expected $($source.pixelWidth)x$($source.pixelHeight), found $($imageEvidence.width)x$($imageEvidence.height)"
        }

        $records.Add([PSCustomObject][ordered]@{
            candidateID = "candidate-rws-$($source.cardID)"
            cardID = $source.cardID
            artworkAsset = $source.artworkAsset
            sourceEvidenceID = $source.evidenceID
            localRelativePath = $relativePath
            sourceURL = $source.originalFileURL
            byteSize = $file.Length
            expectedByteSize = $source.byteSize
            byteSizeMatchesSource = $byteSizeMatches
            mimeType = 'image/jpeg'
            expectedMimeType = $source.mimeType
            mimeVerification = $imageEvidence.decodeStatus
            pixelWidth = $imageEvidence.width
            pixelHeight = $imageEvidence.height
            expectedPixelWidth = $source.pixelWidth
            expectedPixelHeight = $source.pixelHeight
            dimensionMatchesSource = $dimensionMatches
            expectedSourceSHA1 = $source.sourceSHA1.ToLowerInvariant()
            verifiedLocalSHA1 = $actualSHA1
            sha1MatchesSource = $true
            localSHA256 = $actualSHA256
            artworkStatus = 'final'
            pixelReviewStatus = 'source-file-integrity-verified-owner-approved-visual-final'
            territorialRightsReviewStatus = 'approved-for-declared-territories'
            finalAsset = $true
            distributionApproved = $false
            distributionApprovedForDeclaredTerritories = $true
        })
    }
    catch {
        $failures.Add([PSCustomObject]@{
            cardID = $source.cardID
            sourceURL = $source.originalFileURL
            localRelativePath = $relativePath
            reason = 'local-validation-failure'
            expectedSourceSHA1 = $source.sourceSHA1.ToLowerInvariant()
            detail = $_.Exception.Message
        })
    }
}

if (Test-Path -LiteralPath $temporaryDirectory) {
    $remainingTemporaryFiles = @(Get-ChildItem -LiteralPath $temporaryDirectory -Force)
    if ($remainingTemporaryFiles.Count -eq 0) {
        Remove-Item -LiteralPath $temporaryDirectory -Force
    }
}

$orderedRecords = @($records | Sort-Object { [array]::IndexOf($evidence.cardID, $_.cardID) })
if ($orderedRecords.Count -ne 78 -or $failures.Count -gt 0) {
    Write-Host "Verified source files: $($orderedRecords.Count)/78"
    Write-Host "Failures: $($failures.Count)"
    $failures | Format-Table cardID, reason, detail -AutoSize
    throw 'Evidence regeneration is incomplete; the existing final v2 manifest was not overwritten.'
}

$localManifest = [PSCustomObject][ordered]@{
    schemaVersion = 2
    manifestVersion = '2.0.0'
    status = 'integrity-verified-78-of-78-visual-final-territory-limited'
    sourceProvenanceManifest = '../provenance.v2.json'
    generatedAtUTC = [DateTime]::UtcNow.ToString('o')
    sourceSetID = 'wikimedia-commons-taionwc-pam-a-78'
    requestedCardCount = 78
    verifiedCardCount = $orderedRecords.Count
    failureCount = $failures.Count
    artworkStatus = 'final'
    candidateOnly = $false
    finalAsset = $true
    territorialRightsReviewStatus = 'approved-for-declared-territories'
    distributionApproved = $false
    distributionApprovedForDeclaredTerritories = $true
    approvedTerritories = @('US', 'GB', 'ES')
    worldwideDistributionApproved = $false
    legalReviewStatement = 'Owner-approved final visuals. Public distribution is approved only for the declared US, GB, and ES storefront allowlist; worldwide clearance is not declared.'
    records = $orderedRecords
    failures = @($failures)
}

$json = $localManifest | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($manifestPath, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))

Write-Host "Verified candidate files: $($orderedRecords.Count)/78"
Write-Host "Failures: $($failures.Count)"
Write-Host "Manifest: $manifestPath"

if ($failures.Count -gt 0) {
    $failures | Format-Table cardID, reason, detail -AutoSize
    exit 1
}
