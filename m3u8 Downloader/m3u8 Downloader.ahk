#NoTrayIcon
global NM
global X=1
global Num
if !FileExist(Links.txt)
    FileDelete, Links.txt

Gui, Add, GroupBox, x2 y-1 w660 h200 , Links
Gui, Add, Edit, vLinks x12 y19 w640 h140 , 
Gui, Add, Button, gDownload x12 y159 w640 h30 , Download
Gui, Show, w669 h209,M3u8 Downloader
return

Download()
{
GuiControlGet, Links
FileAppend, %Links%, Links.txt
Num := GetLinkNumbers()
Sleep, 1000
GuiControl,, Links, |
 Loop
  {
   FileReadLine, line, Links.txt, %A_Index%
    if ErrorLevel
     break

     If CheckEx(line)
     {
      GuiControlGet, Links
      GuiControl,, Links, % "- Downloading -" A_Space A_Index A_Space . "Of" A_Space Num . "`n" . line
      RegExMatch(line, "O)\/\/(.*?)\/", File)
      RegExMatch(line, "[^/]*+$", EndFile)
      NM := "Ep-" A_Index . ".mp4"
      SetTimer, UpdateMB, 1000
      RunWait %comspec% /c "ffmpeg -i %line% -c copy Ep-%A_Index%.mp4",, HIDE
      SetTimer, UpdateMB, Off
      X++  
     }
  }
 MsgBox % "Complete"
}

CheckEx(line)
{
 If RegExMatch(line, "\w+$")
    return 1

return 0
}

GetLinkNumbers()
{
 Loop, read, Links.txt
    Loop, parse, A_LoopReadLine, %A_Tab%
       A++

Return A
}

UpdateMB()
{
 FileGetSize, fs, %A_WorkingDir%\%NM%
 f := Round(fs/1000000)
 GuiControl,, Links, |
 GuiControl,, Links, % "- Downloading -" A_Space X A_Space . "Of" . A_Space Num . "`n" . f . " MB" A_Space . "Of" A_Space NM
}

GuiClose:
ExitApp