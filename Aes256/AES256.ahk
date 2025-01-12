#NoEnv
#Warn
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
Global Folder
Global nErr
Gui, Add, Text, vTe x15 yp+20 w32, File:
Gui, Add, Edit, xp+40 yp-2 w430 h20 vFile_Path_Set
Gui, Add, Text, x15 yp+30, Key:
Gui, Add, Edit, xp+40 yp-2 w430 h20 password vKey
Gui, Add, Checkbox, vKeyK gShowKey, Show key
Gui, Add, Checkbox, vF x130 y73 gFolder, Folder
Gui, Add, Checkbox, vHashed x185 y73,Hashed Filenames
Gui, Add, Button, x110 y100 w100 h30 vFileFolder gSelectFile, Select File
Gui, Add, Button, x210 y100 w100 h30 gButton, Encrypt
Gui, Add, Button, x310 y100 w100 h30 gButton, Decrypt
Gui, Show, w500 h150, Encrypter\Decrypter
Return

SelectFile()
{
 GuiControlGet, F
 If(F)
 {
  FileSelectFolder, Folder
  Folder := RegExReplace(Folder, "\\$")
  GuiControl,, File_Path_Set, %Folder%
 }
 else
 {
  FileSelectFile, File_Path,,, Select your file
  GuiControl,, File_Path_Set, %File_Path%
 }
}

ShowKey()
{
 GuiControlGet, KeyK
  If(KeyK)
   GuiControl, -password, Key
  Else
   GuiControl, +password, Key
}

Folder()
{
 GuiControlGet, C,, %A_GuiControl%
  If C = 1
    {
     GuiControl,, FileFolder,Select Folder
     GuiControl,, Te,Folder:
    }
  else
    {
     GuiControl,, FileFolder,Select File
     GuiControl,, Te,File:
    }
}

Button()
{
 GuiControlGet, Key
 GuiControlGet, File_Path_Set
 GuiControlGet, Hashed

 GuiControlGet, F
 If(F)
 {
   If(Hashed)
   {
    Loop Files, %File_Path_Set%\*.*, R
    {
     Path := A_LoopFileFullPath
     Name := CalcFileHash(Path, 0x8004, 64 * 1024)
     SplitPath, Path,, dir
     FileMove, % Path, % dir . "\" . Name
    }
   }
  Loop Files, %File_Path_Set%\*.*, R
  {
   Path := A_LoopFileFullPath
   SplitPath, Path, FileName, FilePath, GetExt, GetNoExt
   Original := File_Path_Set . "\" . FileName
   Encrypted := File_Path_Set . "\" . FileName . "[Encrypted]" . ".aes"
   rmv := SubStr(GetNoExt, 1, InStr(GetNoExt, "[") - 1)
   SplitPath, rmv,,, rmvExt, rmvNoExt
   Decrypted := File_Path_Set . "\" . rmvNoExt . "[Decrypted]" . "." rmvExt
   EncFile(A_GuiControl, Original, Encrypted, Decrypted, Key)
   FileDelete % Original
  }
 }
 else
 {
   If(Hashed)
   {
     Name := CalcFileHash(File_Path_Set, 0x8004, 64 * 1024)
     SplitPath, Name,, dir
     FileMove, % Path, % dir . "\" . Name
   }
  SplitPath, Name, FileName, FilePath, GetExt, GetNoExt
  Original := File_Path_Set . "\" . FileName
  Encrypted := File_Path_Set . "\" . FileName . "[Encrypted]" . ".aes"
  rmv := SubStr(GetNoExt, 1, InStr(GetNoExt, "[") - 1)
  SplitPath, rmv,,, rmvExt, rmvNoExt
  Decrypted := File_Path_Set . "\" . rmvNoExt . "[Decrypted]" . "." rmvExt
  EncFile(A_GuiControl, Original, Encrypted, Decrypted, Key)
  FileDelete % Original
 }
CheckError()
}

EncFile(Control, FileName, Encrypted, Decrypted, Key)
{
If( Control = "Encrypt" ) {
   FileCryptFile("encrypt", FileName,  Encrypted, Key)
} Else If( Control = "Decrypt" ) {
   FileCryptFile("decrypt", FileName, Decrypted, Key)
  }
}

CheckError()
{
 MsgBox, 0x0, Encrypt, % nErr = 0 ? "Successful!`nFile(s) Encrypted/Decrypted" : "FAILED"
}

