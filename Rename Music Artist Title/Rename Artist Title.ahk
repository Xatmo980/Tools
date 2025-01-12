Mp := true
Loop % A_WorkingDir . "\" . "*.mp3"
{
 Mp := false
 Artist := FGP_Value(A_LoopFileFullPath, "Album Artist")
 If Artist = 0
    Artist := FGP_Value(A_LoopFileFullPath, "Contributing Artists")
 Title := FGP_Value(A_LoopFileFullPath, "Title")
 FileMove, %A_LoopFileFullPath%, % Artist . " - " . Title . ".mp3"
}
If Mp
{
 MsgBox % "No Mp3s Here"
 ExitApp
}

FGP_Init() {
	static PropTable
	if (!PropTable) {
		PropTable := {Name: {}, Num: {}}, Gap := 0
		oShell := ComObjCreate("Shell.Application")
		oFolder := oShell.NameSpace(0)
		while (Gap < 11)
			if (PropName := oFolder.GetDetailsOf(0, A_Index - 1)) {
				PropTable.Name[PropName] := A_Index - 1
				PropTable.Num[A_Index - 1] := PropName
				Gap := 0
			}
			else
				Gap++
	}
	return PropTable
}

FGP_Value(FilePath, Property) {
	static PropTable := FGP_Init()
	if ((PropNum := PropTable.Name[Property] != "" ? PropTable.Name[Property]
	: PropTable.Num[Property] ? Property : "") != "") {
		SplitPath, FilePath, FileName, DirPath
		oShell := ComObjCreate("Shell.Application")
		oFolder := oShell.NameSpace(DirPath)
		oFolderItem := oFolder.ParseName(FileName)
		if (PropVal := oFolder.GetDetailsOf(oFolderItem, PropNum))
			return PropVal
		return 0
	}
	return -1
}