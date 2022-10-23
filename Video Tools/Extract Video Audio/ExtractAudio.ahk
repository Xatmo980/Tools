#NoTrayIcon

Gui, Add, GroupBox, x12 y-1 w400 h90
Gui, Add, GroupBox, x22 y19 w380 h50 , Video
Gui, Add, Edit, vFile x32 y39 w210 h20 , 
Gui, Add, Button, x242 y39 w70 h20 , Browse
Gui, Add, Button, x322 y39 w70 h20 ,Extract
Gui, Show, w420 h90, Extract Audio
if !FileExist(ffmpeg.exe)
    InstallFFMpeg()
return

ButtonBrowse:
FileSelectFile, SelectedFile, 3
If CheckBox(SelectedFile)
{
 SplitPath, SelectedFile, name
 Name := SubStr(Name, 1, (Str := StrLen(Name) -4))
 FileCreateDir, % Name
 GuiControl,, File, % Name
}
Return

ButtonExtract:
If CheckBox(SelectedFile)
{
 RunWait %comspec% /c ffmpeg -i "%SelectedFile%" -q:a 0 -map a "%A_WorkingDir%\%Name%\%Name%.mp3"
 MsgBox, 262144,, Completed
}
Return

InstallFFMpeg()
{
 FileInstall, ffmpeg.exe, ffmpeg.exe
}

CheckBox(SelectedFile)
{
if (SelectedFile = "")
   {
    MsgBox, didn't select anything.
    Return 0
   }
Return 1
}

GuiClose:
ExitApp