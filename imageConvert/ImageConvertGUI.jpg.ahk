#NoTrayIcon
Global SelectedFolder
Global SelectedFile
if !FileExist(convert.exe)
    FileInstall, convert.exe, convert.exe

Gui, Add, GroupBox, vGB x2 y-1 w590 h50 , File
Gui, Add, Edit, +ReadOnly vFF x12 y19 w310 h20
Gui, Add, Button, gBrowse x322 y19 w90 h20 , Browse
Gui, Add, Button, gConvert x412 y19 w90 h20 , Convert
Gui, Add, GroupBox, x2 y49 w590 h50 , From
Gui, Add, GroupBox, x2 y99 w590 h50 , To
Gui, Add, Checkbox, gCheckMarkTop vJ x12 y69 w70 h20 , jpg
Gui, Add, Checkbox, gCheckMarkTop vP x82 y69 w70 h20 , png
Gui, Add, Checkbox, gCheckMarkTop vW x152 y69 w70 h20 , webp
Gui, Add, Checkbox, gCheckMarkTop vD x222 y69 w70 h20 , dds
Gui, Add, Checkbox, gCheckMarkTop vT x292 y69 w70 h20 , tga
Gui, Add, Checkbox, gCheckMarkTop vTi x362 y69 w70 h20 , tiff
Gui, Add, Checkbox, gCheckMarkBottom vJ2 x12 y119 w70 h20 , jpg
Gui, Add, Checkbox, gCheckMarkBottom vP2 x82 y119 w70 h20 , png
Gui, Add, Checkbox, gCheckMarkBottom vW2 x152 y119 w70 h20 , webp
Gui, Add, Checkbox, gCheckMarkBottom vD2 x222 y119 w70 h20 , dds
Gui, Add, Checkbox, gCheckMarkBottom vT2 x292 y119 w70 h20 , tga
Gui, Add, Checkbox, gCheckMarkBottom vTi2 x362 y119 w70 h20 , tiff
Gui, Add, Checkbox, gCheckMarkTop vC x432 y69 w70 h20 , Custom
Gui, Add, Checkbox, gCheckMarkBottom vC2 x432 y119 w70 h20 , Custom
Gui, Add, Edit, vGC x502 y69 w80 h20
Gui, Add, Edit, vGC2 x502 y119 w80 h20
Gui, Add, Checkbox, gCheckMarkFolder vFold x512 y19 w70 h20 , Folder?
Gui, Show, w598 h156,Image Convert
return

Browse()
{
 GuiControlGet, CF,, Fold
 If CF = 1
  {
   FileSelectFolder, SelectedFolder
   GuiControl,, FF, % SelectedFolder
   return SelectedFolder
  }
 else
  {
   FileSelectFile, SelectedFile
   GuiControl,, FF, % SelectedFile
   return SelectedFile
  }
}

Convert()
{
 GT := GetTop()
 GBo := GetBottom()
 GuiControlGet, CV,, Fold
 If CV = 1
 {
   Loop Files, % SelectedFolder . "\*." . GT
    {
     RF := RemoveExt(A_LoopFileName)
     RunWait %comspec% /c convert.exe "%A_LoopFileFullPath%" -auto-orient "%A_LoopFileDir%\%RF%.%GBo%",, HIDE
    }
  MsgBox % "Converted All " . GT . " -> " . GBo . "in folder " . SelectedFolder
 }
 else
 {
  SplitPath, SelectedFile, name, dir
  R := RemoveExt(name)
  RunWait %comspec% /c convert.exe "%dir%\%R%.%GT%" -auto-orient "%dir%\%R%.%GBo%",, HIDE
  MsgBox % "Converted File " . R . GT . " -> " . R . "." . GBo
 }
}

CheckMarkFolder()
{
 GuiControlGet, CC,, %A_GuiControl%
  If CC = 1
     GuiControl,, GB, Folder
  else
     GuiControl,, GB, File
}

GetTop()
{
 GuiControlGet, T,, J
 If T = 1
    Return "jpg"
 GuiControlGet, T,, P
 If T = 1
    Return "png"
 GuiControlGet, T,, W
 If T = 1
    Return "webp"
 GuiControlGet, T,, D
 If T = 1
    Return "dds"
 GuiControlGet, T,, T
 If T = 1
    Return "tga"
 GuiControlGet, T,, Ti
 If T = 1
    Return "tiff"
 GuiControlGet, T,, C
 If T = 1
   {
    GuiControlGet, CE,, GC
    Return CE
   }
}