FileCryptFile(Mode, Src, Trg, sKey) {
If ( DllCall("Shlwapi.dll\StrSpn"
,"Str",sKey
,"Str","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") != StrLen(sKey) )
Return ("Key has invalid characters")
Mode := (Mode != "Encrypt" ? "Decrypt" : "Encrypt")
VarSetCapacity(Hash, 48)
pKey := &Hash,           nKey := 32
pIni := pKey+nKey,       nIni := 16
hKey := hAlg := hHash := nErr := 0
hBcrypt := DllCall("Kernel32.dll\LoadLibrary", "Str","Bcrypt.dll", "Ptr"),
DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg, "WStr","SHA256", "Ptr", 0, "Int",0)
DllCall("Bcrypt.dll\BCryptCreateHash", "Ptr",hAlg, "PtrP",hHash, "Ptr",0, "Int",0, "Ptr",0, "Int",0, "Int",0)
DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "AStr",sKey, "Int",StrLen(sKey), "Int",0)
DllCall("Bcrypt.dll\BCryptFinishHash", "Ptr",hHash, "Ptr",pKey, "Int",nKey, "Int",0)
DllCall("Bcrypt.dll\BCryptDestroyHash", "Ptr",hHash)
DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int",0)
DllCall("Shlwapi.dll\HashData", "Ptr",pKey, "Int",nKey, "Ptr",pIni, "Int",nIni)
DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg, "WStr","AES", "Ptr",0, "Int",0)
DllCall("Bcrypt.dll\BCryptSetProperty", "Ptr",hAlg, "WStr","ChainingMode", "WStr","ChainingModeCBC", "Int",15, "Int",0)
DllCall("Bcrypt.dll\BCryptGenerateSymmetricKey", "Ptr",hAlg, "PtrP",hKey, "Ptr",0, "Int",0, "Ptr",pKey, "Int",nKey, "Int",0)
nBytes := 524288
rBytes := (nBytes - (Mode="Encrypt"))
wBytes := 0
FileSrc := FileOpen(Src, "r -rwd")
FileTrg := FileSrc ? FileOpen(Trg, "w -rwd") : 0
FileSrc.Pos := 0
VarSetCapacity(Bin, nBytes)
If ( FileSrc.Length And FileTrg.__handle )
Loop
{   rBytes := FileSrc.RawRead(&Bin, rBytes)
nErr   := DllCall("Bcrypt.dll\BCrypt" . Mode, "Ptr",hKey, "Ptr",&Bin, "Int",rBytes, "Ptr",0,"Ptr"
, pIni, "Int",nIni, "Ptr",&Bin, "Int",nBytes, "UIntP",wBytes, "Int",1, "UInt")
wBytes := nErr? 0 : FileTrg.RawWrite(&Bin, wBytes)
}   Until ( nErr Or FileSrc.AtEOF )
FileSrc.Close()
FileTrg.Close()
DllCall("Bcrypt.dll\BCryptDestroyKey", "Ptr",hKey)
DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int", 0)
DllCall("Kernel32.dll\FreeLibrary", "Ptr",hBCrypt)
Return ( nErr ? Format("Bcrypt error: 0x{:08X}", nErr) : wBytes=0 ? "File open Error" : 0 )
}

CalcFileHash(filename, algid, continue = 0, byref hash = 0, byref hashlength = 0)
{
    fpos := ""
    if (!(f := FileOpen(filename, "r")))
    {
        return
    }
    f.pos := 0
    if (!continue && f.length > 0x7fffffff)
    {
        return
    }
    if (!continue)
    {
        VarSetCapacity(data, f.length, 0)
        f.rawRead(&data, f.length)
        f.pos := oldpos
        return CalcAddrHash(&data, f.length, algid, hash, hashlength)
    }
    hashlength := 0
    while (f.pos < f.length)
    {
        readlength := (f.length - fpos > continue) ? continue : f.length - f.pos
        VarSetCapacity(data, hashlength + readlength, 0)
        DllCall("RtlMoveMemory", "Ptr", &data, "Ptr", &hash, "Ptr", hashlength)
        f.rawRead(&data + hashlength, readlength)
        h := CalcAddrHash(&data, hashlength + readlength, algid, hash, hashlength)
    }
    return h
}

CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0)
{
    static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
    hProv := hHash := o := ""
    if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
    {
        if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
        {
            if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
            {
                if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
                {
                    VarSetCapacity(hash, hashlength, 0)
                    if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
                    {
                        loop % hashlength
                        {
                            v := NumGet(hash, A_Index - 1, "UChar")
                            o .= h[(v >> 4) + b] h[(v & 0xf) + b]
                        }
                    }
                }
            }
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
        }
        DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    }
    return o
}

GuiClose:
ExitApp