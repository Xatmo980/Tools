#NoEnv
#SingleInstance force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
OnExit, GuiClose
#Include Class_SQLiteDB.ahk
if !FileExist(sqlite3.dll)
    FileInstall, sqlite3.dll, sqlite3.dll

CBBSQL := "UPDATE table SET column = 'value' WHERE column = 'value'|DELETE FROM table WHERE column = 'value'|INSERT INTO table (column1, column2, column3) VALUES ('value1', 'value2', 'value3')"
FileSelectFile, SelectedFile, 3
DBFileName := SelectedFile
Title := "SQLiteDB Browser"
Gui, +LastFound +OwnDialogs
Gui, Margin, 10, 10
Gui, Add, Text, w100 h20 0x200 vTX, SQL statement:
Gui, Add, ComboBox, x+0 ym w590 vSQL Sort, %CBBSQL%
GuiControlGet, P, Pos, SQL
GuiControl, Move, TX, h%PH%
Gui, Add, Button, ym w80 hp vRun gRunSQL Default, Run
Gui, Add, Text, xm y50 h20 w100 0x200, Table name:
Gui, Add, Edit, x+0 w150 hp vTable, Table
Gui, Add, Button, Section x+10 yp wp hp gGetTable, Get _Table
Gui, Add, Button, x+10 yp wp hp gGetRecordSet, Get _RecordSet
Gui, Add, GroupBox, x+10 yp-13 wp+50 hp+20,Connected to
Gui, Add, Picture, x600 yp+16 Icon177, C:\Windows\System32\shell32.dll
Gui, Add, Text, x620 yp+2 w100 h20 vFName, %N%
Gui, Add, GroupBox, xm w360 h330, Tables
Gui, Add, GroupBox, x370 yp w415 h330, Results
Gui, Add, ListBox, gSelectedTableGetDB xm+10 yp+18 w340 h300 vLB
Gui, Add, ListView, xp+360 yp w390 h295 vR2LV +LV0x00010000
Gui, Add, StatusBar,
Gui, Show, , %Title%


SB_SetText("SQLiteDB new")
Global DB := new SQLiteDB
Sleep, 1000
SB_SetText("Version")
Version := DB.Version
WinSetTitle, %Title% - SQLite3.dll v %Version%
Sleep, 1000
SB_SetText("OpenDB")
If DB.OpenDB(DBFileName) {
   SplitPath, SelectedFile, name
   GuiControl,, FName, % name
}
else {
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   ExitApp
}

Result := ""
SQL := "SELECT name FROM sqlite_schema WHERE type ='table' AND name NOT LIKE 'sqlite_%';"
SB_SetText("Exec: " . SQL)
Start := A_TickCount
If !DB.GetTable(SQL, Result)
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
SB_SetText("Exec: " . SQL . " done in " . (A_TickCount - Start) . " ms")
StartUpReadTables(Result)
Return

GuiClose:
GuiEscape:
If !DB.CloseDB()
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
Gui, Destroy
ExitApp

GetTable:
Gui, Submit, NoHide
Result := ""
SQL := "SELECT * FROM " . Table . ";"
SB_SetText("GetTable: " . SQL)
Start := A_TickCount
If !DB.GetTable(SQL, Result)
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
SB_SetText("GetTable: " . SQL . " done in " . (A_TickCount - Start) . " ms")
ShowTable(Result)
Return

SelectedTableGetDB()
{
 Control := A_GuiControl
   If A_GuiEvent = DoubleClick
    {
     Result := ""
     GuiControlGet, Selection,, %Control%
     SQL := "SELECT * FROM " . Selection . ";"
     SB_SetText("GetTable: " . SQL)
     Start := A_TickCount
     If !DB.GetTable(SQL, Result)
         MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
     SB_SetText("GetTable: " . SQL . " done in " . (A_TickCount - Start) . " ms")
     GuiControl,, Table, % Selection
     ShowTable(Result)
    }
}

GetRecordSet:
Gui, Submit, NoHide
SQL := "SELECT * FROM " . Table . ";"
SB_SetText("Query: " . SQL)
RecordSet := ""
Start := A_TickCount
If !DB.Query(SQL, RecordSet)
   MsgBox, 16, SQLite Error: Query, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
