#NoTrayIcon
Gui, Add, Button, x22 y49 w300 h30 , Generate
Gui, Add, GroupBox, x12 y9 w320 h80 , Pass Gen
Gui, Add, Edit, vGen x22 y29 w300 h20
Gui, Show, w340 h100, Pass Gen
return

ButtonGenerate:
Loop, 1
{
 Loop % (4, Q:="")
     Q .= RandomPW()

GuiControl,, Gen, % Q
}
Return

RandomPW(L:=5, A:=1, R:="", C:="") {
Loop % (L+1, C:="23456789ABCDEFGHJKMNPQRSTUVWXYZ!@#$%^&*")
 Random, A, 1, % (248, R .= "{" . A . ":" . (A & 1 ? "L" : "") . "}")
Return Substr(Format(R, StrSplit(C . C . C . C . C . C . C . C)*), 2)
}
#SingleInstance, Force

GuiClose:
ExitApp