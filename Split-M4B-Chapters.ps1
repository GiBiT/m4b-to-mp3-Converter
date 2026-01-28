# M4B Chapter Splitter (Numbered Filenames, Descriptive Metadata)
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$InputFile
)

# Force UTF-8 and fix console encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path $InputFile)) {
    Write-Host "Error: File '$InputFile' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Extracting metadata..." -ForegroundColor Yellow
$metadataJson = & ffprobe -v quiet -print_format json -show_format -show_chapters $InputFile | ConvertFrom-Json

# 1. Extract and Clean Global Metadata
$globalTags = $metadataJson.format.tags
$bookTitle = if ($globalTags.album) { $globalTags.album } else { $globalTags.title }
$bookArtist = if ($globalTags.artist) { $globalTags.artist } else { $globalTags.album_artist }

# Fix encoding/quotes in global tags
$bookTitle = $bookTitle -replace "[\u2018\u2019]", "'" -replace "[\u201C\u201D]", '"'
$bookArtist = $bookArtist -replace "[\u2018\u2019]", "'" -replace "[\u201C\u201D]", '"'

# 2. Setup Output Directory
$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$OutputDir = Join-Path ([System.IO.Path]::GetDirectoryName($InputFile)) "$BaseName-chapters"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$chapterCount = $metadataJson.chapters.Count
$chapterNum = 1

foreach ($chapter in $metadataJson.chapters) {
    $startTime = $chapter.start_time
    $duration = [double]$chapter.end_time - [double]$chapter.start_time
    
    # 3. Get Chapter Title for Metadata
    $rawTitle = ($chapter.tags.title, $chapter.tags.TITLE | Where-Object {$_})[0]
    if (-not $rawTitle) { $rawTitle = "Chapter $chapterNum" }
    
    # Clean encoding/quotes for the ID3 tag
    $rawTitle = $rawTitle -replace "[\u2018\u2019]", "'" -replace "[\u201C\u201D]", '"'
    
    # 4. Generate Numeric Filename (001.mp3)
    # "D3" ensures 3-digit padding (001, 002...)
    $fileName = "$($chapterNum.ToString('D3')).mp3"
    $outputFile = Join-Path $OutputDir $fileName

    Write-Host "Processing: $fileName -> $rawTitle" -ForegroundColor Cyan

    # 5. Run FFMPEG
    & ffmpeg -ss $startTime -t $duration -i $InputFile `
        -vn -acodec libmp3lame -q:a 2 `
        -metadata title="$rawTitle" `
        -metadata album="$bookTitle" `
        -metadata artist="$bookArtist" `
        -metadata album_artist="$bookArtist" `
        -metadata track="$chapterNum/$chapterCount" `
        -id3v2_version 3 `
        -y $outputFile -loglevel error

    $chapterNum++
}

Write-Host "`n✓ Complete! Files are in: $OutputDir" -ForegroundColor Green