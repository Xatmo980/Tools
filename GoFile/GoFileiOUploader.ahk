#NoTrayIcon
#Include cJson.ahk ; Copyright (c) 2021 Philip Taylor (known also as GeekDude, G33kDude)

Gui, Add, GroupBox, x2 y-1 w500 h130 ,File
Gui, Add, Edit, +ReadOnly vF x12 y29 w340 h20 , 
Gui, Add, Button, gBrow x362 y29 w130 h20 , Browse
Gui, Add, Button, gUp x12 y89 w480 h30 , Upload
Gui, Add, Edit, vL x12 y59 w340 h20 , 
Gui, Add, Button, gCopy x362 y59 w130 h20 , Copy
Gui, Show, w507 h137,GoFileIoUpload
GuiControl,Disable, Upload
return

Brow()
{
 FileSelectFile, SelectedFile, 3
 if (SelectedFile = "")
    MsgBox, The user didn't select anything.
 else
  {
   SplitPath, SelectedFile, name
   GuiControl,Enable, Upload
   GuiControl,, F, % SelectedFile
  }
}

Up()
{
 GuiControlGet, name,, F
 var1 := [name]
 objParam := {file : var1}
 GuiControl,, F, % "Uploading File... Please Wait"
 Link := UploadFile(objParam)
 GuiControl,, L, % Link
 GuiControl,, F, % "Completed Success"
}

Copy()
{
 GuiControlGet, Li,, L
 clipboard := ""
 clipboard := Li
}

UploadFile(objParam)
{
 Url := "https://store1.gofile.io/uploadFile"
 HTTP := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
 HTTP.SetTimeouts(0,30000,30000,600000)
 HTTP.Open("POST", Url, true)
 CreateFormData(PostData, hdr_ContentType, objParam)
 HTTP.SetRequestHeader("Content-Type", hdr_ContentType)
 HTTP.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0")
 HTTP.Option(6) := False
 HTTP.Send(PostData)
 HTTP.WaitForResponse()
 Text := HTTP.ResponseText
 obj := cJson.Loads(Text)
 return obj.data.downloadPage
}

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
   for i, file in FileArray

   GuiControl,Enable, Upload
   GuiControl,, F, % File
}

; Modified version by SKAN, 09/May/2016
CreateFormData(ByRef retData, ByRef retHeader, objParam) {
    New CreateFormData(retData, retHeader, objParam)
}

Class CreateFormData {

    __New(ByRef retData, ByRef retHeader, objParam) {

        Local CRLF := "`r`n", i, k, v, str, pvData
        ; Create a random Boundary
        Local Boundary := this.RandomBoundary()
        Local BoundaryLine := "------------------------------" . Boundary

        ; Create an IStream backed with movable memory.
        hData := DllCall("GlobalAlloc", "uint", 0x2, "uptr", 0, "ptr")
        DllCall("ole32\CreateStreamOnHGlobal", "ptr", hData, "int", False, "ptr*", pStream:=0, "uint")
        this.pStream := pStream

        ; Loop input paramters
        For k, v in objParam
        {
            If IsObject(v) {
                For i, FileName in v
                {
                    str := BoundaryLine . CRLF
                        . "Content-Disposition: form-data; name=""" . k . """; filename=""" . FileName . """" . CRLF
                        . "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF

                    this.StrPutUTF8( str )
                    this.LoadFromFile( Filename )
                    this.StrPutUTF8( CRLF )

                }
            } Else {
                str := BoundaryLine . CRLF
                    . "Content-Disposition: form-data; name=""" . k """" . CRLF . CRLF
                    . v . CRLF
                this.StrPutUTF8( str )
            }
        }

        this.StrPutUTF8( BoundaryLine . "--" . CRLF )

        this.pStream := ObjRelease(pStream) ; Should be 0.
        pData := DllCall("GlobalLock", "ptr", hData, "ptr")
        size := DllCall("GlobalSize", "ptr", pData, "uptr")

        ; Create a bytearray and copy data in to it.
        retData := ComObjArray( 0x11, size ) ; Create SAFEARRAY = VT_ARRAY|VT_UI1
        pvData  := NumGet( ComObjValue( retData ), 8 + A_PtrSize , "ptr" )
        DllCall( "RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size )

        DllCall("GlobalUnlock", "ptr", hData)
        DllCall("GlobalFree", "Ptr", hData, "Ptr")                   ; free global memory

        retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
    }

    StrPutUTF8( str ) {
        length := StrPut(str, "UTF-8") - 1 ; remove null terminator
        VarSetCapacity(utf8, length)
        StrPut(str, &utf8, length, "UTF-8")
        DllCall("shlwapi\IStream_Write", "ptr", this.pStream, "ptr", &utf8, "uint", length, "uint")
    }

    LoadFromFile( filepath ) {
        DllCall("shlwapi\SHCreateStreamOnFileEx"
                    ,   "wstr", filepath
                    ,   "uint", 0x0             ; STGM_READ
                    ,   "uint", 0x80            ; FILE_ATTRIBUTE_NORMAL
                    ,    "int", False            ; fCreate is ignored when STGM_CREATE is set.
                    ,    "ptr", 0               ; pstmTemplate (reserved)
                    ,   "ptr*", pFileStream:=0
                    ,   "uint")
        DllCall("shlwapi\IStream_Size", "ptr", pFileStream, "uint64*", size:=0, "uint")
        DllCall("shlwapi\IStream_Copy", "ptr", pFileStream , "ptr", this.pStream, "uint", size, "uint")
        ObjRelease(pFileStream)
    }

    RandomBoundary() {
        str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
        Sort, str, D| Random
        str := StrReplace(str, "|")
        Return SubStr(str, 1, 12)
    }

    MimeType(FileName) {
        n := FileOpen(FileName, "r").ReadUInt()
        Return (n        = 0x474E5089) ? "image/png"
            :  (n        = 0x38464947) ? "image/gif"
            :  (n&0xFFFF = 0x4D42    ) ? "image/bmp"
            :  (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
            :  (n&0xFFFF = 0x4949    ) ? "image/tiff"
            :  (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
            :  "application/octet-stream"
    }

}

GuiClose:
ExitApp