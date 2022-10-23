#NoTrayIcon
SetBatchLines, -1
if !FileExist(texconv.exe)
    InstallTexConv()

Global Size
Global F
Gui, Add, GroupBox, x2 y-1 w440 h50, Data Folder
Gui, Add, Edit, +ReadOnly vPath x12 y19 w310 h20
Gui, Add, GroupBox, x2 y49 w440 h60, Resolution
Gui, Add, Radio, gGet x12 y69 w70 h30, 512x512
Gui, Add, Radio, gGet x82 y69 w80 h30, 1024x1024
Gui, Add, Radio, gGet x162 y69 w80 h30, 2048x2048
Gui, Add, Radio, gGet x242 y69 w80 h30, 4096x4096
Gui, Add, Button, gBrowse x332 y19 w100 h20, Browse
Gui, Add, Button, gConvert x332 y69 w100 h30, Convert
Gui, Add, GroupBox, x2 y109 w440 h50, Current File
Gui, Add, Edit, +ReadOnly vFiles x12 y129 w420 h20
Gui, Show, w452 h173,DDS Converter
return


Get()
{
 Size := A_GuiControl, Size := StrSplit(Size, "x"), Size := Size[1]
 If Size > 1024
    MsgBox % "Warning setting texture size larger then 1024 may cause the game to lag"
 return Size
}

Browse()
{
 FileSelectFolder, Folder
 if Folder =
   {
    MsgBox, You didn't select a folder.
    return
   }
 GuiControl,, path, %Folder% 
 GetStructure(Folder)
}

GetStructure(Folder)
{
 DisableC()
 Loop, Files, %Folder%\*.*, DR
      {
       F .= A_LoopFileDir . "`n"
       GuiControl,, Files, % "Generating Structure - Folder Number (" . A_Index . ")"
      }
 Sort, F, U
 GuiControl,, Files, % "Ready.."
 EnableC()
}

Convert()
{
 If CheckF()
    {
     MsgBox % "Please select Data Directory First."
     return
    }
 If CheckSize()
    {
     MsgBox % "Please select a Size First."
     return
    }


 DisableC()
 DisableRad()
 Loop, parse, F, `n, `r
   {
   Loop Files, %A_LoopField%\*.dds
    {
     RunWait %comspec% /c "texconv.exe -w "%Size%" -h "%Size%" -m "1" -y -f "DXT5" "%A_LoopFileFullPath%" -o "%A_LoopField%"",, HIDE
     GuiControl,, Files, % "Processing " . A_LoopFileFullPath
   }
  }
 EnableC()
 EnableRad()
 GuiControl,, Files, Complete
}

InstallTexConv()
{
 FileInstall, texconv.exe, texconv.exe
}

DisableC()
{
 GuiControl, Disable, Browse
 GuiControl, Disable, Convert
}

EnableC()
{
 GuiControl, Enable, Browse
 GuiControl, Enable, Convert
}

DisableRad()
{
 GuiControl, Disable, 512x512
 GuiControl, Disable, 1024x1024
 GuiControl, Disable, 2048x2048
 GuiControl, Disable, 4096x4096
}

EnableRad()
{
 GuiControl, Enable, 512x512
 GuiControl, Enable, 1024x1024
 GuiControl, Enable, 2048x2048
 GuiControl, Enable, 4096x4096
}

CheckSize()
{
 if Size =
   {
    return 1
   }
}

CheckF()
{
 if F =
   {
    return 1
   }
}

GuiClose:
ExitApp