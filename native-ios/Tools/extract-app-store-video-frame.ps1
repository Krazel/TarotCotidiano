[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VideoPath,

    [Parameter(Mandatory = $true)]
    [string]$Timestamp,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [ValidateSet('en-US', 'es-ES')]
    [string]$Localization,

    [string]$ScreenState,
    [string]$SourceCommit = 'UNRECORDED'
)

$ErrorActionPreference = 'Stop'

$resolvedVideo = (Resolve-Path -LiteralPath $VideoPath).Path
$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
if ([System.IO.Path]::GetExtension($outputFullPath) -cne '.png') {
    throw 'OutputPath must end in .png so the extracted frame remains lossless.'
}

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
$ffprobe = Get-Command ffprobe -ErrorAction SilentlyContinue
if ($null -eq $ffmpeg -or $null -eq $ffprobe) {
    throw 'ffmpeg and ffprobe are required. Do not install or download them automatically from this script.'
}

$outputDirectory = Split-Path -Parent $outputFullPath
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
if (Test-Path -LiteralPath $outputFullPath) {
    throw "Refusing to overwrite an existing frame: $outputFullPath"
}

& $ffmpeg.Source -hide_banner -loglevel error -ss $Timestamp -i $resolvedVideo -frames:v 1 -fps_mode passthrough -compression_level 0 $outputFullPath
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputFullPath -PathType Leaf)) {
    throw 'Frame extraction failed.'
}

$probeText = & $ffprobe.Source -v error -select_streams v:0 -show_entries stream=width,height -of json $outputFullPath
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to inspect the extracted frame.'
}
$probe = $probeText | ConvertFrom-Json
$stream = @($probe.streams)[0]
if ($null -eq $stream -or [int]$stream.width -le 0 -or [int]$stream.height -le 0) {
    throw 'Extracted frame dimensions are invalid.'
}

$sourceHash = (Get-FileHash -LiteralPath $resolvedVideo -Algorithm SHA256).Hash.ToLowerInvariant()
$frameHash = (Get-FileHash -LiteralPath $outputFullPath -Algorithm SHA256).Hash.ToLowerInvariant()
$evidencePath = "$outputFullPath.evidence.json"
$evidence = [ordered]@{
    schemaVersion = 1
    app = 'Tarot Deck'
    buildVersion = '1.0'
    buildNumber = '1'
    sourceCommit = $SourceCommit
    localization = $Localization
    screenState = $ScreenState
    sourceKind = 'video-frame'
    sourceFilename = [System.IO.Path]::GetFileName($resolvedVideo)
    sourceSHA256 = $sourceHash
    timestamp = $Timestamp
    frameFilename = [System.IO.Path]::GetFileName($outputFullPath)
    frameSHA256 = $frameHash
    width = [int]$stream.width
    height = [int]$stream.height
    extractedAtUTC = [DateTime]::UtcNow.ToString('o')
    finalAppStoreExport = $false
}

$evidence | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $evidencePath -Encoding utf8NoBOM
Write-Output "Extracted lossless frame: $outputFullPath"
Write-Output "Frame size: $($stream.width)x$($stream.height)"
Write-Output "Evidence: $evidencePath"
Write-Output 'This is a source frame, not a final App Store export. Review crop, scale, privacy, localization and an accepted Apple canvas separately.'
