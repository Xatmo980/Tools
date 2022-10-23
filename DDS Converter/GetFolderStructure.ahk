FileSelectFolder, Folder
Loop, Files, %Folder%\*.*, R
      {
       FileAppend, %A_LoopFileDir%`n, %A_WorkingDir%\Processing.txt
      }
FileRead, O, Processing.txt
Sort, O, U
FileAppend, %O%, %A_WorkingDir%\List.txt