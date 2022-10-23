#NoTrayIcon

Gui, Add, GroupBox, x12 y-1 w320 h200
Gui, Add, GroupBox, x22 y19 w300 h50 , Video
Gui, Add, Edit, vFile x32 y39 w210 h20 , 
Gui, Add, Button, x242 y39 w70 h20 , Browse
Gui, Add, GroupBox, x22 y69 w300 h120 , Options
Gui, Add, GroupBox, x22 y89 w100 h50 , Start Time
Gui, Add, Edit, vStart x32 y109 w80 h20 , 00:00:00
Gui, Add, GroupBox, x122 y89 w100 h50 , End Time
Gui, Add, Edit, vEnd x132 y109 w80 h20 , 00:00:00 
Gui, Add, GroupBox, x222 y89 w100 h50 , Size
Gui, Add, Edit, vSize x232 y109 w80 h20 , 350
Gui, Add, GroupBox, x22 y139 w100 h50 , Frame Rate
Gui, Add, Edit, vRate x32 y159 w80 h20 , 10
Gui, Add, GroupBox, x122 y139 w100 h50 , FPS
Gui, Add, Edit, vFPS x132 y159 w80 h20 , 10
Gui, Add, Button, x232 y149 w80 h30 ,Make
Gui, Show, w347 h212, Vid To Gif
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


ButtonMake:
If CheckBox(SelectedFile)
{
 GuiControlGet, Rate
 GuiControlGet, Size
 GuiControlGet, FPS
 GuiControlGet, Start
 GuiControlGet, End
RunWait %comspec% /c ffmpeg -i "%SelectedFile%" -r %Rate% -vf "scale=%Size%:-1`,fps=%FPS%`,split[s0][s1]`;[s0]palettegen[p]`;[s1][p]paletteuse" -ss %Start% -to %End% "%A_WorkingDir%\%Name%\%Name%.mp4"
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