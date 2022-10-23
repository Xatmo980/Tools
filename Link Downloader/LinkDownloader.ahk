#NoTrayIcon
if !FileExist(Links.txt)
    FileDelete, Links.txt

Gui, Add, GroupBox, x2 y-1 w660 h200 , Links
Gui, Add, Edit, vLinks x12 y19 w640 h140 , 
Gui, Add, Button, gDownload x12 y159 w640 h30 , Download
Gui, Show, w669 h209, Link Downloader
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
      RegExMatch(line, "O)\/\/(.*?)\/", File)
       IfNotExist % A_WorkingDir . "\" . File.Value(1)
        FileCreateDir % A_WorkingDir . "\" . File.Value(1)

       RegExMatch(line, "[^/]*+$", EndFile)
       UrlDownloadToFile, %line%, % A_WorkingDir . "\" . File.Value(1) . "\" . EndFile
       GuiControlGet, Links
       GuiControl,, Links, % "- Downloading -" A_Space A_Index A_Space . "Of" A_Space Num . "`n" . line
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

GuiClose:
ExitApp