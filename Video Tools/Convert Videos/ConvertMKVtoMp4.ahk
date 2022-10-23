FileSelectFolder, Folder, % A_ScriptDir
Folder := RegExReplace(Folder, "\\$")
SetFormat, float, 0.1
Global totalFileSize
Global FileSize
Global name
Global Fname
Global A
SplitPath, Folder, name
Num = 0
If !Num := GetFileNumbers(Folder, Num)
  {
   MsgBox, No MKVs Here.
   ExitApp
  }

if !FileExist(ffmpeg.exe)
    InstallFFMpeg()

Loop Files, %Folder%\*.mkv, R
  {
   A := A_Index
   Fname := A_LoopFileName
   FileGetSize, ifs, % Fname
   totalFileSize := ifs
   FileSize := Round(totalFileSize/1000000)
   SetTimer, MonitorSize, 100
   RunWait %comspec% /c ffmpeg -i "%A_LoopFileFullPath%" -codec copy "%name%%A%.mp4",, HIDE
   Progress, 100, 100`% done (%FileSize% MB), Converting %Fname%
   SetTimer, MonitorSize, Off
  }
MsgBox, 262144,, Completed

GetFileNumbers(Folder, Num)
{
 Loop Files, %Folder%\*.mkv, R
  {
   Num := A_Index
  }
  Return Num
}

MonitorSize()
{
  FileGetSize, fs, % name . A . ".mp4"
  b += 0
  g := Floor(fs/totalFileSize * 100)
  b := Floor(fs/totalFileSize * 10000)/100
  f := Round(fs/1000000)
  Progress, %g%, %b%`% done (%f% MB), Converting %Fname%
}

InstallFFMpeg()
{
 FileInstall, ffmpeg.exe, ffmpeg.exe
}