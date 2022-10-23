if !FileExist("ffmpeg.exe")
    InstallFFMpeg()

FileSelectFolder, Folder
Folder := RegExReplace(Folder, "\\$")
SplitPath, Folder, name
Num = 0
If !Num := GetFileNumbers(Folder, Num)
  {
   MsgBox, No webms Here.
   ExitApp
  }

Loop Files, %Folder%\*.webm
  {
   Name := SubStr(A_LoopFileName, 1, (Str := StrLen(A_LoopFileName) -4))
   Progress, m2 b fs10 zh0, % A_LoopFileName A_Space A_Index . "/" . Num, , , Courier New
   RunWait %comspec% /c ffmpeg -i "%A_LoopFileFullPath%" -strict experimental "%Name%.mp4"
    ;RunWait %comspec% /c ffmpeg -i "%A_LoopFileFullPath%" -c:v libvpx-vp9 -crf 33 -b:v 0 -c:a libopus "%Name%.webm"
  }
MsgBox, 262144,, Completed
ExitApp

GetFileNumbers(Folder, Num)
{
 Loop Files, %Folder%\*.webm, R
  {
   Num := A_Index
  }
  Return Num
}

InstallFFMpeg()
{
 MsgBox, FFmpeg.exe missing from directory
 ExitApp
}