

Loop
 {
  FileReadLine, line, List.txt, %A_Index%
      if ErrorLevel
         break

  Loop Files, %line%\*.dds
  {
   FileGetSize, Size, %A_LoopFileFullPath%, K
    ;If Size > 256
       RunWait %comspec% /c "texconv.exe -w "1024" -h "1024" -m "1" -y -f "DXT5" "%A_LoopFileFullPath%" -o "%line%"",, HIDE
  }
 }
MsgBox % "Complete"