#NoTrayIcon

Gui, Add, GroupBox, x2 y-1 w240 h50 , Watermark
Gui, Add, Edit, vWater x12 y19 w130 h20 ,
Gui, Add, Button, gWaterBrowse x152 y19 w80 h20 , Browse
Gui, Add, GroupBox, x242 y-1 w240 h50 , Video
Gui, Add, Edit, vVid x252 y19 w130 h20 , 
Gui, Add, Button, gVideoBrowse x392 y19 w80 h20 , Browse
Gui, Add, GroupBox, x482 y-1 w110 h50, 
Gui, Add, Button, gMark x492 y19 w90 h20 , Mark It
Gui, Add, GroupBox, x2 y49 w480 h50 , Position
Gui, Add, CheckBox, gCheckMark vC x12 y69 w70 h20 , Center
Gui, Add, CheckBox, gCheckMark vTL x92 y69 w70 h20 , Top Left
Gui, Add, CheckBox, gCheckMark vTR x182 y69 w70 h20 , Top Right
Gui, Add, CheckBox, gCheckMark vBR x282 y69 w80 h20 , Bottom Right
Gui, Add, CheckBox, gCheckMark vBL x392 y69 w70 h20 , Bottom Left
Gui, Add, GroupBox, x482 y49 w110 h50,Scale
Gui, Add, Edit, vS x492 y69 w90 h20 ,1
Gui, Show, w601 h105, Water Maker
if !FileExist(ffmpeg.exe)
    InstallFFMpeg()
return

CheckMark()
{
 CK := A_GuiControl
 If CK := "C"
    {
     GuiControl,, TL, 0
     GuiControl,, TR, 0
     GuiControl,, BR, 0
     GuiControl,, BL, 0
    }
 If CK := "TL"
    {
     GuiControl,, C, 0
     GuiControl,, TR, 0
     GuiControl,, BR, 0
     GuiControl,, BL, 0
    }
 If CK := "TR"
    {
     GuiControl,, C, 0
     GuiControl,, TL, 0
     GuiControl,, BR, 0
     GuiControl,, BL, 0
    }
 If CK := "BR"
    {
     GuiControl,, C, 0
     GuiControl,, TL, 0
     GuiControl,, TR, 0
     GuiControl,, BL, 0
    }
 If CK := "BL"
    {
     GuiControl,, C, 0
     GuiControl,, TL, 0
     GuiControl,, TR, 0
     GuiControl,, BR, 0
    }

GuiControl,, %A_GuiControl%, 1
Return CK
}

Mark()
{
 If CheckBox()
 {
  GuiControlGet, S
  GuiControlGet, C
  GuiControlGet, TL
  GuiControlGet, TR
  GuiControlGet, BR
  GuiControlGet, BL
  GuiControlGet, Water
  GuiControlGet, Vid
  If (TL = "1")
     RunWait %comspec% /c ffmpeg -i %Vid% -i %Water% -filter_complex "[1]scale=iw*0.%S%:-1[wm];[0][wm]overlay=10:10" "%A_WorkingDir%\WaterMarked(TopLeft)_%Vid%"
  If (TR = "1")
     RunWait %comspec% /c ffmpeg -i %Vid% -i %Water% -filter_complex "[1]scale=iw*0.%S%:-1[wm];[0][wm]overlay=main_w-overlay_w-10:10" "%A_WorkingDir%\WaterMarked(TopRight)_%Vid%"
  If (BL = "1")
     RunWait %comspec% /c ffmpeg -i %Vid% -i %Water% -filter_complex "[1]scale=iw*0.%S%:-1[wm];[0][wm]overlay=10:main_h-overlay_h-10" "%A_WorkingDir%\WaterMarked(BottomLeft)_%Vid%"
  If (BR = "1")
     RunWait %comspec% /c ffmpeg -i %Vid% -i %Water% -filter_complex "[1]scale=iw*0.%S%:-1[wm];[0][wm]overlay=main_w-overlay_w-10:main_h-overlay_h-10" "%A_WorkingDir%\WaterMarked(BottomRight)_%Vid%"
  If (C = "1")
     RunWait %comspec% /c ffmpeg -i %Vid% -i %Water% -filter_complex "[1]scale=iw*0.%S%:-1[wm];[0][wm]overlay=main_w/2-overlay_w/2:main_h/2-overlay_h/2" "%A_WorkingDir%\WaterMarked(Center)_%Vid%"
  MsgBox, 262144,, Completed
 }
}

CheckBox()
{
GuiControlGet, Water
if (Water = "")
   {
    MsgBox, didn't select anything.
    Return 0
   }
Return 1
}

WaterBrowse()
{
 FileSelectFile, SelectedFile
 SplitPath, SelectedFile, name
 GuiControl,, Water, % name
}

VideoBrowse()
{
 FileSelectFile, SelectedFile
 SplitPath, SelectedFile, name
 NoSpaces := StrReplace(name, A_Space, "")
 GuiControl,, Vid, % NoSpaces
 FileMove, %name%, %NoSpaces%
}

InstallFFMpeg()
{
 FileInstall, ffmpeg.exe, ffmpeg.exe
}

GuiClose:
ExitApp