#NoTrayIcon

Gui, Add, GroupBox, x12 y9 w370 h700 , Enabled Services
Gui, Add, ListBox, gSelectOne vEnList x22 y29 w350 h670 , 
Gui, Add, Button, gDisable x392 y340 w70 h20 , Disable ->
Gui, Add, Button, gEnable x392 y360 w70 h20 , <- Enable 
Gui, Add, GroupBox, x382 y320 w90 h70 , Control
Gui, Add, GroupBox, x382 y250 w90 h70 , Fix Permission
Gui, Add, Button, gFix x392 y270 w70 h40 , Fix
Gui, Add, GroupBox, x472 y9 w370 h700 , Disabled Services
Gui, Add, ListBox, gSelectOne vDisList x482 y29 w350 h670 ,
Gui, Show, w886 h723, ServiceManager

LoadLists(Reload := 0)
Return

RegKeyData(RegName)
{
 RegRead, O, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%RegName%, Start
 Return O
}

GetDisplayName(RegName)
{
 RegRead, D, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%RegName%, DisplayName
    If InStr(D, "@")
       Return
Return D
}

Disable()
{
 GuiControlGet, Enalist,, EnList
 If Enalist =
    {
     MsgBox % "Nothing Selected"
     Return
    }
RegName := GetSrvName(Enalist)
RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%RegName%, Start, 4
If CheckIfSuccess(RegName, E := 0, D := 1)
   {
    Run %comspec% /c "sc.exe stop %RegName%",, Hide
    LoadLists(Reload := 1)
    MsgBox % "Disabled" A_Space Enalist
   }
}

Enable()
{
 GuiControlGet, Disalist,, DisList
 If Disalist =
    {
     MsgBox % "Nothing Selected"
     Return
    }
RegName := GetSrvName(Disalist)
RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%RegName%, Start, 3
If CheckIfSuccess(RegName, E := 1, D := 0)
   {
    LoadLists(Reload := 1)
    MsgBox % "Enabled" A_Space Enalist
   }
}

CheckIfSuccess(RegName, E, D)
{
  S := RegKeyData(RegName)
    If (E = 1 && S = 4)
       {
        MsgBox % "There was an error and the key could not be changed(Normally a Permission Error or Program not RanAs Administrator)"
        Return 0
       }
    If (D = 1 && S = 3)
       {
        MsgBox % "There was an error and the key could not be changed(Normally a Permission Error or Program not RanAs Administrator)"
        Return 0
       }

Return 1
}


LoadLists(Reload)
{
If Reload = 1
   {
    GuiControl,, EnList, |
    GuiControl,, DisList, |
    Reload = 0
   }
Loop, Reg, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services, KV
{
    If (Start := RegKeyData(A_LoopRegName) = 3)
       If !(D := GetDisplayName(A_LoopRegName) = "")
            EList .= GetDisplayName(A_LoopRegName) . "`n"
    If (Start := RegKeyData(A_LoopRegName) = 4)
       If !(D := GetDisplayName(A_LoopRegName) = "")
            DList .= GetDisplayName(A_LoopRegName) . "`n"
}
Sort, EList, U
Sort, DList, U

Loop, parse, EList, `n
      SEList .= A_LoopField . "|"
Loop, parse, DList, `n
      SDList .= A_LoopField . "|"

GuiControl,, EnList, %SEList%
GuiControl,, DisList, %SDList%
DeSelectAll()
}

GetSrvName(ServiceName)
{
 If ServiceName = 
    Return
 Loop, Reg, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services, KV
 {
    If (Start := RegKeyData(A_LoopRegName) = 3)
       If (D := GetDisplayName(A_LoopRegName) = ServiceName)
            Return A_LoopRegName
    If (Start := RegKeyData(A_LoopRegName) = 4)
       If (D := GetDisplayName(A_LoopRegName) = ServiceName)
            Return A_LoopRegName
 }
}


Fix()
{
 GuiControlGet, Enalist,, EnList
 GuiControlGet, Disalist,, DisList
 ModPermission(Name := GetSrvName(Enalist))
 ModPermission(Name := GetSrvName(Disalist))
}

ModPermission(Name)
{
 If Name =
    Return

 FileAppend, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%Name% [1 9], %Name%.ini
 RunWait %comspec% /c REGINI %A_WorkingDir%\%Name%.ini
 FileDelete, %A_WorkingDir%\%Name%.ini
}

SelectOne()
{
 If A_GuiEvent = DoubleClick
  {
   MsgBox % "Information will be here"
  }
 Control := A_GuiControl
 If Control = EnList
    GuiControl, Choose, ListBox2, 0
 If Control = DisList
    GuiControl, Choose, ListBox1, 0
}

DeSelectAll()
{
 GuiControl, Choose, ListBox2, 0
 GuiControl, Choose, ListBox1, 0
}


;REGINI file
;HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%RegName% [1 9]
;1 - Administrators Full Access
;2 - Administrators Read Access
;3 - Administrators Read and Write Access
;4 - Administrators Read, Write and Delete Access
;5 - Creator Full Access
;6 - Creator Read and Write Access
;7 - World Full Access
;8 - World Read Access
;9 - World Read and Write Access
;10 - World Read, Write and Delete Access
;11 - Power Users Full Access
;12 - Power Users Read and Write Access
;13 - Power Users Read, Write and Delete Access
;14 - System Operators Full Access
;15 - System Operators Read and Write Access
;16 - System Operators Read, Write and Delete Access
;17 - System Full Access
;18 - System Read and Write Access
;19 - System Read Access
;20 - Administrators Read, Write and Execute Access
;21 - Interactive User Full Access
;22 - Interactive User Read and Write Access
;23 - Interactive User Read, Write and Delete Access

GuiClose:
ExitApp