GetBottom()
{
 GuiControlGet, B,, J2
 If B = 1
    Return "jpg"
 GuiControlGet, B,, P2
 If B = 1
    Return "png"
 GuiControlGet, B,, W2
 If B = 1
    Return "webp"
 GuiControlGet, B,, D2
 If B = 1
    Return "dds"
 GuiControlGet, B,, T2
 If B = 1
    Return "tga"
 GuiControlGet, B,, Ti2
 If B = 1
    Return "tiff"
 GuiControlGet, B,, C2
 If B = 1
   {
    GuiControlGet, CE2,, GC2
    Return CE2
   }
}

CheckMarkTop()
{
 CT := A_GuiControl
 If CT := "J"
    {
     GuiControl,, P, 0
     GuiControl,, W, 0
     GuiControl,, D, 0
     GuiControl,, T, 0
     GuiControl,, C, 0
     GuiControl,, Ti, 0
    }
 If CT := "P"
    {
     GuiControl,, J, 0
     GuiControl,, W, 0
     GuiControl,, D, 0
     GuiControl,, T, 0
     GuiControl,, C, 0
     GuiControl,, Ti, 0
    }
 If CT := "W"
    {
     GuiControl,, J, 0
     GuiControl,, P, 0
     GuiControl,, D, 0
     GuiControl,, T, 0
     GuiControl,, C, 0
     GuiControl,, Ti, 0
    }
 If CT := "D"
    {
     GuiControl,, J, 0
     GuiControl,, P, 0
     GuiControl,, W, 0
     GuiControl,, T, 0
     GuiControl,, C, 0
     GuiControl,, Ti, 0
    }
 If CT := "T"
    {
     GuiControl,, J, 0
     GuiControl,, P, 0
     GuiControl,, W, 0
     GuiControl,, D, 0
     GuiControl,, C, 0
     GuiControl,, Ti, 0
    }
 If CT := "Ti"
    {
     GuiControl,, J, 0
     GuiControl,, P, 0
     GuiControl,, W, 0
     GuiControl,, D, 0
     GuiControl,, C, 0
     GuiControl,, T, 0
    }
 If CT := "C"
    {
     GuiControl,, J, 0
     GuiControl,, P, 0
     GuiControl,, W, 0
     GuiControl,, D, 0
     GuiControl,, T, 0
     GuiControl,, Ti, 0
    }

GuiControl,, %A_GuiControl%, 1
}

CheckMarkBottom()
{
 CB := A_GuiControl
 If CB := "J2"
    {
     GuiControl,, P2, 0
     GuiControl,, W2, 0
     GuiControl,, D2, 0
     GuiControl,, T2, 0
     GuiControl,, C2, 0
     GuiControl,, Ti2, 0
    }
 If CB := "P2"
    {
     GuiControl,, J2, 0
     GuiControl,, W2, 0
     GuiControl,, D2, 0
     GuiControl,, T2, 0
     GuiControl,, C2, 0
     GuiControl,, Ti2, 0
    }
 If CB := "W2"
    {
     GuiControl,, J2, 0
     GuiControl,, P2, 0
     GuiControl,, D2, 0
     GuiControl,, T2, 0
     GuiControl,, C2, 0
     GuiControl,, Ti2, 0
    }
 If CB := "D2"
    {
     GuiControl,, J2, 0
     GuiControl,, P2, 0
     GuiControl,, W2, 0
     GuiControl,, T2, 0
     GuiControl,, C2, 0
     GuiControl,, Ti2, 0
    }
 If CB := "T2"
    {
     GuiControl,, J2, 0
     GuiControl,, P2, 0
     GuiControl,, W2, 0
     GuiControl,, D2, 0
     GuiControl,, C2, 0
     GuiControl,, Ti2, 0
    }
 If CB := "Ti2"
    {
     GuiControl,, J2, 0
     GuiControl,, P2, 0
     GuiControl,, W2, 0
     GuiControl,, D2, 0
     GuiControl,, C2, 0
     GuiControl,, T2, 0
    }
 If CB := "C2"
    {
     GuiControl,, J2, 0
     GuiControl,, P2, 0
     GuiControl,, W2, 0
     GuiControl,, D2, 0
     GuiControl,, T2, 0
     GuiControl,, Ti2, 0
    }

GuiControl,, %A_GuiControl%, 1
}

RemoveExt(name)
{
 E := SubStr(name, -5)
 If E = .webp
   ER := SubStr(name, 1, L := StrLen(name) -5)
 else
   ER := SubStr(name, 1, L := StrLen(name) -4)

 return ER
}

GuiClose:
ExitApp