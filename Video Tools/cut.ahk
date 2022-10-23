Gui, Cut:Add, GroupBox, x12 y-1 w320 h165
Gui, Cut:Add, GroupBox, x22 y19 w300 h50 , Video
Gui, Cut:Add, Edit, vFile x32 y39 w210 h20 , 
Gui, Cut:Add, Button, gBrowse x242 y39 w70 h20 , Browse
Gui, Cut:Add, GroupBox, x22 y69 w300 h80 , Options
Gui, Cut:Add, GroupBox, x22 y89 w100 h50 , Start Time
Gui, Cut:Add, Edit, vStart x32 y109 w80 h20 , 00:00:00
Gui, Cut:Add, GroupBox, x122 y89 w100 h50 , End Time
Gui, Cut:Add, Edit, vEnd x132 y109 w80 h20 , 00:00:00
Gui, Cut:Add, GroupBox, x222 y89 w100 h50,
Gui, Cut:Add, Button, gMake x232 y109 w80 h20 ,Make
Gui, Cut:Show, w347 h175, Cut Video
return

Make()
{
  GuiControlGet, ST,Cut:, Start
  GuiControlGet, EN,Cut:, End
  GuiControlGet, NM,Cut:, File
  N := GetName(NM)
  E := GetWebmExt(NM)
     If E = .mkv
        RunWait %comspec% /c ffmpeg -ss %ST% -i "%NM%" -to %EN% -c copy "%A_WorkingDir%\%N%\%N%%E%"
     If E = .mp4
        RunWait %comspec% /c ffmpeg -ss %ST% -i "%NM%" -to %EN% -c copy "%A_WorkingDir%\%N%\%N%%E%"
     If E = webm
        RunWait %comspec% /c ffmpeg -ss %ST% -i "%NM%" -to %EN% -c copy "%A_WorkingDir%\%N%\%N%.webm"
      MsgBox, 262144,, Completed
}

GetName(NM)
{
 SplitPath, NM, name
 Name := SubStr(Name, 1, (Str := StrLen(Name) -4))
 FileCreateDir, % Name
 return Name
}

GetWebmExt(Extention)
{
 Extention := SubStr(Extention, (Str := StrLen(Extention)-3),4)
 return Extention
}

Browse()
{
 FileSelectFile, SelectedFile, 3
 GuiControl,Cut: , File, % SelectedFile
}

CutGuiClose:
ExitApp
Return
