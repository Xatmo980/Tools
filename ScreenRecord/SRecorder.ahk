#NoTrayIcon
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
D := GetDevices()

If !Y := CheckDX11()
    {
     Msgbox, This tool requires both Windows 10 and DirectX11 to Function`n (ERROR - C:\Windows\System32\d3d11.dll - Missing)
     ExitApp
    }

Gui, Add, GroupBox, x2 y-1 w150 h50, File Name
Gui, Add, GroupBox, x152 y-1 w150 h50, FPS
Gui, Add, GroupBox, x302 y-1 w150 h50, Record Time Seconds
Gui, Add, GroupBox, x452 y-1 w150 h50, Audio Device
Gui, Add, DropDownList, R3 vDevice x462 y19 w130 h20,%D%
Gui, Add, GroupBox, x602 y-1 w130 h50, 
Gui, Add, Edit, vName x12 y19 w130 h20, 
Gui, Add, Edit, vFPS x162 y19 w130 h20, 
Gui, Add, Edit, vRTS x312 y19 w130 h20,
Gui, Add, Button, gStart x612 y19 w110 h20, Start
Gui, Show, w735 h57, Screen Record
return

X::
WinGetActiveTitle, Title
WinGetPos, X, Y, Height, Width, %Title%
x1 := X, x2 := Width, y1 := Y, y2 := Height
MsgBox % x1 A_Space x2 A_Space y1 A_Space y2
return

Start:
GuiControlGet, Name
GuiControlGet, FPS
GuiControlGet, RTS
GuiControlGet, Device
Secon := RTS
If !L := Check(Name, FPS, RTS)
   {
    Msgbox, Please Fill out everything and retry
    return
   }
WinMinimize, Screen Record

SetTimer, Counter, 1000

file := Name . ".mp4"
video_bitrate := 4000000
video_fps := FPS
duration := RTS
capture_cursor := true
audiodevice := "" . Device . ""
audioDelay := 80
;x1 := 300, x2 :=  300, y1 := 300, y2 := 300
  CaptureCoordinatesWithCPU := true
; Rotate := true
; UseSoftwareEncoding := true

setbatchlines -1
Global pSinkWriter, SourceReader, audioStreamIndex, Flush, IMFSourceReaderCallback
IDXGIFactory := CreateDXGIFactory()
if !IDXGIFactory
{
   MsgBox, 16, Error, Create IDXGIFactory failed.
   ExitApp
}
loop
{
   IDXGIFactory_EnumAdapters(IDXGIFactory, A_Index-1, IDXGIAdapter)
   loop
   {
      hr := IDXGIAdapter_EnumOutputs(IDXGIAdapter, A_Index-1, IDXGIOutput)
      if (hr = "DXGI_ERROR_NOT_FOUND")
         break
      VarSetCapacity(DXGI_OUTPUT_DESC, 88+A_PtrSize, 0)
      IDXGIOutput_GetDesc(IDXGIOutput, &DXGI_OUTPUT_DESC)
      Width := NumGet(DXGI_OUTPUT_DESC, 72, "int")
      Height := NumGet(DXGI_OUTPUT_DESC, 76, "int")
      AttachedToDesktop := NumGet(DXGI_OUTPUT_DESC, 80, "int")
      if (AttachedToDesktop = 1)
         break 2         
   }
}
if (AttachedToDesktop != 1)
{
   MsgBox, 16, Error, No adapter attached to desktop
   ExitApp
}
D3D11CreateDevice(IDXGIAdapter, D3D_DRIVER_TYPE_UNKNOWN := 0, 0, 0, 0, 0, D3D11_SDK_VERSION := 7, d3d_device, 0, d3d_context)
IDXGIOutput1 := IDXGIOutput1_Query(IDXGIOutput)
IDXGIOutput1_DuplicateOutput(IDXGIOutput1, d3d_device, Duplication)
VarSetCapacity(DXGI_OUTDUPL_DESC, 36, 0)
IDXGIOutputDuplication_GetDesc(Duplication, &DXGI_OUTDUPL_DESC)
DesktopImageInSystemMemory := NumGet(DXGI_OUTDUPL_DESC, 32, "uint")
sleep 50   ; As I understand - need some sleep for successful connecting to IDXGIOutputDuplication interface

VarSetCapacity(D3D11_TEXTURE2D_DESC, 44, 0)
NumPut(width, D3D11_TEXTURE2D_DESC, 0, "uint")   ; Width
NumPut(height, D3D11_TEXTURE2D_DESC, 4, "uint")   ; Height
NumPut(1, D3D11_TEXTURE2D_DESC, 8, "uint")   ; MipLevels
NumPut(1, D3D11_TEXTURE2D_DESC, 12, "uint")   ; ArraySize
NumPut(DXGI_FORMAT_B8G8R8A8_UNORM := 87, D3D11_TEXTURE2D_DESC, 16, "uint")   ; Format
NumPut(1, D3D11_TEXTURE2D_DESC, 20, "uint")   ; SampleDescCount
NumPut(0, D3D11_TEXTURE2D_DESC, 24, "uint")   ; SampleDescQuality
NumPut(D3D11_USAGE_STAGING := 3, D3D11_TEXTURE2D_DESC, 28, "uint")   ; Usage
NumPut(0, D3D11_TEXTURE2D_DESC, 32, "uint")   ; BindFlags
NumPut(D3D11_CPU_ACCESS_READ := 0x20000 | D3D11_CPU_ACCESS_WRITE := 0x10000, D3D11_TEXTURE2D_DESC, 36, "uint")   ; CPUAccessFlags
NumPut(0, D3D11_TEXTURE2D_DESC, 40, "uint")   ; MiscFlags
ID3D11Device_CreateTexture2D(d3d_device, &D3D11_TEXTURE2D_DESC, 0, staging_tex)
if (capture_cursor = true)
{
   VarSetCapacity(D3D11_TEXTURE2D_DESC, 44, 0)
   NumPut(width, D3D11_TEXTURE2D_DESC, 0, "uint")   ; Width
   NumPut(height, D3D11_TEXTURE2D_DESC, 4, "uint")   ; Height
   NumPut(1, D3D11_TEXTURE2D_DESC, 8, "uint")   ; MipLevels
   NumPut(1, D3D11_TEXTURE2D_DESC, 12, "uint")   ; ArraySize
   NumPut(DXGI_FORMAT_B8G8R8A8_UNORM := 87, D3D11_TEXTURE2D_DESC, 16, "uint")   ; Format
   NumPut(1, D3D11_TEXTURE2D_DESC, 20, "uint")   ; SampleDescCount
   NumPut(0, D3D11_TEXTURE2D_DESC, 24, "uint")   ; SampleDescQuality
   NumPut(D3D11_USAGE_DEFAULT := 0, D3D11_TEXTURE2D_DESC, 28, "uint")   ; Usage
   NumPut(D3D11_BIND_RENDER_TARGET := 0x20, D3D11_TEXTURE2D_DESC, 32, "uint")   ; BindFlags
   NumPut(0, D3D11_TEXTURE2D_DESC, 36, "uint")   ; CPUAccessFlags
   NumPut(D3D11_RESOURCE_MISC_GDI_COMPATIBLE := 0x200, D3D11_TEXTURE2D_DESC, 40, "uint")   ; MiscFlags
   ID3D11Device_CreateTexture2D(d3d_device, &D3D11_TEXTURE2D_DESC, 0, gdi_tex)
}

LOAD_DLL_Mf_Mfplat_Mfreadwrite()
MFStartup(version := 2, MFSTARTUP_FULL := 0)
if (ShowAllAudioDevicesNames != 1)
{
   if (UseSoftwareEncoding != 1)
   {
      VarSetCapacity(MFT_REGISTER_TYPE_INFO, 32, 0)
      DllCall("RtlMoveMemory", "ptr", &MFT_REGISTER_TYPE_INFO, "ptr", MF_GUID(GUID, "MFMediaType_Video"), "ptr", 16)
      DllCall("RtlMoveMemory", "ptr", &MFT_REGISTER_TYPE_INFO + 16, "ptr", MF_GUID(GUID, "MFVideoFormat_H264"), "ptr", 16)
      hardware_encoder := MFTEnumEx(MF_GUID(GUID, "MFT_CATEGORY_VIDEO_ENCODER"), MFT_ENUM_FLAG_HARDWARE := 0x04|MFT_ENUM_FLAG_SORTANDFILTER := 0x40, 0, &MFT_REGISTER_TYPE_INFO)
   }
   if (x1 != "")
   {
      checkCoordinates(x1, x2, y1, y2, hardware_encoder)
      width := x2-x1
      height := y2-y1
      VarSetCapacity(D3D11_BOX, 24, 0)
      NumPut(x1, D3D11_BOX, 0, "uint")   ; left
      NumPut(y1, D3D11_BOX, 4, "uint")   ; top
      NumPut(0, D3D11_BOX, 8, "uint")   ; front
      NumPut(x2, D3D11_BOX, 12, "uint")   ; right
      NumPut(y2, D3D11_BOX, 16, "uint")   ; bottom
      NumPut(1, D3D11_BOX, 20, "uint")   ; back
   }
   if (hardware_encoder != "")
   {
      MFCreateAttributes(pMFAttributes, 4)
      IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS"), true)
   }
   else
      MFCreateAttributes(pMFAttributes, 3)
   IMFAttributes_SetGUID(pMFAttributes, MF_GUID(GUID, "MF_TRANSCODE_CONTAINERTYPE"), MF_GUID(GUID1, "MFTranscodeContainerType_MPEG4"))
   IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_SINK_WRITER_DISABLE_THROTTLING"), true)
   IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_LOW_LATENCY"), true)
   MFCreateSinkWriterFromURL(file, 0, pMFAttributes, pSinkWriter)
   Release(pMFAttributes)
   pMFAttributes := ""

   loop 2   ; 1 - input, 2 - output
   {
      MFCreateMediaType(pMediaType%A_Index%)
      IMFAttributes_SetGUID(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Video"))
      if (A_Index = 1)
      {
         if !InStr(hardware_encoder, "NVIDIA") or ((x1 != "") and (CaptureCoordinatesWithCPU = true))
            IMFAttributes_SetGUID(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFVideoFormat_RGB32"))
         else
            IMFAttributes_SetGUID(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFVideoFormat_ARGB32"))
      }
      else
      {
         IMFAttributes_SetGUID(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFVideoFormat_H264"))
         IMFAttributes_SetUINT32(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_AVG_BITRATE"), video_bitrate)
      }
      IMFAttributes_SetUINT32(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_INTERLACE_MODE"), MFVideoInterlace_Progressive := 2)
      IMFAttributes_SetUINT64(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), (width<<32)|height)
      IMFAttributes_SetUINT64(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_RATE"), (video_fps<<32)|1)
      IMFAttributes_SetUINT64(pMediaType%A_Index%, MF_GUID(GUID, "MF_MT_PIXEL_ASPECT_RATIO"), (1<<32)|1)
   }
   IMFSinkWriter_AddStream(pSinkWriter, pMediaType2, videoStreamIndex)
   IMFSinkWriter_SetInputMediaType(pSinkWriter, videoStreamIndex, pMediaType1, 0)
   Release(pMediaType1)
   Release(pMediaType2)
   pMediaType1 := pMediaType2 := ""
}

if (audiodevice != "") or (ShowAllAudioDevicesNames = 1)
{
   NUM_CHANNELSMax := BITS_PER_SAMPLEMax := SAMPLES_PER_SECONDMax := BYTES_PER_SECONDMax := StreamNumberAudio := TypeNumberAudio := AudioSources := ""
   audiobasedevice := audiodevice
   IMFSourceReaderCallback := IMFSourceReaderCallback_new()
   MFCreateAttributes(pMFAttributes, 1)
   IMFAttributes_SetGUID(pMFAttributes, MF_GUID(GUID, "MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE"), MF_GUID(GUID1, "MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID"))
   MFEnumDeviceSources(pMFAttributes, pppSourceActivate, pcSourceActivate)
   Loop % pcSourceActivate
   {
      IMFActivate := NumGet(pppSourceActivate + (A_Index - 1)*A_PtrSize)
      devicename := IMFActivate_GetAllocatedString(IMFActivate, MF_GUID(GUID, "MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME"))
      if (ShowAllAudioDevicesNames = 1)
      {
         basedevicename := devicename
         loop
         {
            if !InStr(Audiodevicenames, """" devicename """`r`n")
               break
            devicename := basedevicename "[" A_Index+1 "]"
         }
         Audiodevicenames .= """" devicename """|"
      }
      else
      {
         if RegexMatch(audiodevice, "\[(\d)]$", match) and (devicename = RegexReplace(audiodevice, "\[\d]$"))
         {
            match1--
            if (match1 = 0)
               audiodevice := devicename
            else
               audiodevice := devicename "[" match1 "]"
         }
         if (devicename = audiodevice) and (MediaSourceAudio = "")
            IMFActivate_ActivateObject(IMFActivate, IMFMediaSource := "{279a808d-aec7-40c8-9c6b-a6b492c78a66}", MediaSourceAudio)
      }
      Release(IMFActivate)
      IMFActivate := ""
   }
   DllCall("ole32\CoTaskMemFree", "ptr", pppSourceActivate)
   Release(pMFAttributes)
   pMFAttributes := ""
   if (ShowAllAudioDevicesNames = 1)
   {
      if (Audiodevicenames = "")
         Audiodevicenames .= "None"
      msgbox % clipboard := "Audio:`r`n" Audiodevicenames
      ExitApp
   }
   if (MediaSourceAudio = "")
   {
      msgbox % "Cannot find Audio device - """ audiobasedevice """"
      ExitApp
   }
   MFCreateAttributes(pMFAttributes, 1)
   IMFAttributes_SetUnknown(pMFAttributes, MF_GUID(GUID, "MF_SOURCE_READER_ASYNC_CALLBACK"), IMFSourceReaderCallback)
   MFCreateSourceReaderFromMediaSource(MediaSourceAudio, pMFAttributes, SourceReader)
   loop
   {
      n := A_Index - 1
      if (IMFSourceReader_GetNativeMediaType(SourceReader, n, 0, ppMediaType) = "MF_E_INVALIDSTREAMNUMBER")
         break
      Release(ppMediaType)
      ppMediaType := ""
      loop
      {
         k := A_Index - 1
         if (IMFSourceReader_GetNativeMediaType(SourceReader, n, k, ppMediaType) = "MF_E_NO_MORE_TYPES")
            break
         IMFAttributes_GetGUID(ppMediaType, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), pguidValue)
         if (MemoryDifference(&pguidValue, MF_GUID(GUID, "MFMediaType_Audio"), 16) = 0)
         {
            IMFAttributes_GetGUID(ppMediaType, MF_GUID(GUID, "MF_MT_SUBTYPE"), pguidValueSubType)
            AudioSources .= Format("0x{:x}", NumGet(pguidValueSubType, 0, "int")) "`n"
            if (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFAudioFormat_PCM"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFAudioFormat_Float"), 16) = 0)
            {
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_AVG_BYTES_PER_SECOND"), BYTES_PER_SECOND) = "MF_E_ATTRIBUTENOTFOUND")
                  BYTES_PER_SECOND := 0
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_BITS_PER_SAMPLE"), BITS_PER_SAMPLE) = "MF_E_ATTRIBUTENOTFOUND")
                  BITS_PER_SAMPLE := 0
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_SAMPLES_PER_SECOND"), SAMPLES_PER_SECOND) = "MF_E_ATTRIBUTENOTFOUND")
                  SAMPLES_PER_SECOND := 0
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_NUM_CHANNELS"), NUM_CHANNELS) = "MF_E_ATTRIBUTENOTFOUND")
                  NUM_CHANNELS := 0
               if ((NUM_CHANNELSMax < 2) and (NUM_CHANNELS > NUM_CHANNELSMax)) or ((NUM_CHANNELSMax = 2) and (NUM_CHANNELS = 6)) or ((NUM_CHANNELSMax > 2) and (NUM_CHANNELSMax != 6) and ((NUM_CHANNELS = 2) or (NUM_CHANNELS = 6))) or ((NUM_CHANNELS = NUM_CHANNELSMax) and (BITS_PER_SAMPLEMax != 16) and ((BITS_PER_SAMPLE = 16) or (BITS_PER_SAMPLE > BITS_PER_SAMPLEMax))) or ((NUM_CHANNELS = NUM_CHANNELSMax) and (BITS_PER_SAMPLE = BITS_PER_SAMPLEMax) and (SAMPLES_PER_SECONDMax != 44100) and (SAMPLES_PER_SECONDMax != 48000) and ((SAMPLES_PER_SECOND = 44100) or (SAMPLES_PER_SECOND > SAMPLES_PER_SECONDMax))) or ((SAMPLES_PER_SECONDMax != 48000) and (SAMPLES_PER_SECOND = 48000)) or ((NUM_CHANNELS = NUM_CHANNELSMax) and (BITS_PER_SAMPLE = BITS_PER_SAMPLEMax) and (SAMPLES_PER_SECOND = SAMPLES_PER_SECONDMax) and (BYTES_PER_SECOND > BYTES_PER_SECONDMax))
               { 
                  NUM_CHANNELSMax := NUM_CHANNELS
                  BITS_PER_SAMPLEMax := BITS_PER_SAMPLE
                  SAMPLES_PER_SECONDMax := SAMPLES_PER_SECOND
                  BYTES_PER_SECONDMax := BYTES_PER_SECOND
                  StreamNumberAudio := n
                  TypeNumberAudio := k
               }
            }
         }
         Release(ppMediaType)
         ppMediaType := ""
      }
   }
   if (StreamNumberAudio = "")
   {
      Sort, AudioSources, U
      msgbox % "Current AudioSources not supported:`n" AudioSources
      ExitApp
   }
   IMFSourceReader_SetStreamSelection(SourceReader, MF_SOURCE_READER_ALL_STREAMS := 0xFFFFFFFE, false)
   IMFSourceReader_SetStreamSelection(SourceReader, StreamNumberAudio, true)
   Release(pMFAttributes)
   pMFAttributes := ""
   if (NUM_CHANNELSMax = 0)
      NUM_CHANNELSMax := 1
   else if (NUM_CHANNELSMax > 2) and (NUM_CHANNELSMax < 6)
      NUM_CHANNELSMax := 2
   else if (NUM_CHANNELSMax > 6)
      NUM_CHANNELSMax := 6
   if (SAMPLES_PER_SECONDMax < 44100)
      SAMPLES_PER_SECONDMax := 44100
   else if (SAMPLES_PER_SECONDMax > 44100)
      SAMPLES_PER_SECONDMax := 48000
   loop 2   ; 1 - input, 2 - output
   {
      MFCreateMediaType(pMediaTypeAudio%A_Index%)
      IMFAttributes_SetGUID(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Audio"))
      if (A_Index = 1)
         IMFAttributes_SetGUID(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFAudioFormat_PCM"))
      else
      {
         IMFAttributes_SetGUID(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFAudioFormat_AAC"))
         IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_AVG_BYTES_PER_SECOND"), 20000)
      }
      IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_BITS_PER_SAMPLE"), 16)
      IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_SAMPLES_PER_SECOND"), SAMPLES_PER_SECONDMax)
      IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_NUM_CHANNELS"), NUM_CHANNELSMax)
   }
   IMFSinkWriter_AddStream(pSinkWriter, pMediaTypeAudio2, audioStreamIndex)
   IMFSinkWriter_SetInputMediaType(pSinkWriter, audioStreamIndex, pMediaTypeAudio1, 0)
   IMFSourceReader_SetCurrentMediaType(SourceReader, StreamNumberAudio, 0, pMediaTypeAudio1)
   Release(pMediaTypeAudio1)
   Release(pMediaTypeAudio2)
   pMediaTypeAudio1 := pMediaTypeAudio2 := ""
}
IMFSinkWriter_BeginWriting(pSinkWriter)
video_frame_duration := 10000000/video_fps
video_frame_count := duration*video_fps
cbWidth := 4 * width
cbBuffer := cbWidth * height
rtStart := 0
fps := 1000/video_fps
CaptureDuration := duration*1000 - 2*fps
VarSetCapacity(TIMECAPS, 8, 0)
DllCall("winmm\timeGetDevCaps", "ptr", &TIMECAPS, "uint", 8)
uPeriod := NumGet(TIMECAPS, 0, "uint")
DllCall("Winmm\timeBeginPeriod", "uint", uPeriod)

;msgbox % "hardware-encoder - " ((hardware_encoder != "") ? hardware_encoder : "none")
loop
{
   if (A_Index != 1)
   {
      DllCall("QueryPerformanceCounter", "int64*", ATickCount)
      sleepDuration := fps*(A_Index-1) - (ATickCount - start)*1000/freq
      SleepEnd := ATickCount + sleepDuration*freq/1000
      sleep % sleepDuration - 15
      DllCall("QueryPerformanceCounter", "int64*", ATickCount)
      if (ATickCount < SleepEnd)
         DllCall("Sleep", "uint", (SleepEnd - ATickCount)*1000/freq)
   }
   VarSetCapacity(DXGI_OUTDUPL_FRAME_INFO, 48, 0)
   if (A_Index = 1)
      AcquireNextFrame := IDXGIOutputDuplication_AcquireNextFrame(Duplication, -1, &DXGI_OUTDUPL_FRAME_INFO, desktop_resource)
   else
      AcquireNextFrame := IDXGIOutputDuplication_AcquireNextFrame(Duplication, 0, &DXGI_OUTDUPL_FRAME_INFO, desktop_resource)
   if (AcquireNextFrame != "DXGI_ERROR_WAIT_TIMEOUT")
   {
      if (A_Index = 1)
      {
         if (audiodevice != "")
         {
            IMFSourceReader_ReadSample(SourceReader, MF_SOURCE_READER_ANY_STREAM := 0xFFFFFFFE, 0, 0, 0, 0, 0)
            if (audioDelay > 0)
               DllCall("Sleep", "uint", audioDelay)
         }
         DllCall("QueryPerformanceCounter", "int64*", start)
         DllCall("QueryPerformanceFrequency", "int64*", freq)
      }
      else
      {
         Release(pSample)
         Release(pBuffer)
         pSample := pBuffer := ""
      }
      tex := ID3D11Texture2D_Query(desktop_resource)
      if (capture_cursor = true)
      {
         VarSetCapacity(CURSORINFO, cbSize := 16 + A_PtrSize, 0)
         NumPut(cbSize, CURSORINFO, 0, "uint")
      }
      if (capture_cursor = true) and DllCall("GetCursorInfo", "ptr", &CURSORINFO) and (NumGet(CURSORINFO, 4, "uint") = 1)   ; CURSOR_SHOWING
      {
         hCursor := NumGet(CURSORINFO, 8)
         xCursor := NumGet(CURSORINFO, 8 + A_PtrSize, "int")
         yCursor := NumGet(CURSORINFO, 12 + A_PtrSize, "int")
         VarSetCapacity(ICONINFO, 8 + A_PtrSize*3, 0)
         DllCall("GetIconInfo", "ptr", hCursor, "ptr", &ICONINFO)
         xHotspot := NumGet(ICONINFO, 4, "uint")
         yHotspot := NumGet(ICONINFO, 8, "uint")
         hbmMask  := NumGet(ICONINFO, 8 + A_PtrSize)
         hbmColor := NumGet(ICONINFO, 8 + A_PtrSize*2)
         ID3D11DeviceContext_CopyResource(d3d_context, gdi_tex, tex)
         gdi_Surface := IDXGISurface1_Query(gdi_tex)
         IDXGISurface1_GetDC(gdi_Surface, 0, hdc)
         DllCall("DrawIconEx", "ptr", hdc, "int", xCursor - xHotspot, "int", yCursor - yHotspot, "ptr", hCursor, "int", 0, "int", 0, "uint", 0, "ptr", 0, "uint", DI_NORMAL := 0x0003 | DI_DEFAULTSIZE := 0x0008)
         if hbmMask
            DllCall("DeleteObject", "ptr", hbmMask)
         if hbmColor
            DllCall("DeleteObject", "ptr", hbmColor)
         hbmMask := hbmColor := ""
         IDXGISurface1_ReleaseDC(gdi_Surface, 0)
         if (x1 = "")
            ID3D11DeviceContext_CopyResource(d3d_context, staging_tex, gdi_tex)
         else
            ID3D11DeviceContext_CopySubresourceRegion(d3d_context, staging_tex, 0, 0, 0, 0, gdi_tex, 0, &D3D11_BOX)   ; set region
         ObjRelease(gdi_Surface)
         gdi_Surface := ""
      }
      else
      {
         if (x1 = "")
            ID3D11DeviceContext_CopyResource(d3d_context, staging_tex, tex)
         else
            ID3D11DeviceContext_CopySubresourceRegion(d3d_context, staging_tex, 0, 0, 0, 0, tex, 0, &D3D11_BOX)   ; set region
      }
      VarSetCapacity(D3D11_MAPPED_SUBRESOURCE, 8+A_PtrSize, 0)
      ID3D11DeviceContext_Map(d3d_context, staging_tex, 0, D3D11_MAP_READ := 1, 0, &D3D11_MAPPED_SUBRESOURCE)
      pBits := NumGet(D3D11_MAPPED_SUBRESOURCE, 0, "ptr")
      pitch := NumGet(D3D11_MAPPED_SUBRESOURCE, A_PtrSize, "uint")

      MFCreateMemoryBuffer(cbBuffer, pBuffer)
      IMFMediaBuffer_Lock(pBuffer, pData, 0, 0)
      if !InStr(hardware_encoder, "NVIDIA") or ((x1 != "") and (CaptureCoordinatesWithCPU = true)) or (Rotate = true)
         MFCopyImage(pData, cbWidth, pBits+(height-1)*pitch, pitch*-1, cbWidth, height)
      else
         MFCopyImage(pData, cbWidth, pBits, pitch, cbWidth, height)
      IMFMediaBuffer_Unlock(pBuffer)
      IMFMediaBuffer_SetCurrentLength(pBuffer, cbBuffer)
      MFCreateSample(pSample)
      IMFSample_AddBuffer(pSample, pBuffer)
   }
   IMFSample_SetSampleTime(pSample, rtStart)
   IMFSample_SetSampleDuration(pSample, video_frame_duration)
   IMFSinkWriter_WriteSample(pSinkWriter, streamIndex, pSample)
   if (AcquireNextFrame != "DXGI_ERROR_WAIT_TIMEOUT")
   {
      ID3D11DeviceContext_Unmap(d3d_context, staging_tex, 0)
      ObjRelease(tex)
      Release(desktop_resource)
      tex := desktop_resource := ""
      IDXGIOutputDuplication_ReleaseFrame(duplication)
   }
   if ((ATickCount - start)/freq*1000 >= CaptureDuration)
   {
      video_frame_countReal := A_Index
      if (audiodevice != "")
      {
         flush := 1
         loop
         {
            if (flush = "")
               break
            sleep 50
         }
      }
      break
   }
   rtStart += video_frame_duration
}
IMFSinkWriter_Finalize(pSinkWriter)
DllCall("Winmm\timeEndPeriod", "uint", uPeriod)
if audiodevice
{
   Release(MediaSourceAudio)
   MediaSourceAudio := ""
}
Release(pSample)
Release(pBuffer)
Release(pSinkWriter)
Release(staging_tex)
Release(d3d_device)
Release(d3d_context)
Release(duplication)
Release(IDXGIAdapter)
Release(IDXGIOutput)
ObjRelease(IDXGIOutput1)
Release(IDXGIFactory)
if (capture_cursor = true)
{
   Release(gdi_tex)
   gdi_tex := ""
}
pSample := pBuffer := pSinkWriter := staging_tex := d3d_device := d3d_context := duplication := IDXGIAdapter := IDXGIOutput := IDXGIOutput1 := IDXGIFactory := ""
MFShutdown()
ToolTip
WinRestore, Screen Record
SetTimer, Counter, off
msgbox % "done`n" video_frame_countReal " captured`n" video_frame_count-video_frame_countReal " frames dropped"
return

CreateDXGIFactory()
{
   if !DllCall("GetModuleHandle","str","DXGI")
      DllCall("LoadLibrary","str","DXGI")
   if !DllCall("GetModuleHandle","str","D3D11")
      DllCall("LoadLibrary","str","D3D11")
   GUID(riid, "{7b7166ec-21c7-44ae-b21a-c9ae321ae369}")
   hr := DllCall("DXGI\CreateDXGIFactory1", "ptr", &riid, "ptr*", ppFactory)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   return ppFactory
}

IDXGIFactory_EnumAdapters(this, Adapter, ByRef ppAdapter)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "uint", Adapter, "ptr*", ppAdapter)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIAdapter_EnumOutputs(this, Output, ByRef ppOutput)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "uint", Output, "ptr*", ppOutput)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0x887A0002   ; DXGI_ERROR_NOT_FOUND
            return "DXGI_ERROR_NOT_FOUND"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IDXGIAdapter_GetDesc(this, pDesc)
{
   hr := DllCall(NumGet(NumGet(this+0)+8*A_PtrSize), "ptr", this, "ptr", pDesc)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIOutput_GetDesc(this, pDesc)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "ptr", pDesc)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIOutputDuplication_GetDesc(this, pDesc)
{
   DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "ptr", pDesc)
   if ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIOutputDuplication_AcquireNextFrame(this, TimeoutInMilliseconds, pFrameInfo, ByRef ppDesktopResource)
{
   hr := DllCall(NumGet(NumGet(this+0)+8*A_PtrSize), "ptr", this, "uint", TimeoutInMilliseconds, "ptr", pFrameInfo, "ptr*", ppDesktopResource)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0x887A0027   ; DXGI_ERROR_WAIT_TIMEOUT
            return "DXGI_ERROR_WAIT_TIMEOUT"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

D3D11CreateDevice(pAdapter, DriverType, Software, Flags, pFeatureLevels, FeatureLevels, SDKVersion, ByRef ppDevice, ByRef pFeatureLevel, ByRef ppImmediateContext)
{
   hr := DllCall("D3D11\D3D11CreateDevice", "ptr", pAdapter, "int", DriverType, "ptr", Software, "uint", Flags, "ptr", pFeatureLevels, "uint", FeatureLevels, "uint", SDKVersion, "ptr*", ppDevice, "ptr*", pFeatureLevel, "ptr*", ppImmediateContext)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID3D11Device_CreateTexture2D(this, pDesc, pInitialData, ByRef ppTexture2D)
{
   hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "ptr", pDesc, "ptr", pInitialData, "ptr*", ppTexture2D)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIOutputDuplication_MapDesktopSurface(this, pLockedRect)
{
   hr := DllCall(NumGet(NumGet(this+0)+12*A_PtrSize), "ptr", this, "ptr", pLockedRect)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0x887A0004   ; DXGI_ERROR_UNSUPPORTED
            return "DXGI_ERROR_UNSUPPORTED"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IDXGIOutputDuplication_UnMapDesktopSurface(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+13*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIOutputDuplication_ReleaseFrame(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+14*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIOutput1_DuplicateOutput(this, pDevice, ByRef ppOutputDuplication)
{
   hr := DllCall(NumGet(NumGet(this+0)+22*A_PtrSize), "ptr", this, "ptr", pDevice, "ptr*", ppOutputDuplication)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGISurface1_GetDC(this, Discard, ByRef phdc)
{
   hr := DllCall(NumGet(NumGet(this+0)+11*A_PtrSize), "ptr", this, "int", Discard, "ptr*", phdc)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGISurface1_ReleaseDC(this, pDirtyRect)
{
   hr := DllCall(NumGet(NumGet(this+0)+12*A_PtrSize), "ptr", this, "ptr", pDirtyRect)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IDXGIOutput1_Query(IDXGIOutput)
{ 
   hr := ComObjQuery(IDXGIOutput, "{00cddea8-939b-4b83-a340-a685226666cc}")
   if !hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   return hr
}

ID3D11Texture2D_Query(desktop_resource)
{ 
   hr := ComObjQuery(desktop_resource, "{6f15aaf2-d208-4e89-9ab4-489535d34f9c}")
   if !hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   return hr
}

IDXGISurface1_Query(Texture2D)
{ 
   hr := ComObjQuery(Texture2D, "{4AE63092-6327-4c1b-80AE-BFE12EA32B86}")
   if !hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   return hr
}

ID3D11DeviceContext_CopyResource(this, pDstResource, pSrcResource)
{
   hr := DllCall(NumGet(NumGet(this+0)+47*A_PtrSize), "ptr", this, "ptr", pDstResource, "ptr", pSrcResource)
   if ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID3D11DeviceContext_CopySubresourceRegion(this, pDstResource, DstSubresource, DstX, DstY, DstZ, pSrcResource, SrcSubresource, pSrcBox)
{
   hr := DllCall(NumGet(NumGet(this+0)+46*A_PtrSize), "ptr", this, "ptr", pDstResource, "uint", DstSubresource, "uint", DstX, "uint", DstY, "uint", DstZ, "ptr", pSrcResource, "uint", SrcSubresource, "ptr", pSrcBox)
   if ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID3D11DeviceContext_Map(this, pResource, Subresource, MapType, MapFlags, pMappedResource)
{
   hr := DllCall(NumGet(NumGet(this+0)+14*A_PtrSize), "ptr", this, "ptr", pResource, "uint", Subresource, "uint", MapType, "uint", MapFlags, "ptr", pMappedResource)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID3D11DeviceContext_Unmap(this, pResource, Subresource)
{
   hr := DllCall(NumGet(NumGet(this+0)+15*A_PtrSize), "ptr", this, "ptr", pResource, "uint", Subresource)
   if ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}



LOAD_DLL_Mf_Mfplat_Mfreadwrite()
{
   if !DllCall("GetModuleHandle","str","Mf")
      DllCall("LoadLibrary","Str", "Mf.dll", "ptr")
   if !DllCall("GetModuleHandle","str","Mfplat")
      DllCall("LoadLibrary","Str", "Mfplat.dll", "ptr")
   if !DllCall("GetModuleHandle","str","Mfreadwrite")
      DllCall("LoadLibrary","Str", "Mfreadwrite.dll", "ptr")
}

MFStartup(version, dwFlags)
{
   hr := DllCall("Mfplat.dll\MFStartup", "uint", version, "uint", dwFlags)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFShutdown()
{
   hr := DllCall("Mfplat.dll\MFShutdown")
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFTEnumEx(guidCategory, Flags, pInputType, pOutputType)
{
   if (A_PtrSize = 8)
      hr := DllCall("Mfplat\MFTEnumEx", "ptr", guidCategory, "uint", Flags, "ptr", pInputType, "ptr", pOutputType, "ptr*", pppMFTActivate, "uint*", pnumMFTActivate)
   else
      hr := DllCall("Mfplat\MFTEnumEx", "uint64", NumGet(guidCategory+0, 0, "uint64"), "uint64", NumGet(guidCategory+0, 8, "uint64"), "uint", Flags, "ptr", pInputType, "ptr", pOutputType, "ptr*", pppMFTActivate, "uint*", pnumMFTActivate)
   loop % pnumMFTActivate
   {
      IMFActivate := NumGet(pppMFTActivate + (A_Index - 1)*A_PtrSize)
      if (A_Index = 1)
         hardware_encoder := IMFActivate_GetAllocatedString(IMFActivate, MF_GUID(GUID, "MFT_FRIENDLY_NAME_Attribute"))
      Release(IMFActivate)
   }
   DllCall("ole32\CoTaskMemFree", "ptr", pppMFTActivate)
   return hardware_encoder
}

MFCreateSinkWriterFromURL(pwszOutputURL, pByteStream, pAttributes, ByRef ppSinkWriter)
{
   hr := DllCall("Mfreadwrite.dll\MFCreateSinkWriterFromURL", "str", pwszOutputURL, "ptr", pByteStream, "ptr", pAttributes, "ptr*", ppSinkWriter)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateSourceReaderFromMediaSource(pMediaSource, pAttributes, ByRef ppSourceReader)
{
   hr := DllCall("Mfreadwrite.dll\MFCreateSourceReaderFromMediaSource", "ptr", pMediaSource, "ptr", pAttributes, "ptr*", ppSourceReader)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateMediaType(ByRef ppMFType)
{
   hr := DllCall("Mfplat.dll\MFCreateMediaType", "ptr*", ppMFType)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateAttributes(ByRef ppMFAttributes, cInitialSize)
{
   hr := DllCall("Mfplat.dll\MFCreateAttributes", "ptr*", ppMFAttributes, "uint", cInitialSize)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateSample(ByRef ppIMFSample)
{
   hr := DllCall("Mfplat.dll\MFCreateSample", "ptr*", ppIMFSample)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateMemoryBuffer(cbMaxLength, ByRef ppBuffer)
{
   hr := DllCall("Mfplat.dll\MFCreateMemoryBuffer", "uint", cbMaxLength, "ptr*", ppBuffer)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCopyImage(pDest, lDestStride, pSrc, lSrcStride, dwWidthInBytes, dwLines)
{
   hr := DllCall("Mfplat.dll\MFCopyImage", "ptr", pDest, "int", lDestStride, "ptr", pSrc, "int", lSrcStride, "uint", dwWidthInBytes, "uint", dwLines)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFEnumDeviceSources(pAttributes, ByRef pppSourceActivate, ByRef pcSourceActivate)
{
   hr := DllCall("Mf.dll\MFEnumDeviceSources", "ptr", pAttributes, "ptr*", pppSourceActivate, "uint*", pcSourceActivate)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateCollection(ByRef ppIMFCollection)
{
   hr := DllCall("Mfplat.dll\MFCreateCollection", "ptr*", ppIMFCollection)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateAggregateSource(pSourceCollection, ByRef ppAggSource)
{
   hr := DllCall("Mf.dll\MFCreateAggregateSource", "ptr", pSourceCollection, "ptr*", ppAggSource)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSourceReader_SetCurrentMediaType(this, dwStreamIndex, pdwReserved, pMediaType)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "uint", pdwReserved, "ptr", pMediaType)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSourceReader_SetStreamSelection(this, dwStreamIndex, fSelected)
{
   hr := DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "int", fSelected)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSourceReader_GetNativeMediaType(this, dwStreamIndex, dwMediaTypeIndex, ByRef ppMediaType)
{
   hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "uint", dwMediaTypeIndex, "ptr*", ppMediaType)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0xC00D36B3   ; MF_E_INVALIDSTREAMNUMBER
            return "MF_E_INVALIDSTREAMNUMBER"
         if (hr&=0xFFFFFFFF) = 0xC00D36B9   ; MF_E_NO_MORE_TYPES
            return "MF_E_NO_MORE_TYPES"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IMFSourceReader_ReadSample(this, dwStreamIndex, dwControlFlags, pdwActualStreamIndex, pdwStreamFlags, pllTimestamp, ppSample)
{
   hr := DllCall(NumGet(NumGet(this+0)+9*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "uint", dwControlFlags, "uint", pdwActualStreamIndex, "uint", pdwStreamFlags, "int", pllTimestamp, "ptr", ppSample)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSourceReader_Flush(this, dwStreamIndex)
{
   hr := DllCall(NumGet(NumGet(this+0)+10*A_PtrSize), "ptr", this, "uint", dwStreamIndex)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_GetGUID(this, guidKey, ByRef pguidValue)
{
   VarSetCapacity(pguidValue, 16, 0)
   hr := DllCall(NumGet(NumGet(this+0)+10*A_PtrSize), "ptr", this, "ptr", guidKey, "ptr", &pguidValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   return &pguidValue
}

IMFAttributes_GetUINT64(this, guidKey, ByRef punValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+8*A_PtrSize), "ptr", this, "ptr", guidKey, "uint64*", punValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_GetUINT32(this, guidKey, ByRef punValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "ptr", guidKey, "uint*", punValue)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0xC00D36E6   ; MF_E_ATTRIBUTENOTFOUND
            return "MF_E_ATTRIBUTENOTFOUND"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IMFAttributes_SetUINT32(this, guidKey, unValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+21*A_PtrSize), "ptr", this, "ptr", guidKey, "uint", unValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_SetUINT64(this, guidKey, unValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+22*A_PtrSize), "ptr", this, "ptr", guidKey, "uint64", unValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_SetGUID(this, guidKey, guidValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+24*A_PtrSize), "ptr", this, "ptr", guidKey, "ptr", guidValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_SetUnknown(this, guidKey, pUnknown)
{
   hr := DllCall(NumGet(NumGet(this+0)+27*A_PtrSize), "ptr", this, "ptr", guidKey, "ptr", pUnknown)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFActivate_GetAllocatedString(this, guidKey)
{
   hr := DllCall(NumGet(NumGet(this+0)+13*A_PtrSize), "ptr", this, "ptr", guidKey, "ptr*", ppwszValue, "uint*", pcchLength)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   AllocatedString := StrGet(ppwszValue, pcchLength, "UTF-16")
   DllCall("ole32\CoTaskMemFree", "ptr", ppwszValue)
   return AllocatedString
}

IMFActivate_ActivateObject(this, riid, ByRef ppv)
{
   GUID(riid, riid)
   hr := DllCall(NumGet(NumGet(this+0)+33*A_PtrSize), "ptr", this, "ptr", &riid, "ptr*", ppv)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_SendStreamTick(this, dwStreamIndex, llTimestamp)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "int64", llTimestamp)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_AddStream(this, pMediaTypeOut, ByRef pdwStreamIndex)
{
   hr := DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "ptr", pMediaTypeOut, "ptr*", pdwStreamIndex)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_SetInputMediaType(this, dwStreamIndex, pInputMediaType, pEncodingParameters)
{
   hr := DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "ptr", pInputMediaType, "ptr", pEncodingParameters)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_BeginWriting(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_WriteSample(this, dwStreamIndex, pSample)
{
   hr := DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "ptr", pSample)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_Finalize(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+11*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaBuffer_Lock(this, ByRef ppbBuffer, ByRef pcbMaxLength, ByRef pcbCurrentLength)
{
   hr := DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "ptr*", ppbBuffer, "uint*", pcbMaxLength, "uint*", pcbCurrentLength)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaBuffer_Unlock(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaBuffer_SetCurrentLength(this, cbCurrentLength)
{
   hr := DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "uint", cbCurrentLength)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaSource_Shutdown(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+12*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_AddBuffer(this, pBuffer)
{
   hr := DllCall(NumGet(NumGet(this+0)+42*A_PtrSize), "ptr", this, "ptr", pBuffer)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_SetSampleTime(this, hnsSampleTime)
{
   hr := DllCall(NumGet(NumGet(this+0)+36*A_PtrSize), "ptr", this, "int64", hnsSampleTime)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_GetSampleDuration(this, ByRef phnsSampleDuration)
{
   hr := DllCall(NumGet(NumGet(this+0)+37*A_PtrSize), "ptr", this, "int64*", phnsSampleDuration)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_SetSampleDuration(this, hnsSampleDuration)
{
   hr := DllCall(NumGet(NumGet(this+0)+38*A_PtrSize), "ptr", this, "int64", hnsSampleDuration)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFCollection_AddElement(this, pUnkElement)
{
   hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "ptr", pUnkElement)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MF_GUID(ByRef GUID, name)
{
   static init:=1, _:={}
   if init
   {
      init:=0
      _.MF_MT_MAJOR_TYPE := [0x48eba18e, 0xf8c9, 0x4687, 0xbf, 0x11, 0x0a, 0x74, 0xc9, 0xf9, 0x6a, 0x8f]
      _.MF_MT_SUBTYPE := [0xf7e34c9a, 0x42e8, 0x4714, 0xb7, 0x4b, 0xcb, 0x29, 0xd7, 0x2c, 0x35, 0xe5]
      _.MF_MT_AVG_BITRATE := [0x20332624, 0xfb0d, 0x4d9e, 0xbd, 0x0d, 0xcb, 0xf6, 0x78, 0x6c, 0x10, 0x2e]
      _.MF_MT_INTERLACE_MODE := [0xe2724bb8, 0xe676, 0x4806, 0xb4, 0xb2, 0xa8, 0xd6, 0xef, 0xb4, 0x4c, 0xcd]
      _.MF_MT_FRAME_SIZE := [0x1652c33d, 0xd6b2, 0x4012, 0xb8, 0x34, 0x72, 0x03, 0x08, 0x49, 0xa3, 0x7d]
      _.MF_MT_FRAME_RATE := [0xc459a2e8, 0x3d2c, 0x4e44, 0xb1, 0x32, 0xfe, 0xe5, 0x15, 0x6c, 0x7b, 0xb0]
      _.MF_MT_PIXEL_ASPECT_RATIO := [0xc6376a1e, 0x8d0a, 0x4027, 0xbe, 0x45, 0x6d, 0x9a, 0x0a, 0xd3, 0x9b, 0xb6]
      _.MF_MT_AUDIO_AVG_BYTES_PER_SECOND := [0x1aab75c8, 0xcfef, 0x451c, 0xab, 0x95, 0xac, 0x03, 0x4b, 0x8e, 0x17, 0x31]
      _.MF_MT_AUDIO_BLOCK_ALIGNMENT := [0x322de230, 0x9eeb, 0x43bd, 0xab, 0x7a, 0xff, 0x41, 0x22, 0x51, 0x54, 0x1d]
      _.MF_MT_AUDIO_SAMPLES_PER_SECOND := [0x5faeeae7, 0x0290, 0x4c31, 0x9e, 0x8a, 0xc5, 0x34, 0xf6, 0x8d, 0x9d, 0xba]
      _.MF_MT_AUDIO_BITS_PER_SAMPLE := [0xf2deb57f, 0x40fa, 0x4764, 0xaa, 0x33, 0xed, 0x4f, 0x2d, 0x1f, 0xf6, 0x69]
      _.MF_MT_AUDIO_NUM_CHANNELS := [0x37e48bf5, 0x645e, 0x4c5b, 0x89, 0xde, 0xad, 0xa9, 0xe2, 0x9b, 0x69, 0x6a]
      _.MFT_CATEGORY_VIDEO_ENCODER := [0xf79eac7d, 0xe545, 0x4387, 0xbd, 0xee, 0xd6, 0x47, 0xd7, 0xbd, 0xe4, 0x2a]
      _.MF_TRANSCODE_CONTAINERTYPE := [0x150ff23f, 0x4abc, 0x478b, 0xac, 0x4f, 0xe1, 0x91, 0x6f, 0xba, 0x1c, 0xca]
      _.MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS := [0xa634a91c, 0x822b, 0x41b9, 0xa4, 0x94, 0x4d, 0xe4, 0x64, 0x36, 0x12, 0xb0]
      _.MFTranscodeContainerType_MPEG4 := [0xdc6cd05d, 0xb9d0, 0x40ef, 0xbd, 0x35, 0xfa, 0x62, 0x2c, 0x1a, 0xb2, 0x8a]
      _.MFT_FRIENDLY_NAME_Attribute := [0x314ffbae, 0x5b41, 0x4c95, 0x9c, 0x19, 0x4e, 0x7d, 0x58, 0x6f, 0xac, 0xe3]
      _.MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME := [0x60d0e559, 0x52f8, 0x4fa2, 0xbb, 0xce, 0xac, 0xdb, 0x34, 0xa8, 0xec, 0x1]
      _.MF_SINK_WRITER_DISABLE_THROTTLING := [0x08b845d8, 0x2b74, 0x4afe, 0x9d, 0x53, 0xbe, 0x16, 0xd2, 0xd5, 0xae, 0x4f]
      _.MF_LOW_LATENCY := [0x9c27891a, 0xed7a, 0x40e1, 0x88, 0xe8, 0xb2, 0x27, 0x27, 0xa0, 0x24, 0xee]
      _.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE := [0xc60ac5fe, 0x252a, 0x478f, 0xa0, 0xef, 0xbc, 0x8f, 0xa5, 0xf7, 0xca, 0xd3]
      _.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID := [0x14dd9a1c, 0x7cff, 0x41be, 0xb1, 0xb9, 0xba, 0x1a, 0xc6, 0xec, 0xb5, 0x71]
      _.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID := [0x8ac3587a, 0x4ae7, 0x42d8, 0x99, 0xe0, 0x0a, 0x60, 0x13, 0xee, 0xf9, 0x0f]
      _.MF_SOURCE_READER_DISCONNECT_MEDIASOURCE_ON_SHUTDOWN := [0x56b67165, 0x219e, 0x456d, 0xa2, 0x2e, 0x2d, 0x30, 0x04, 0xc7, 0xfe, 0x56]
      _.MF_SOURCE_READER_ASYNC_CALLBACK := [0x1e3dbeac, 0xbb43, 0x4c35, 0xb5, 0x07, 0xcd, 0x64, 0x44, 0x64, 0xc9, 0x65]
      _.MFSampleExtension_Discontinuity := [0x9cdf01d9, 0xa0f0, 0x43ba, 0xb0, 0x77, 0xea, 0xa0, 0x6c, 0xbd, 0x72, 0x8a]
      _.MFMediaType_Video := [0x73646976, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFMediaType_Audio := [0x73647561, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xAA, 0x00, 0x38, 0x9B, 0x71]
      _.MFAudioFormat_AAC := [0x1610, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFAudioFormat_Float := [0x0003, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFAudioFormat_PCM := [0x0001, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_H264 := [0x34363248, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]   ; FCC("H264") = 0x34363248
      _.MFVideoFormat_RGB32 := [0x00000016, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_ARGB32 := [0x00000015, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_I420 := [0x30323449, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_IYUV := [0x56555949, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_NV12 := [0x3231564E, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_YUY2 := [0x32595559, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_YV12 := [0x32315659, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_RGB24 := [0x00000014, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
   }
   if _.haskey(name)
   {
      p := _[name]
      VarSetCapacity(GUID,16)
      ,NumPut(p.1+(p.2<<32)+(p.3<<48),GUID,0,"int64")
      ,NumPut(p.4+(p.5<<8)+(p.6<<16)+(p.7<<24)+(p.8<<32)+(p.9<<40)+(p.10<<48)+(p.11<<56),GUID,8,"int64")
      return &GUID
   }
   else return name
}

GUID(ByRef GUID, sGUID)
{
    VarSetCapacity(GUID, 16, 0)
    return DllCall("ole32\CLSIDFromString", "WStr", sGUID, "Ptr", &GUID) >= 0 ? &GUID : ""
}

FCC(var)
{
   c := StrSplit(var)
   msgbox % clipboard := Format("{:#x}",((Asc(c[1])&255)+((Asc(c[2])&255)<<8)+((Asc(c[3])&255)<<16)+((Asc(c[4])&255)<<24)))
}

Release(this)
{
   DllCall(NumGet(NumGet(this+0)+2*A_PtrSize), "ptr", this)
   if ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MemoryDifference(ptr1, ptr2, num)
{
   return DllCall("msvcrt\memcmp", "ptr", ptr1, "ptr", ptr2, "int", num) 
}

_Error(val)
{
   msgbox % val
   ExitApp
}

checkCoordinates(ByRef start1, ByRef end1, ByRef start2, ByRef end2, hardware_encoder:="")
{
   if !InStr(hardware_encoder, "NVIDIA") or ((x1 != "") and (CaptureCoordinatesWithCPU = true))
      min1 := min2 := 33
   else
      min1 := 33, min2 := 17
   max1 := A_ScreenWidth, max2 := A_ScreenHeight
   loop 2
   {
      if (end%A_Index% - start%A_Index% < min%A_Index%)
         end%A_Index% := start%A_Index% + min%A_Index%
      if (!InStr(hardware_encoder, "NVIDIA") or ((x1 != "") and (CaptureCoordinatesWithCPU = true))) and (mod(end%A_Index% - start%A_Index%, 2) != 0)
         end%A_Index%++
      if (end%A_Index% > max%A_Index%)
      {
         start%A_Index% += max%A_Index%-end%A_Index%
         end%A_Index% := max%A_Index%
      }
   }
}



IMFSourceReaderCallback_new() {
   static VTBL := [ "QueryInterface"
                  , "AddRef"
                  , "Release"
                  , "OnReadSample" A_PtrSize
                  , "OnFlush"
                  , "OnEvent" ]
                  
        , heapSize := A_PtrSize*10
        , heapOffset := A_PtrSize*9
        
        , flags := (HEAP_GENERATE_EXCEPTIONS := 0x4) | (HEAP_NO_SERIALIZE := 0x1)
        , HEAP_ZERO_MEMORY := 0x8
   
   hHeap := DllCall("HeapCreate", "UInt", flags, "Ptr", 0, "Ptr", 0, "Ptr")
   addr := IMFSourceReaderCallback := DllCall("HeapAlloc", "Ptr", hHeap, "UInt", HEAP_ZERO_MEMORY, "Ptr", heapSize, "Ptr")
   addr := NumPut(addr + A_PtrSize, addr + 0)
   for k, v in VTBL
      addr := NumPut( RegisterSyncCallback("IMFSourceReaderCallback_" . v), addr + 0 )
   NumPut(hHeap, IMFSourceReaderCallback + heapOffset)
   Return IMFSourceReaderCallback
}

IMFSourceReaderCallback_QueryInterface(this, riid, ppvObject)
{
   static IID_IUnknown, IID_IMFSourceReaderCallback
   if (!VarSetCapacity(IID_IUnknown))
   {
      VarSetCapacity(IID_IUnknown, 16), VarSetCapacity(IID_IMFSourceReaderCallback, 16)
      DllCall("ole32\CLSIDFromString", "WStr", "{00000000-0000-0000-C000-000000000046}", "Ptr", &IID_IUnknown)
      DllCall("ole32\CLSIDFromString", "WStr", "{deec8d99-fa1d-4d82-84c2-2c8969944867}", "Ptr", &IID_IMFSourceReaderCallback)
   }
   if (DllCall("ole32\IsEqualGUID", "Ptr", riid, "Ptr", &IID_IMFSourceReaderCallback) || DllCall("ole32\IsEqualGUID", "Ptr", riid, "Ptr", &IID_IUnknown))
   {
      NumPut(this, ppvObject+0, "Ptr")
      IMFSourceReaderCallback_AddRef(this)
      return 0 ; S_OK
   }
   NumPut(0, ppvObject+0, "Ptr")
   return 0x80004002 ; E_NOINTERFACE
}

IMFSourceReaderCallback_AddRef(this) {
   static refOffset := A_PtrSize*8
   NumPut(refCount := NumGet(this + refOffset, "UInt") + 1, this + refOffset, "UInt")
   Return refCount
}

IMFSourceReaderCallback_Release(this) {
   static refOffset := A_PtrSize*8
        , heapOffset := A_PtrSize*9
   NumPut(refCount := NumGet(this + refOffset, "UInt") - 1, this + refOffset, "UInt")
   if (refCount = 0) {
      hHeap := NumGet(this + heapOffset)
      DllCall("HeapDestroy", "Ptr", hHeap)
   }
   Return refCount
}

/*
    RegisterSyncCallback

    A replacement for RegisterCallback for use with APIs that will call
    the callback on the wrong thread.  Synchronizes with the script's main
    thread via a window message.

    This version tries to emulate RegisterCallback as much as possible
    without using RegisterCallback, so shares most of its limitations,
    and some enhancements that could be made are not.

    Other differences from v1 RegisterCallback:
      - Variadic mode can't be emulated exactly, so is not supported.
      - A_EventInfo can't be set in v1, so is not supported.
      - Fast mode is not supported (the option is ignored).
      - ByRef parameters are allowed (but ByRef is ignored).
      - Throws instead of returning "" on failure.
*/
RegisterSyncCallback(FunctionName, Options:="", ParamCount:="")
{
    if !(fn := Func(FunctionName)) || fn.IsBuiltIn
        throw Exception("Bad function", -1, FunctionName)
    if (ParamCount == "")
        ParamCount := fn.MinParams
    if (ParamCount > fn.MaxParams && !fn.IsVariadic || ParamCount+0 < fn.MinParams)
        throw Exception("Bad param count", -1, ParamCount)

    static sHwnd := 0, sMsg, sSendMessageW
    if !sHwnd
    {
        Gui RegisterSyncCallback: +Parent%A_ScriptHwnd% +hwndsHwnd
        OnMessage(sMsg := 0x8000, Func("RegisterSyncCallback_Msg"))
        sSendMessageW := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "user32.dll", "ptr"), "astr", "SendMessageW", "ptr")
    }

    if !(pcb := DllCall("GlobalAlloc", "uint", 0, "ptr", 96, "ptr"))
        throw
    DllCall("VirtualProtect", "ptr", pcb, "ptr", 96, "uint", 0x40, "uint*", 0)

    p := pcb
    if (A_PtrSize = 8)
    {
        /*
        48 89 4c 24 08  ; mov [rsp+8], rcx
        48 89 54'24 10  ; mov [rsp+16], rdx
        4c 89 44 24 18  ; mov [rsp+24], r8
        4c'89 4c 24 20  ; mov [rsp+32], r9
        48 83 ec 28'    ; sub rsp, 40
        4c 8d 44 24 30  ; lea r8, [rsp+48]  (arg 3, &params)
        49 b9 ..        ; mov r9, .. (arg 4, operand to follow)
        */
        p := NumPut(0x54894808244c8948, p+0)
        p := NumPut(0x4c182444894c1024, p+0)
        p := NumPut(0x28ec834820244c89, p+0)
        p := NumPut(  0xb9493024448d4c, p+0) - 1
        lParamPtr := p, p += 8

        p := NumPut(0xba, p+0, "char") ; mov edx, nmsg
        p := NumPut(sMsg, p+0, "int")
        p := NumPut(0xb9, p+0, "char") ; mov ecx, hwnd
        p := NumPut(sHwnd, p+0, "int")
        p := NumPut(0xb848, p+0, "short") ; mov rax, SendMessageW
        p := NumPut(sSendMessageW, p+0)
        /*
        ff d0        ; call rax
        48 83 c4 28  ; add rsp, 40
        c3           ; ret
        */
        p := NumPut(0x00c328c48348d0ff, p+0)
    }
    else ;(A_PtrSize = 4)
    {
        p := NumPut(0x68, p+0, "char")      ; push ... (lParam data)
        lParamPtr := p, p += 4
        p := NumPut(0x0824448d, p+0, "int") ; lea eax, [esp+8]
        p := NumPut(0x50, p+0, "char")      ; push eax
        p := NumPut(0x68, p+0, "char")      ; push nmsg
        p := NumPut(sMsg, p+0, "int")
        p := NumPut(0x68, p+0, "char")      ; push hwnd
        p := NumPut(sHwnd, p+0, "int")
        p := NumPut(0xb8, p+0, "char")      ; mov eax, &SendMessageW
        p := NumPut(sSendMessageW, p+0, "int")
        p := NumPut(0xd0ff, p+0, "short")   ; call eax
        p := NumPut(0xc2, p+0, "char")      ; ret argsize
        p := NumPut((InStr(Options, "C") ? 0 : ParamCount*4), p+0, "short")
    }
    NumPut(p, lParamPtr+0) ; To be passed as lParam.
    p := NumPut(&fn, p+0)
    p := NumPut(ParamCount, p+0, "int")
    return pcb
}

RegisterSyncCallback_Msg(wParam, lParam)
{
    if (A_Gui != "RegisterSyncCallback")
        return
    fn := Object(NumGet(lParam + 0))
    paramCount := NumGet(lParam + A_PtrSize, "int")
    params := []
    Loop % paramCount
        params.Push(NumGet(wParam + A_PtrSize * (A_Index-1)))
    return %fn%(params*)
}

IMFSourceReaderCallback_OnReadSample4(this_, hrStatus, dwStreamIndex, dwStreamFlags, llTimestamp, llTimestamp1, pSample)
{
   Static audioStart, gapAudio
   critical
   if hrStatus
      _Error(A_ThisFunc " error: " hrStatus "`nErrorLevel: " ErrorLevel)
   llTimestamp |= (llTimestamp1 << 32)
   if (pSample != 0)
   {
      if (gapAudio = 1)
      {
         IMFAttributes_SetUINT32(pSample, MF_GUID(GUID, "MFSampleExtension_Discontinuity"), true)
         gapAudio := ""
      }
      if (audioStart = "")
         audioStart := llTimestamp
      IMFSample_SetSampleTime(pSample, llTimestamp - audioStart)
      IMFSinkWriter_WriteSample(pSinkWriter, audioStreamIndex, pSample)
   }
   else if (dwStreamFlags & MF_SOURCE_READERF_STREAMTICK := 256) and (audioStart != "")
   {
      IMFSinkWriter_SendStreamTick(pSinkWriter, audioStreamIndex, llTimestamp - audioStart)
      gapAudio := 1
   }
   if (flush = "")
      IMFSourceReader_ReadSample(SourceReader, MF_SOURCE_READER_ANY_STREAM := 0xFFFFFFFE, 0, 0, 0, 0, 0)
   else
   {
      Release(IMFSourceReaderCallback)
      Release(SourceReader)
      SourceReader := IMFSourceReaderCallback := flush := audioStart := gapAudio := ""
   }
   return
}

IMFSourceReaderCallback_OnReadSample8(this_, hrStatus, dwStreamIndex, dwStreamFlags, llTimestamp, pSample)
{
   Static audioStart, gapAudio
   critical
   if hrStatus
      _Error(A_ThisFunc " error: " hrStatus "`nErrorLevel: " ErrorLevel)
   if (pSample != 0)
   {
      if (gapAudio = 1)
      {
         IMFAttributes_SetUINT32(pSample, MF_GUID(GUID, "MFSampleExtension_Discontinuity"), true)
         gapAudio := ""
      }
      if (audioStart = "")
         audioStart := llTimestamp
      IMFSample_SetSampleTime(pSample, llTimestamp - audioStart)
      IMFSinkWriter_WriteSample(pSinkWriter, audioStreamIndex, pSample)
   }
   else if (dwStreamFlags & MF_SOURCE_READERF_STREAMTICK := 256) and (audioStart != "")
   {
      IMFSinkWriter_SendStreamTick(pSinkWriter, audioStreamIndex, llTimestamp - audioStart)
      gapAudio := 1
   }
   if (flush = "")
      IMFSourceReader_ReadSample(SourceReader, MF_SOURCE_READER_ANY_STREAM := 0xFFFFFFFE, 0, 0, 0, 0, 0)
   else
   {
      Release(IMFSourceReaderCallback)
      Release(SourceReader)
      SourceReader := IMFSourceReaderCallback := flush := audioStart := gapAudio := ""
   }
   return
}

IMFSourceReaderCallback_OnFlush(this_, dwStreamIndex)
{
   return
}

IMFSourceReaderCallback_OnEvent(this_)
{
   return
}

Check(Name, FPS, RTS)
{
 If Name =
    Return 0
 If FPS =
    Return 0
 If RTS =
    Return 0

Return 1
}

CheckDX11()
{
 if !FileExist("C:\Windows\System32\d3d11.dll")
     Return 0

Return 1
}

GetDevices()
{
   NUM_CHANNELSMax := BITS_PER_SAMPLEMax := SAMPLES_PER_SECONDMax := BYTES_PER_SECONDMax := StreamNumberAudio := TypeNumberAudio := AudioSources := ""
   audiobasedevice := audiodevice
   IMFSourceReaderCallback := IMFSourceReaderCallback_new()
   MFCreateAttributes(pMFAttributes, 1)
   IMFAttributes_SetGUID(pMFAttributes, MF_GUID(GUID, "MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE"), MF_GUID(GUID1, "MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID"))
   MFEnumDeviceSources(pMFAttributes, pppSourceActivate, pcSourceActivate)
   Loop % pcSourceActivate
   {
      IMFActivate := NumGet(pppSourceActivate + (A_Index - 1)*A_PtrSize)
      devicename := IMFActivate_GetAllocatedString(IMFActivate, MF_GUID(GUID, "MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME"))
         basedevicename := devicename
         loop
         {
            if !InStr(Audiodevicenames, """" devicename """|")
               break
            devicename := basedevicename "[" A_Index+1 "]"
         }
         Audiodevicenames .= "" devicename ""
   }
   DllCall("ole32\CoTaskMemFree", "ptr", pppSourceActivate)
   Release(pMFAttributes)
   pMFAttributes := ""
      if (Audiodevicenames = "")
         Audiodevicenames .= "None"
      ;msgbox % clipboard := Audiodevicenames
      Return clipboard := Audiodevicenames
}

Counter:
Secon--
ToolTip,Recording.. %Secon%, 0, 0, Sec
;ToolTip, x0 y0 zh0 b FM9 FS10 CT800000 , Seconds, %Secon%, Sec , ,
WinSet, Transparent, 200, Sec
Return

GuiClose:
ExitApp