ShowRecordSet(RecordSet)
RecordSet.Free()
SB_SetText("Query: " . SQL . " done in " . (A_TickCount - Start) . " ms")
Return

RunSQL:
Gui, +OwnDialogs
GuiControlGet, SQL
If SQL Is Space
{
   SB_SetText("No text entered")
   Return
}
If !InStr("`n" . CBBSQL . "`n", "`n" . SQL . "`n") {
   GuiControl, , SQL, %SQL%
   CBBSQL .= "`n" . SQL
}
If (SubStr(SQL, 0) <> ";")
   SQL .= ";"
Result := ""
If RegExMatch(SQL, "i)^\s*SELECT\s") {
   SB_SetText("GetTable: " . SQL)
   If !DB.GetTable(SQL, Result)
      MsgBox, 16, SQLite Error: GetTable, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   Else
      ShowTable(Result)
   SB_SetText("GetTable: " . SQL . " done!")
} Else {
   SB_SetText("Exec: " . SQL)
   If !DB.Exec(SQL)
      MsgBox, 16, SQLite Error: Exec, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   Else
      SB_SetText("Exec: " . SQL . " done!")
}
Return

SQLiteExecCallBack(DB, ColumnCount, ColumnValues, ColumnNames) {
   This := Object(DB)
   MsgBox, 0, %A_ThisFunc%
      , % "SQLite version: " . This.Version . "`n"
      . "SQL statement: " . StrGet(A_EventInfo) . "`n"
      . "Number of columns: " . ColumnCount . "`n" 
      . "Name of first column: " . StrGet(NumGet(ColumnNames + 0, "UInt"), "UTF-8") . "`n" 
      . "Value of first column: " . StrGet(NumGet(ColumnValues + 0, "UInt"), "UTF-8")
   Return 0
}

ShowTable(Table) {
   Global
   Local ColCount, RowCount, Row
   GuiControl, -ReDraw, R1LV
   LV_Delete()
   ColCount := LV_GetCount("Column")
   Loop, %ColCount%
      LV_DeleteCol(1)
   If (Table.HasNames) {
      Loop, % Table.ColumnCount
         LV_InsertCol(A_Index,"", Table.ColumnNames[A_Index])
      If (Table.HasRows) {
         Loop, % Table.RowCount {
            RowCount := LV_Add("", "")
            Table.Next(Row)
            Loop, % Table.ColumnCount
               LV_Modify(RowCount, "Col" . A_Index, Row[A_Index])
         }
      }
      Loop, % Table.ColumnCount
         LV_ModifyCol(A_Index, "AutoHdr")
   }
   GuiControl, +ReDraw, R1LV
}

StartUpReadTables(Table)
{
 Global
 Local ColCount, RowCount, Row

If (Table.HasNames) {
      If (Table.HasRows) {
          Loop, % Table.RowCount
              {
                Table.Next(Row)
                      Loop, % Table.ColumnCount
                            A .= Row[A_Index] . "|"
              }
         }
    }
 GuiControl,, LB, % A
}
; ----------------------------------------------------------------------------------------------------------------------
ShowRecordSet(RecordSet) {
   Global
   Local ColCount, RowCount, Row, RC
   GuiControl, -ReDraw, R2LV
   LV_Delete()
   ColCount := LV_GetCount("Column")
   Loop, %ColCount%
      LV_DeleteCol(1)
   If (RecordSet.HasNames) {
      Loop, % RecordSet.ColumnCount
         LV_InsertCol(A_Index,"", RecordSet.ColumnNames[A_Index])
   }
   If (RecordSet.HasRows) {
      If (RecordSet.Next(Row) < 1) {
         MsgBox, 16, %A_ThisFunc%, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
         Return
      }
      Loop {
         RowCount := LV_Add("", "")
         Loop, % RecordSet.ColumnCount
            LV_Modify(RowCount, "Col" . A_Index, Row[A_Index])
            RC := RecordSet.Next(Row)
      } Until (RC < 1)
   }
   If (RC = 0)
      MsgBox, 16, %A_ThisFunc%, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
   Loop, % RecordSet.ColumnCount
      LV_ModifyCol(A_Index, "AutoHdr")
   GuiControl, +ReDraw, R2LV
}