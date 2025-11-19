# Fixes Folder

## How to Use

These files are designed to be ran when you have an issue. You can copy which fix attempt file to your location to run instead of the ones in the root.

Divided in here are 2 Directories:
1. `/Direct` needs an input file included in the command
2. `/Interactive` will prompt you to enter a path for the file

These files are to be run just like the ones found in the root, we can just change the command name

## Usage

These files try to resolve this particular error:
```
Assertion failed: vbrsf[sfb] >= vbrsfmin[sfb], file ../../lame-3.100/libmp3lame/vbrquantize.c, line 783
```

### 3 Possible Ways to Fix
#### Fix 1
Replace this line in your script
```
ffmpeg -v quiet -i "$InputFile" -ss $start -to $end -acodec libmp3lame -qscale:a 2 -metadata title="$title" "$outFile"
```
With: 
```
ffmpeg -v quiet -i "$InputFile" -ss $start -to $end -acodec libmp3lame -b:a 128k -metadata title="$title" "$outFile"
```

Alternatively: 
Direct: Run `.\Split-M4B-Chapters-Fix-1.ps1 -InputFile "C:\Downloads\File.m4b"`
Interactive: Run `.\Split-M4B-Chapters-Prompt-Fix-1.ps1"`

_Fix 1 did compile 1 out of 3 different files with this same issue_

#### Fix 2
You can pad each extract by 0.05s at the start and end to avoid “zero-length” edge cases:

Right before your ffmpeg line, add:
```
if ($end - $start -lt 0.1) { $end = $start + 0.2 }
$startAdj = [math]::Max($start - 0.05, 0)
$endAdj = $end + 0.05
```
Then use `$startAdj` and `$endAdj`:
```
ffmpeg -v quiet -i "$InputFile" -ss $startAdj -to $endAdj -acodec libmp3lame -qscale:a 2 -metadata title="$title" "$outFile"
```

Alternatively: 
Direct: 		`.\Split-M4B-Chapters-Fix-2.ps1 -InputFile "C:\Downloads\File.m4b"`
Interactive: 	`.\Split-M4B-Chapters-Prompt-Fix-2.ps1"`

#### Fix 3
Output M4A instead of MP3

Replace these file lines
```
$outFile = Join-Path $OutputDir "$safeTitle.m4a"
ffmpeg -v quiet -i "$InputFile" -ss $start -to $end -c:a aac -b:a 128k -metadata title="$title" "$outFile"
```

Alternatively: 
Direct: 		`.\Split-M4B-Chapters-Fix-3.ps1 -InputFile "C:\Downloads\File.m4b"`
Interactive: 	`.\Split-M4B-Chapters-Prompt-Fix-3.ps1"`

