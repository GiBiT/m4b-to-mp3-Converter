# M4B to MP3 Splitter/Converter
Takes a M4B file and split it into MP3 chapters. 

Works well to separate Audiobooks into a Plex Tracklist

## Requirements
- ffmpeg
- Windows Powershell
- mp3tag (if you want to rename the chapters)


## How to Run

### Interactive Mode
1. Open Windows Powershell
2. Run `.\Split-M4B-Chapters.ps1` or paste the contents of the `.ps1`
3. Type the Filepath as your input file (ex. C:\Downloads\File.m4b)
4. Wait for it to complete
5. You'll see a folder created in the same location as your input file that is suffixed with `-chapters`

#### Troubleshooting
If you get an error regarding Unauthorized. Try this: `powershell -ExecutionPolicy Bypass -Command "& '.\Split-M4B-Chapters.ps1'"`

Sometimes if you just take the content of the ps1 and copy/paste it into a powershell environment, it'll work. 

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

