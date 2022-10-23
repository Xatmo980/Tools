#NoTrayIcon
Global H
Global M
Global S

if !FileExist(ffmpeg.exe)
    FileInstall, ffmpeg.exe, ffmpeg.exe
Sleep, 1000

Gui, Add, GroupBox, vFileFolder x2 y-1 w360 h50, File
Gui, Add, GroupBox, x362 y-1 w90 h50, Ext
Gui, Add, Edit, +ReadOnly vSelect x12 y19 w270 h20, 
Gui, Add, Button, gBrowse x292 y19 w60 h20, Browse
Gui, Add, Edit, vExt x372 y19 w70 h20, mp3
Gui, Add, GroupBox, x2 y99 w540 h50, Playing
Gui, Add, Edit, +ReadOnly vPlaying x12 y119 w520 h20
Gui, Add, Button, gStart x462 y19 w70 h20, Start
Gui, Add, GroupBox, x452 y-1 w90 h50, 
Gui, Add, GroupBox,  x2 y49 w360 h50, Stream Address
Gui, Add, GroupBox, x362 y49 w90 h50, Port
Gui, Add, Edit, vAdd x12 y69 w340 h20,rtmp://
Gui, Add, Edit, vPort x372 y69 w70 h20, 1935
Gui, Add, GroupBox, x452 y49 w90 h50 , Folder?
Gui, Add, CheckBox, gChange vBox x472 y69 w60 h20 , Yes
Gui, Show, w551 h159,Mini Streamer
return

Browse:
GuiControlGet, A,, Box
If A = 1
  {
   FileSelectFolder, Selection
   GuiControl,, Select, % Selection
  }
else
  {
   FileSelectFile, Selection, 3
   GuiControl,, Select, % Selection
  }
return

Start()
{
 GuiControlGet, Selection,, Select
 GuiControlGet, Ex,, Ext
 GuiControlGet, Ad,, Add
 If Checker(Selection)
 {
  GuiControlGet, Chk,, Box
  Disable()
  If Chk = 1
   {
    Loop Files, %Selection%\*.%Ex%
    {
     T := GetTime(file := A_LoopFileFullPath)
     GuiControl,, Playing, % N := GetName(A_LoopFileName) A_Space "- Length (" . T . ")"
     Split := StrSplit(T, ":")
     H := Split[1], M := Split[2], S := Split[3]
     SetTimer, Timer, 1000
     RunWait %comspec% /c "ffmpeg.exe -re -i "%A_LoopFileFullPath%" -vcodec libx264 -acodec aac -f flv "%Ad%" ",, HIDE
     SetTimer, Timer, off
    }
   }
  else
   {
    T := GetTime(file := Selection)
    GuiControl,, Playing, % N := GetName(Selection) A_Space "- Length (" . T . ")"
    Split := StrSplit(T, ":")
    H := Split[1], M := Split[2], S := Split[3]
    SetTimer, Timer, 1000
    RunWait %comspec% /c "ffmpeg.exe -re -i "%Selection%" -vcodec libx264 -acodec aac -f flv "%Ad%" ",, HIDE
    SetTimer, Timer, off
   }
  Enable()
 }
}

GetTime(vPath)
{
vLength := JEE_FileGetDetail(vPath, "Length")
    if !(vLength = "")
       vOutput .= vLength "`t"

return vOutput
}

JEE_FileGetDetail(vPath, vDetail)
{
	static oArray := {}
	if !FileExist(vPath)
		return
	SplitPath, vPath, vName, vDir
	oShell := ComObjCreate("Shell.Application")
	oFolder := oShell.Namespace(vDir "\")
	oFilename := oFolder.Parsename(vName)
	if oArray.HasKey("z" vDetail)
	{
		vValue := oFolder.GetDetailsOf(oFilename, oArray["z" vDetail])
		oShell := oFolder := oFilename := ""
		return vValue
	}
	Loop
	{
		vDetail2 := oFolder.GetDetailsOf(oFolder.Items, A_Index-1)
		if (vDetail2 = "")
			break
		if (vDetail = vDetail2)
		{
			vValue := oFolder.GetDetailsOf(oFilename, A_Index-1)
			oArray["z" vDetail] := A_Index-1
			break
		}
	}
	oShell := oFolder := oFilename := ""
	return vValue
}

Timer:
 S--
  If S < 1
    {
     S=59
     if M > 0
        M--
    }
  If M < 1
    {
     if H > 0
       {
        M=59
        H--
       }
    }
WinSetTitle, Mini Streamer,, %  "Mini Streamer - " . H . ":" . M . ":" . S
return

Checker(Selection)
{
if (Selection = "")
   {
    MsgBox, didn't select anything.
    Return 0
   }
Return 1
}

Change()
{
 GuiControlGet, C,, %A_GuiControl%
  If C = 1
     GuiControl,, FileFolder, Folder
  else
     GuiControl,, FileFolder, File
}

GetName(Path)
{
 SplitPath, Path, name
 Return name
}

Disable()
{
  GuiControl, Disable, Browse
  GuiControl, Disable, Start
  GuiControl, Disable, Port
  GuiControl, Disable, Yes
  GuiControl, Disable, Add
  GuiControl, Disable, Ext
}

Enable()
{
 GuiControl, Enable, Browse
 GuiControl, Enable, Start
 GuiControl, Enable, Port
 GuiControl, Enable, Yes
 GuiControl, Enable, Add
 GuiControl, Enable, Ext
}

GuiClose:
ExitApp