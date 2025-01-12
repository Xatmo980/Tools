#Include cJson.ahk
#NoTrayIcon
Gui, Add, GroupBox, x2 y-1 w320 h50 , Guild ID
Gui, Add, Edit, vLead x12 y19 w300 h20 , 
Gui, Add, Radio, vR1 x22 y49 w50 h20 , Json
Gui, Add, Radio, vR2 x82 y49 w50 h20 , Html
Gui, Add, Radio, vR3 x142 y49 w60 h20 , Text
Gui, Add, Button, gExtract x202 y49 w110 h20 , Export
Gui, Show, w334 h78,(Mee6)LeaderboardExtractor
return

Extract()
{
 GuiControlGet, ID,, Lead
 LeaderBoard := "https://mee6.xyz/api/plugins/levels/leaderboard/" . ID . "?limit=999&page=0"
 Text := Connect(LeaderBoard, Method := "GET", PostData)
 If CheckError401(Text)
    {
     MsgBox % "(Received Error Code 401) - You may need to set your leaderboard to public in your mee6 settings"
     return
    }
 If CheckError404(Text)
   {
    MsgBox % "(Received Error Code 404) - The Guild was not found on Mee6"
    return
   }
 type := CheckType()
 if type = Json
   {
    ExportJson(Text)
    return
   }
 if type = html
    {
     ExportHTML(Text)
     return
    }
 if type = Tex
    {
     ExportTEXT(Text)
     return
    }
}

CheckType()
{
 GuiControlGet, Json,, R1
  If Json
    return "Json"
 GuiControlGet, html,, R2
  If html
    return "html"
 GuiControlGet, Text,, R3
  If Text
    return "Tex"
}
ExportHTML(Text)
{
 A = 1
 obj := cJson.Loads(Text)
 Style = <style>`nbody {`n   background-color: #23272A`;`n   font-size:6px`;`n   text-align:center`;`n   color: #FFFFFF`;`n}`ntd`, th {`n   border: 1px solid #23272A`;`n   text-align: center`;`n   padding: 10px`;`n}`nimg {`n   float:left`;`n   margin-right:-60px`;`n}`n</style>
 Head .= "<html>`n" . Style . "<body>`n<center>`n<table style=""width:70`%`;border`:1px solid black`;border-radius`:10px`;background-color:#2C2F33"">`n<tr>`n<th>Username</th>`n<th>level</th>`n<th>messages</th>`n<th>xp</th>`n</tr>"
  loop % obj.players.Length()
  {
   Data .= "<tr><td><img src=""https://cdn.discordapp.com/avatars/" . obj.players[A].id . "/" . obj.players[A].avatar . ".webp?size=64"">" . obj.players[A].username .   "</td>`n"
   Data .= "<td>" . obj.players[A].level . "</td>`n"
   Data .= "<td>" . obj.players[A].message_count . "</td>`n"
   Data .= "<td>" . obj.players[A].xp . "</td>`n</tr>`n"
   A++
  }
 Footer .= "</table></center></body></html>"
 FileAppend, % Head . Data . Footer, Users.html
}

ExportTEXT(Text)
{
 A = 1
 obj := cJson.Loads(Text)
 Data .= "Username      " . "level   " . "Messages    " . "xp`n"
  loop % obj.players.Length()
  {
   Data .= obj.players[A].username . "       " . obj.players[A].level . "        " . obj.players[A].message_count . "     " . obj.players[A].xp . "`n"
   A++
  }
 FileAppend, % Data, Users.txt
}

ExportJson(Text)
{
 FileAppend % Text, Users.json
}

CheckError401(Text)
{
 obj := cJson.Loads(Text)
 if obj.status_code = 401
    return 1
 else
    return 0
}

CheckError404(Text)
{
 obj := cJson.Loads(Text)
 if obj.status_code = 404
    return 1
 else
    return 0
}

Connect(Url, Method, PostData)
{
 HTTP := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
 HTTP.Open(Method, Url, true)
 HTTP.Send(PostData)
 HTTP.WaitForResponse()
 Text := HTTP.ResponseText
return Text
}

GuiClose:
ExitApp