# m4b-to-mp3-Converter
Take an M4A or M4B file and split it into MP3 chapters

## How to Run

Interactive Mode
1. Open Powershell
2. Run `.\Split-M4B-Chapters.ps1` or paste the contents of the `.ps1`
3. Type the Filepath (ex. C:\Downloads\File.m4b)
4. Wait for it to complete

Direct Command Mode
1. Open Powershell
2. Run `.\Split-M4B-Chapters.ps1 -InputFile "C:\Downloads\File.m4b.m4b"`
3. Wait for it to complete

The issue with the "Direct Command Mode" is that you may not have the right file permissions. To solve that:
1. Open Powershell
2. Type `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
3. Then re-run the command

## Known Issue(s)

`Assertion failed: vbrsf[sfb] >= vbrsfmin[sfb], file ../../lame-3.100/libmp3lame/vbrquantize.c, line 783`

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
Fix 1 did compile 1 out of 3 different files with this same issue

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

#### Fix 3
Output M4A instead of MP3

Replace these file lines
```
$outFile = Join-Path $OutputDir "$safeTitle.m4a"
ffmpeg -v quiet -i "$InputFile" -ss $start -to $end -c:a aac -b:a 128k -metadata title="$title" "$outFile"
```
