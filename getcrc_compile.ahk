this_file:=New Crc(A_ScriptFullPath)
INIT_CRC:=this_file.crc ; This is the initial CRC at load time used to make sure the file
						; hasn't been re-written/tampered with during runtime
						; You can check my CRC I provide with this very program itself.
; Get or check CRC for a file
#SingleInstance,Force
; Init - Optimization
SetBatchLines,-1
SetWinDelay,0
SetKeyDelay,-1
;Debug(A_LineNumber,file.file "`n" file.crc "`n" file.Check(file.file,file.crc))

; Init - Vars
TITLE:="NPS CRC Check"

; Init - menu
Menu,Tray,NoStandard
Menu,Tray,Add,&Reload %TITLE%,Restart
Menu,Tray,Add
Menu,Tray,Add,E&xit %TITLE%,GuiClose

; Init - Gui
Gui,Font,s13 c0x212121,Segoe UI
Gui,Color,0x212121,0xF0F0F0
Gui,-Caption +Border
Gui,Margin,0,0
Gui,Font,c0x01579B
GuiButton(TITLE,"TITLE_VAR","TitleBack",,0xF0F0F0,0x212121,0,0,502,28)
MinButton(454,20,0x212121,0x212121)
CloseButton(478,4,0x212121,0xFF5252)
Gui,Font,s11 c0xF0F0F0
Gui,Add,Text,y+4 x8 w300 Section,Choose your file to check or generate CRC: 
Gui,Font,s9 c0x212121, Consolas
Gui,Add,Edit,y+4 vFileText gFileTextCheck w400 h28 0x400000 0x400 HwndCRC_EDIT_HWND
Gui,Font,s11 c0x01579B,Segoe UI
GuiButton("&Browse File","BROWSE_VAR","BrowseText",,0xF0F0F0,0xFFFFFF,"+0","p",86,28)
Gui,Font,s9 c0x212121, Consolas
Gui,Add,Edit,xs y+4 w243 h28 0x400000 vCheckCrcVar
Gui,Font,s11 c0x01579B,Segoe UI
GuiButton("&Check CRC","CHECK_VAR","CheckBack",,0xF0F0F0,0xFFFFFF,"+0","p",243,28)
GuiButton("&Get CRC","GET_VAR","GetBack",,0xF0F0F0,0xFFFFFF,"s","+4",486,28)
Gui,Add,Text,x0 y+0 h8 w482
Gui,+LastFound
gui_id:=WinExist()
Gui,Show,AutoSize,%TITLE%
msgList:={"WM_KEYUP":"0x101","WM_LBUTTONDOWN":"0x201"
		,"WM_KEYDN":"0x100","WM_MOUSEHOVER":"0x200"}
For message, hex in msgList
	OnMessage(hex,message)
message:=hex:=""
GetControls(TITLE)
SetTimer,CheckThisFileSecure,1
Return

; Hotkeys
#If WinActive("ahk_id " gui_id)
	!b::Gosub,GetFile
	!c::Gosub,CheckCRC
	!g::Gosub,GetCRC
#IfWinActive

