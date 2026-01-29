param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$InputFile
)

# 1. Handle Encoding (Prevents the "Invalid Handle" crash)
try {
    $OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    Write-Host "Warning: Could not force UTF8 console encoding. Symbols might look odd." -ForegroundColor Gray
}

if (-not (Test-Path $InputFile)) {
    Write-Host "Error: File '$InputFile' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Extracting metadata..." -ForegroundColor Yellow
$metadataJson = & ffprobe -v quiet -print_format json -show_format -show_chapters $InputFile | ConvertFrom-Json

# 2. Extract and Clean Global Metadata
$globalTags = $metadataJson.format.tags
$bookTitle = if ($globalTags.album) { $globalTags.album } else { $globalTags.title }
$bookArtist = if ($globalTags.artist) { $globalTags.artist } else { $globalTags.album_artist }

# Cleanup characters
$bookTitle = $bookTitle -replace "[\u2018\u2019]", "'" -replace "[\u201C\u201D]", '"'
$bookArtist = $bookArtist -replace "[\u2018\u2019]", "'" -replace "[\u201C\u201D]", '"'

# 3. Setup Output Directory
$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$OutputDir = Join-Path ([System.IO.Path]::GetDirectoryName($InputFile)) "$BaseName-chapters"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$chapterCount = $metadataJson.chapters.Count
$chapterNum = 1

foreach ($chapter in $metadataJson.chapters) {
    $startTime = $chapter.start_time
    $duration = [double]$chapter.end_time - [double]$chapter.start_time
    
    # 4. Smart Title Logic
    $rawTitle = ($chapter.tags.title, $chapter.tags.TITLE | Where-Object {$_})[0]
    
    # If title is just a number (e.g. "001"), make it "Chapter 01"
    if ($rawTitle -match '^\d+$' -or -not $rawTitle) {
        $rawTitle = "Chapter $($chapterNum.ToString('D2'))"
    }
    
    $rawTitle = $rawTitle -replace "[\u2018\u2019]", "'" -replace "[\u201C\u201D]", '"'
    
    # 5. Filename is ALWAYS just the number
    $fileName = "$($chapterNum.ToString('D3')).mp3"
    $outputFile = Join-Path $OutputDir $fileName

    Write-Host "Extracting: $fileName ($rawTitle)" -ForegroundColor Cyan

    # 6. Run FFMPEG
    # -b:a 192k fixes the 'Assertion failed' VBR crash
    & ffmpeg -ss $startTime -t $duration -i $InputFile `
        -map 0:a -map 0:v? -c:a libmp3lame -b:a 192k -c:v copy `
        -disposition:v:0 attached_pic `
        -metadata title="$rawTitle" `
        -metadata album="$bookTitle" `
        -metadata artist="$bookArtist" `
        -metadata album_artist="$bookArtist" `
        -metadata track="$chapterNum" `
        -id3v2_version 3 `
        -y $outputFile -loglevel error

    $chapterNum++
}

Write-Host "`n✓ Complete! Extracted to: $OutputDir" -ForegroundColor Green