function Split-M4B-Chapters {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputFile
    )

    # Ensure file exists
    if (-not (Test-Path $InputFile)) {
        Write-Error "File not found: $InputFile"
        exit 1
    }

    # Get file name and output folder
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $OutputDir = Join-Path ([System.IO.Path]::GetDirectoryName($InputFile)) "$BaseName-chapters"

    # Create output folder
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

    Write-Host "📖 Splitting $InputFile into chapters..."
    Write-Host "📁 Output folder: $OutputDir`n"

    # Get chapters JSON from ffprobe
    $chaptersJson = ffprobe -v quiet -print_format json -show_chapters "$InputFile" | Out-String
    $chapters = ($chaptersJson | ConvertFrom-Json).chapters

    if (-not $chapters) {
        Write-Error "❌ No chapters found in $InputFile"
        exit 1
    }

    # Loop through each chapter
    for ($i = 0; $i -lt $chapters.Count; $i++) {
        $ch = $chapters[$i]
        $start = [double]$ch.start_time
        $end = [double]$ch.end_time
        $title = if ($ch.tags.title -and $ch.tags.title.Trim() -ne "") { $ch.tags.title } else { "Chapter_$i" }

        # Clean filename
        $safeTitle = ($title -replace '[\\/:*?"<>|]', '_')
        $outFile = Join-Path $OutputDir "$safeTitle.mp3"

        Write-Host "🎧 Extracting: $safeTitle"

        # Extract and encode to MP3 (VBR)
        ffmpeg -v quiet -i "$InputFile" -ss $start -to $end -acodec libmp3lame -qscale:a 2 -metadata title="$title" "$outFile"
    }

    Write-Host "`n✅ Done! Chapters saved in: $OutputDir"
    Start-Process explorer $OutputDir
}

# 👇 Run interactively (will prompt for InputFile)
Split-M4B-Chapters