; Functions
FileCRC32(sFile="",cSz=4){ ; by SKAN www.autohotkey.com/community/viewtopic.php?t=64211
	cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 10-Oct-2009
	hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
	IfLess,hFil,1, Return,hFil
	hMod := DllCall( "LoadLibrary", Str,"ntdll.dll" ), CRC32 := 0
	DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
	Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
		DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,Bytes, UInt,0 )
		, CRC32 := DllCall( "NTDLL\RtlComputeCrc32", UInt,CRC32, UInt,&Buffer, UInt,Bytes, UInt )
	DllCall( "CloseHandle", UInt,hFil )
	SetFormat, Integer, % SubStr( ( A_FI := A_FormatInteger ) "H", 0 )
	CRC32 := SubStr( CRC32 + 0x1000000000, -7 ), DllCall( "CharUpper", Str,CRC32 )
	SetFormat, Integer, %A_FI%
	Return CRC32, DllCall( "FreeLibrary", UInt,hMod )
}
Class Crc {
	__New(file){
		If this.file:=FileExist(file)?file:"" {
			this.crc:=this.Get(file)
		}
	}
	Get(file){
		Return this.FileCRC32(file)
	}
	Check(file,crc){
		Return (this.FileCRC32(file)=crc)
	}
	FileCRC32(sFile="",cSz=4){ ; by SKAN www.autohotkey.com/community/viewtopic.php?t=64211
		cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 10-Oct-2009
		hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
		IfLess,hFil,1, Return,hFil
		hMod := DllCall( "LoadLibrary", Str,"ntdll.dll" ), CRC32 := 0
		DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
		Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
			DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,Bytes, UInt,0 )
			, CRC32 := DllCall( "NTDLL\RtlComputeCrc32", UInt,CRC32, UInt,&Buffer, UInt,Bytes, UInt )
		DllCall( "CloseHandle", UInt,hFil )
		SetFormat, Integer, % SubStr( ( A_FI := A_FormatInteger ) "H", 0 )
		CRC32 := SubStr( CRC32 + 0x1000000000, -7 ), DllCall( "CharUpper", Str,CRC32 )
		SetFormat, Integer, %A_FI%
		Return CRC32, DllCall( "FreeLibrary", UInt,hMod )
	}
}
Debug(title:="Debug Pause",msg:=0,type:=64,exit:=0){
	MsgBox,% (Mod(type,16)=0)?type:64,%title%,%msg%
	If exit
		ExitApp
}
GetControls(title,control:=0,posvar:=0){
	If (control && posvar)
		{
			namenum:=EnumVarName(control)
			ControlGetPos,x,y,w,h,%control%,%title%
			pos:=(posvar == "X")?x
			:(posvar == "Y")?y
			:(posvar == "W")?w
			:(posvar == "H")?h
			:(posvar == "X2")?x+w
			:(posvar == "Y2")?Y+H
			:0
			Globals.SetGlobal(namenum posvar,pos)
			Return pos
		}
	Else If !(control && posvar)
		{
			WinGet,a,ControlList,%title%
			Loop,Parse,a,`n
				{
					namenum:=EnumVarName(A_LoopField)
					If namenum
						{
							ControlGetPos,x,y,w,h,%A_LoopField%,%title%
							Globals.SetGlobal(namenum "X",x)
							Globals.SetGlobal(namenum "Y",y)
							Globals.SetGlobal(namenum "W",w)
							Globals.SetGlobal(namenum "H",h)
							Globals.SetGlobal(namenum "X2",x+w)
							Globals.SetGlobal(namenum "Y2",y+h)				
						}
				}
			Return a
		}
}
EnumVarName(control){
	name:=InStr(control,"msctls_p")?"MP"
	:InStr(control,"Static")?"S"
	:InStr(control,"Button")?"B"
	:InStr(control,"Edit")?"E"
	:InStr(control,"ListBox")?"LB"
	:InStr(control,"msctls_u")?"UD"
	:InStr(control,"ComboBox")?"CB"
	:InStr(control,"ListView")?"LV"
	:InStr(control,"SysTreeView")?"TV"
	:InStr(control,"SysLink")?"L"
	:InStr(control,"msctls_h")?"H"
	:InStr(control,"SysDate")?"TD"
	:InStr(control,"SysMonthCal")?"MC"
	:InStr(control,"msctls_t")?"SL"
	:InStr(control,"msctls_s")?"SB"
	:InStr(control,"327701")?"AX"
	:InStr(control,"SysTabC")?"T"
	:0
	num:=(name == "MP")?SubStr(control,18)
	:(name == "S")?SubStr(control,7)
	:(name == "B")?SubStr(control,7)
	:(name == "E")?SubStr(control,5)
	:(name == "LB")?SubStr(control,8)
	:(name == "UD")?SubStr(control,15)
	:(name == "CB")?SubStr(control,9)
	:(name == "LV")?SubStr(control,14)
	:(name == "TV")?SubStr(control,14)
	:(name == "L")?SubStr(control,8)
	:(name == "H")?SubStr(control,16)
	:(name == "TD")?SubStr(control,18)
	:(name == "MC")?SubStr(control,14)
	:(name == "SL")?SubStr(control,18)
	:(name == "SB")?SubStr(control,19)
	:(name == "AX")?SubStr(control,5)
	:(name == "T")?SubStr(control,16)
	:0
	Return name num
}
WM_KEYDN(msgs*){
	Global
	If MouseOver(E1X,E1Y,E1X2,E1Y2,"Client"){
		GuiControlGet,_current_browse_txt_,,FileText
		If (_current_browse_txt_!=file){
			Send,{BackSpace}
			GuiControl,,FileText,% file
		}
	}
}
WM_KEYUP(msgs*){
	Global
	If MouseOver(E1X,E1Y,E1X2,E1Y2,"Client"){
		GuiControlGet,_current_browse_txt_,,FileText
		If (_current_browse_txt_!=file){
			Send,{BackSpace}
			GuiControl,,FileText,% file
		}
	}
}
WM_MOUSEHOVER(){
	Global
	SetTimer,OVER_E1,-1000
	If MouseOver(E1X,E1Y,E1X2,E1Y2,"Client"){
		GuiControlGet,_current_browse_txt_,,FileText
		If (_current_browse_txt_!=file)
			GuiControl,,FileText,% file
	}
}
WM_LBUTTONDOWN(){
	Global
	If WinActive("ahk_id " gui_id){
		If MouseOver(S1X,S1Y,S1X2,S1Y2,"Client")
			PostMessage,0xA1,2,,,ahk_id %gui_id%
		If MouseOver(S3X,S3Y,S3X2,S3Y2,"Client")
			Gosub,GetFile
		If MouseOver(S5X,S5Y,S5X2,S5Y2,"Client")
			Gosub,GetCRC
		If MouseOver(S4X,S4Y,S4X2,S4Y2,"Client")
			Gosub,CheckCRC
		If MouseOver(MP2X,MP7Y,MP6X2,MP6Y2,"Client")
			WinMinimize,ahk_id %gui_id%
		If MouseOver(MP7X,MP7Y,MP15X2,MP15Y2,"Client")
			WinClose,ahk_id %gui_id%
	}
}
; Classes
Class Globals { ; my favorite way to set and retrive global tions. Good for
	SetGlobal(name,value=""){ ; setting globals from other functions
		Global
		%name%:=value
		Return
	}
	GetGlobal(name){	
		Global
		Local var:=%name%
		Return var
	}
}
CloseButton(x,y,lcolor,dcolor,subWin:="",small:=False){
	Global
	Local big
	small:=small?3:4
	big:=small*3
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% x%x% y%y% w%small% h%small% vClose1, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 x+0 w%small% h%small% vClose2, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 x+0 w%small% h%small% vClose3, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 xp-%small% w%small% h%small% vClose4, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 xp-%small% w%small% h%small% vClose5, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp-%big% xp+%big% w%small% h%small% vClose6, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp-%small% x+0 w%small% h%small% vClose7, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp+%big% xp-%small% w%small% h%small% vClose8, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 x+0 w%small% h%small% vClose9, 100
}
MinButton(x,y,lcolor,dcolor,subWin:="",small:=False){
	Global
	Local big
	small:=small?3:4
	big:=small*3
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% x%x% y%y% w%small% h%small% vMin1, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin2, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin3, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin4, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin5, 100
}
GuiButton(title,txtvar,progvar,subWin:="",color:="0x1D1D1D",border:="0x1D1D1D",x:="+0",y:="+0",w:="",h=""){
	Global
	%txtvar%:=title
	Gui,%subWin%Add,Progress,x%x% y%y% w%w% h%h% Background%border% c%color% v%progvar%,100
	Gui,%subWin%Add,Text,w%w% h%h% xp yp Center +BackgroundTrans 0x200 v%txtvar%,%title%
}
MouseOver(x1,y1,x2,y2,coordmode:="Screen"){
	CoordMode,Mouse,%coordmode%
	MouseGetPos,_x,_y
	Return (_x>=x1 AND _x<=x2 AND _y>=y1 AND _y<=y2)
}

GetFile:
	last_file:=file
	FileSelectFile,file,3,%A_MyDocuments%,Get file for CRC generation/check:
	GuiControl,,FileText,% file?file:last_file
	last_file:=!file?last_file:""
	file:=file?file:last_file
Return
FileTextCheck:
	
Return
GetCRC:
	If file {
		CRC:=FileCRC32(file)
		Debug(TITLE " Info","CRC for file:`n" file " :`n`n" CRC "`n`nCopied to your clipboard.")
		Clipboard:=CRC
		CRC:=""
	} Else Debug(TITLE " Info","No file provided for CRC generation.",48)
Return
CheckCRC:
	Gui,Submit,NoHide
	If (file And CheckCrcVar) {
		CRC:=FileCRC32(file)
		chck:=(CRC=CheckCrcVar)
		Debug(chck?TITLE " Info":TITLE " Error"
			,chck?"File: " file "`nCRC = " A_Tab A_Tab CRC "`nMatches: " A_Tab CheckCrcVar
			:"File: " file "`nCRC = " A_Tab A_Tab CRC "`nDoes not match: " A_Tab CheckCrcVar
			,chck?64:16)
		CRC:=chck:=""
	} Else Debug(TITLE " Info",(!file And CheckCrcVar)?"No file provided for CRC check."
				:(!CheckCrcVar And file)?"No CRC number provided for CRC check."
				:"No file or CRC number provided for CRC check.",48)
Return
CheckThisFileSecure: ; This sub goes with the corresponding function that calls it, prevents this program from being
	If ! this_file.Check(A_ScriptFullPath,INIT_CRC){ ; altered while it is running. It will exit program if check fails.
		Debug(TITLE " Error","This program has been tampered with since it was ran this time."
			. " This is a fail-safe feature.`n`n" TITLE " will now exit.",16,1)
	}
Return
TT_OFF:
	ToolTip,,,,20
Return
OVER_E1:
	If MouseOver(E2X,E2Y,E2X2,E2Y2,"Client"){
		ToolTip,% "Enter the original file`'s CRC hash to check`nagainst the current files CRC into this edit`nbox...",,,20
		SetTimer,TT_OFF,1501
	}
Return
Restart:
	Try Run,%A_ScriptFullPath%
	Catch RESTART_ERR {
		Debug(TITLE " Error","Could not reload " TITLE ".`nPlease exit and then start " TITLE " again.")
		Return
	}
	ExitApp
Return
GuiClose:
	ExitApp