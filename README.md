# M4B to MP3 Splitter/Converter
Take an M4A or M4B file and split it into MP3 chapters. 

Works well to separate Audiobooks into a Plex Tracklist

## Requirements
- ffmpeg
- Windows Powershell
- mp3tag (if you want to rename the chapters)


## How to Run

Interactive Mode
1. Open Powershell
2. Run `.\Split-M4B-Chapters.ps1` or paste the contents of the `.ps1`
3. Type the Filepath (ex. C:\Downloads\File.m4b)
4. Wait for it to complete

Direct Command Mode
1. Open Powershell
2. Run `.\Split-M4B-Chapters.ps1 -InputFile "C:\Downloads\File.m4b"`
3. Wait for it to complete

The issue with the "Direct Command Mode" is that you may not have the right file permissions. To solve that:
1. Open Powershell
2. Type `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
3. Then re-run the command

Another possible fix if you're getting issues getting it to run: (Obviously Replace {File} with your filename)
`powershell -ExecutionPolicy Bypass -Command "& '.\Split-M4B-Chapters.ps1' -InputFile 'File.m4b'"`

## How It Works
1. Once you run that code it will take any chapters that it finds in the input file and convert it to individual mp3 files (unless you're running Fix-2 which converts to m4a).
2. It will try and find an existing Chapter Name and if it finds one it will use that.
3. If it does not find a Chapter Name your Chapter title will be `001` and increment in that format.

- To add/fix the titles, download [mp3tag](https://www.mp3tag.de/en/) and copy all the files into it
- Once you do that press `Control + A` and then `Control + Shift + K` and the Auto-numbering Wizard will pop up to add Track Numbers and/or Discnumber 
<img width="539" height="437" alt="image" src="https://github.com/user-attachments/assets/5aa4656e-1786-46c9-a5f8-497e672fcefd" />

To rename the chapters you can do several things:
1. Press `Control + A` to highlight all, then right click and Choose `Convert > Tag Tag`
<img width="656" height="512" alt="image" src="https://github.com/user-attachments/assets/6ddbe560-da61-4444-99c1-843ed7dfefd4" />

2. Then you can use the track to rename each track. So if your book starts at Chapter 1, it's simple:
<img width="407" height="279" alt="image" src="https://github.com/user-attachments/assets/1d0829de-0eac-40de-aa70-18b3ae4ee60e" />

3. If your book does not start with Chapter 1, for example a prologue you can highlight all chapters except `001` and do this in the "Format string:" input `Chapter $sub(%track%,1)` and you can adjust your `$sub(%track%,1)` to `$sub(%track%,2)` if you want to go two chapters back, or even use the title instead of the track like this: `Chapter $sub(%title%,1)`

_If you want to organize for Plex and you want to separate the book into parts, you can do so by adjusting the Discnumber. Just remember if you want Discnumber to work in Plex, you have to restart the Track at 1 per new discnumber_

## Known Issue(s)

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

Alternatively: Run `.\Split-M4B-Chapters-Fix-1.ps1 -InputFile "C:\Downloads\File.m4b"` 

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

Alternatively: Run `.\Split-M4B-Chapters-Fix-2.ps1 -InputFile "C:\Downloads\File.m4b"` 

#### Fix 3
Output M4A instead of MP3

Replace these file lines
```
$outFile = Join-Path $OutputDir "$safeTitle.m4a"
ffmpeg -v quiet -i "$InputFile" -ss $start -to $end -c:a aac -b:a 128k -metadata title="$title" "$outFile"
```

Alternatively: Run `.\Split-M4B-Chapters-Fix-3.ps1 -InputFile "C:\Downloads\File.m4b"` 

