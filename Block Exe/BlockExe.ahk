#NoTrayIcon
Global O
Global Notes

Gui, Add, GroupBox, x2 y-1 w180 h200 , Blocked Exes
Gui, Add, ListBox, gClicked vList x12 y19 w160 h180, Exes
Gui, Add, GroupBox, x2 y199 w180 h90, 
Gui, Add, Button, gAdd x12 y219 w160 h30, Add
Gui, Add, Button, gDelete x12 y249 w160 h30, Delete
Gui, Show, w188 h299,Exe Blocker
LoadExes()
return

Add()
{
 FileSelectFile, Exe
 SplitPath % Exe, name
 If name =
   {
    MsgBox % "Nothing was selected or you Cancelled"
    Return
   }

RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%name%, Debugger, consent.exe
LoadExes()
}

Delete()
{
 GuiControlGet, Item,, List
 If Item =
    {
     MsgBox % "Nothing Selected"
     Return
    }

RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%Item%
LoadExes()
}

LoadExes()
{
GuiControl,, List, |
 Loop, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options, 1, 1
      {
        If A_LoopRegName = Debugger
           {
            RegRead, value
            If Value = consent.exe
              {
               SplitPath % A_LoopRegSubKey, name
               GuiControl,, List, %name%
              }
           }
      }
}

Clicked()
{

 If A_GuiEvent = DoubleClick
 {
  if WinExist("Info")
     Gui, Info:Destroy

  GuiControlGet, O,, List
  If O =
     {
      MsgBox % "You Dident Select an Item"
      Return
     }

RegRead, Info, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%O%, Debugger
RegRead, TheNote, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%O%, Note

Gui, Info:Add, GroupBox, x12 y-1 w214 h87, Information
Gui, Info:Add, GroupBox, x12 y80 w214 h60,
Gui, Info:Add, GroupBox, x14 y43 w210 h38, Notes:
Gui, Info:Add, Edit, vNotes x16 y56 w205 h19, % TheNote
Gui, Info:Add, Text, x18 y15, % "Exe:" A_Space O
Gui, Info:Add, Text, x18 y30, % "Debugger:" A_Space Info
Gui, Info:Add, Button, gOpenReg x22 y99 w194 h30,Open In Regedit
Gui, Info:Show, w240 h148,Info
return
 }
}

OpenReg()
{
 Key := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\" . O
 RegWrite, REG_SZ, HKEY_Current_User\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %Key%
 Run, regedit.exe
}

InfoGuiClose:
GuiControlGet, SaveNote,Info:,Notes
RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%O%, Note,%SaveNote%
Gui, Info:Destroy
Return

GuiClose:
ExitApp