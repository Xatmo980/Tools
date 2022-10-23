#NoTrayIcon
RestoreWorkingDir()
if !FileExist("Game.ini")
   {
    FileCreateDir, sounds
    InstallSounds()
    MsgBox % "Please Drag your game exe onto the gui interface to add them"
   }

Gui, Color , 808080
Gui, Add, GroupBox, vPanel x12 y-1 w200 h545, Panel
LoadGamesGuiIcons()
Gui, Show, w226 h555,GameLauncher
return

GuiDropFiles:
 A := GetIniIndex()
   If A > 15
     {
      MsgBox % "Maximux Programs Reached Sorry"
      Return
     }
 FileGetShortcut, %A_GuiEvent%, OutTarget
    If OutTarget
       AddPathLink(OutTarget, A)
    else
       AddPathNormal(A)

LoadGamesGuiIcons()
Return

GuiContextMenu:
If InStr(A_GuiControl, "Panel")
   {
    Gui, C:Add, GroupBox, x2 y-1 w160 h70, Options
    Gui, C:Add, Button, gAddCat x12 y19 w140 h20, Add Category
    Gui, C:Add, Button, gAddUrl x12 y39 w140 h20, Add Url
    Gui, C:Show, w165 h72, Add options
    return
   }
If !InStr(A_GuiControl, "Panel") && !InStr(A_GuiControl, "\")
   {
    MsgBox, 4,, % "Rename" A_Space A_GuiControl . "?"
      IfMsgBox Yes
        {
         If CheckIfCat(A_GuiControl)
           {
            MsgBox % "Sorry Cannot Rename Categories."
            Return
           }
         InputBox, Rename, Renameing, Renameing %A_GuiControl% to?
         if (Rename = "")
            {
             MsgBox, No Changes Made.
             Return
            }
         GuiControl, Text, %A_GuiControl%, %Rename%
         IniWrite, %Rename%, Game.ini, % RTrim(LTrim(SubStr(DD := GetIndexViaName(A_GuiControl), 1, Length := StrLen(A_GuiControl)), "["), "]"), Name
        }
      else
        Return
   }
If InStr(A_GuiControl, "\")
   {
    Gui, Op:Color , 808080
    Gui, Op:Add, GroupBox, x2 y-1 w390 h140, Controls
    Gui, Op:Add, GroupBox, x2 y19 w390 h50, Game
    Gui, Op:Add, Edit, +ReadOnly vGURL x12 y39 w250 h20, % Pa := GetFullPathViaPath(A_GuiControl)
    Gui, Op:Add, Button, gDeleteG x272 y39 w110 h20, Delete From Gui
    Gui, Op:Add, GroupBox, x2 y69 w390 h50, Parameters
    Gui, Op:Add, Edit, vParam x12 y89 w250 h20
    Gui, Op:Add, Button, gRunP x272 y89 w110 h20, Run With Parameters
    Gui, Op:Show, w396 h146, Options
    Return
   }
Return

FolderGUI(Path)
{
 MsgBox % "Folder Gui Here" A_Space A_GuiControl
}

Run()
{ 
 Pa := GetFullPathViaPath(A_GuiControl)
 SplitPath, Pa,, dir
 soundplay, .\sounds\run.mp3
 SetWorkingDir % dir
 If !InStr(Pa, ".exe")
   {
    
   }
else
   {
    Run % Pa
    RestoreWorkingDir()
   }
}

RunP()
{
 GuiControlGet, URL,Op:, GURL
 GuiControlGet, Para,Op:, Param
  if (Para = "")
     {
      MsgBox, Parameters were empty. Failed to run.
      Return
     }
 SplitPath, URL,, dir
 soundplay, .\sounds\run.mp3
 SetWorkingDir % dir
 Gui, Op:Destroy
 Run % URL A_Space Para
 RestoreWorkingDir()
}

DeleteG()
{
 GuiControlGet, URL,Op:, GURL
 IniDelete, Game.ini, % Number := RTrim(LTrim(SubStr(D := GetIndexViaPath(URL), 1, Length := StrLen(D)), "["), "]")
 soundplay, .\sounds\delete.mp3
 Gui, Op:Destroy
      ReInI()

Sleep, 500
Reload
}

ReInI()
{
 Loop, read, Game.ini
 {
    Loop, parse, A_LoopReadLine, %A_Tab%
    {
      Inc++
      If InStr(A_LoopField, "Name")
       {
         V1 := SubStr(A_LoopField, 6, W := StrLen(A_LoopField))
         If !(V1 := "")
           {
            B++
            FileReadLine, Ind, Game.ini, % Inc + 1
            IniList .= "[" . B . "]" . "`n" . "Name=" . V1 := SubStr(A_LoopField, 6, W := StrLen(A_LoopField)) . "`n" . "Path=" . V2 := SubStr(Ind, 6, W := StrLen(Ind)) . "`n"
           }
       }
    }
 }
FileDelete, Game.ini
FileAppend, %IniList%, Game.ini
}

GetIndexViaPath(URL)
{
 Loop, read, Game.ini
 {
    Loop, parse, A_LoopReadLine, %A_Tab%
    {
      Inc++
      If InStr(A_LoopField, URL)
       {
         FileReadLine, Ind, Game.ini, % Inc := Inc - 2
         Return Ind
       }
    }
 }
}

GetIndexViaName(Name)
{
 Loop, read, Game.ini
 {
    Loop, parse, A_LoopReadLine, %A_Tab%
    {
      In++
      If InStr(A_LoopField, Name)
       {
         FileReadLine, Inp, Game.ini, % In := In - 1
         Return Inp
       }
    }
 }
}

GetFullPathViaPath(Path)
{
 Loop, read, Game.ini
 {
    Loop, parse, A_LoopReadLine, %A_Tab%
    {
      In++
      If InStr(A_LoopField, Path)
       {
         FileReadLine, Inp, Game.ini, % In
         Inp := SubStr(Inp, 6, Len := StrLen(Inp))
         Return Inp
       }
    }
 }
}

LoadGamesGuiIcons()
{
 L := GetIniIndex() - 1
 I = 16
 B = 26
 Loop, %L%
 {
  IniRead, Name, Game.ini, %A_Index%, Name
  IniRead, Path, Game.ini, %A_Index%, Path
  Gui, Add, Text, x58 y%B%, % Name
  Gui, Add, Picture, gRun x22 y%I%, % Path
  Gui, Color , 808080
  I := I + 35
  B := B + 35
 }
}

AddPathLink(OutTarget, A)
{
 Loop, %OutTarget%
       ShortPathName := A_LoopFileShortPath 

 InputBox, Name, Game Name, Please Enter the Games name.
    If CheckName(Name)
     {
      IniWrite, %Name%, Game.ini, %A%, Name
      IniWrite, %ShortPathName%, Game.ini, %A%, Path
      soundplay, .\sounds\add.mp3
     }
    else
      MsgBox % "Name was empty failed to add"
}

AddPathNormal(A)
{
 Loop, %A_GuiEvent%
       ShortPathName := A_LoopFileShortPath

 InputBox, Name, Game Name, Please Enter the Games name.
  If CheckName(Name)
   {
    IniWrite, %Name%, Game.ini, %A%, Name
    IniWrite, %ShortPathName%, Game.ini, %A%, Path
    soundplay, .\sounds\add.mp3
   }
  else
    MsgBox % "Name was empty failed to add"
}

AddFolderCat(A)
{
  If CheckGameExe()
  {
   InputBox, Name, Folder Name, Please Enter the Folders name.
   If CheckName(Name)
    {
     FileCreateDir % Name
     IniWrite, (%Name%), Game.ini, %A%, Name
     IniWrite, %A_WorkingDir%\%Name%\%Name%.exe, Game.ini, %A%, Path
     FileCopy, GameLauncher.exe, %Name%\%Name%.exe
     soundplay, .\sounds\add.mp3
     LoadGamesGuiIcons()
    }
   else
     MsgBox % "Name was empty failed to add"
  }
 else
   MsgBox % "Cannot Create Categories within Categories. Sorry."
}

AddCat()
{
 MsgBox, 4,, % "Create New Category" . "?"
   IfMsgBox Yes
     {
      Gui, C:Destroy
      A := GetIniIndex()
       If A > 15
       {
        MsgBox % "Maximux Programs Reached Sorry"
        return
       }
        AddFolderCat(A)
     }
   else
     Return
}

AddUrl()
{
Gui, C:Destroy
MsgBox % "Nothing here yet"
}

GetIniIndex()
{
I := 1
 Loop
 {
  IniRead, I, Game.ini, %A_Index%, Name
    If I = ERROR
       Return A_Index
 }
}

InstallSounds()
{
FileInstall, sounds\add.mp3, sounds\add.mp3, Overwrite
FileInstall, sounds\run.mp3, sounds\run.mp3, Overwrite
FileInstall, sounds\delete.mp3, sounds\delete.mp3, Overwrite
}

RestoreWorkingDir()
{
 SetWorkingDir % A_ScriptDir
}

CheckName(Name)
{
 if (name = "")
    Return 0
 else
    Return 1
}

CheckGameExe()
{
 if FileExist("GameLauncher.exe")
    Return 1
 else
    Return 0
}

CheckIfCat(CatName)
{
 If InStr(CatName, "(")
    Return 1
 else
    Return 0
}

GuiClose:
ExitApp

OpGuiClose:
Gui, Op:Destroy
Return

CGuiClose:
Gui, C:Destroy
Return