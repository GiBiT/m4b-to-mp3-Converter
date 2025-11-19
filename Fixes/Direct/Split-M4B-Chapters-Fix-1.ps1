param(
	[Parameter(Mandatory = $true)]
	[string]$InputFile
)

# Force UTF-8 output so PowerShell doesn't corrupt characters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

Write-Host "Splitting $InputFile into chapters..."
Write-Host "Output folder: $OutputDir`n"

# Get chapters JSON from ffprobe
$chaptersJson = ffprobe -v quiet -print_format json -show_chapters "$InputFile" | Out-String
$chapters = ($chaptersJson | ConvertFrom-Json).chapters

if (-not $chapters) {
	Write-Error "No chapters found in $InputFile"
	exit 1
}

# Loop through each chapter
for ($i = 0; $i -lt $chapters.Count; $i++) {
	$ch = $chapters[$i]
	$start = [double]$ch.start_time
	$end = [double]$ch.end_time

	# Clean remaining forbidden characters in Title
	$title = if ($ch.tags.title -and $ch.tags.title.Trim() -ne "") { $ch.tags.title } else { "Chapter_$i" }
	$title = $title -replace "’","'" -replace ':', ' -'
	$safeTitle = ($title -replace '[\\/*?"<>|]', '_')
	$outFile = Join-Path $OutputDir "$safeTitle.mp3"
	Write-Host "Extracting: $safeTitle"

	# Extract and encode to MP3 (CBR)
	ffmpeg -v quiet -i "$InputFile" -ss $start -to $end -acodec libmp3lame -b:a 128k -metadata title="$title" "$outFile"
}

Write-Host "`Done! Chapters saved in: $OutputDir"
Start-Process explorer $OutputDir
