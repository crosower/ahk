;1920x1080 resolution
;builds and ingame settings: https://imgur.com/a/FUxbMtK, no -zoom in any riven

#SingleInstance Force
#Persistent
#NoEnv
#InstallKeybdHook
SendMode Input
Process, Priority,, A
ListLines Off
SetWinDelay, -1
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1, -1
SetControlDelay, -1
#MaxHotkeysPerInterval 99000000
#MaxThreads 255
#KeyHistory 0

#include ui.ahk
#Include timers.ahk
#Include ImageSearchAdvanced.ahk

;---------------------------------------------------Waters---------------------------------------------------

global MidLimb:= 1895
global CRLimb := 1895
global CLLimb := 2393

;---------------------------------------------------Zenith n propa---------------------------------------------------

global betweenP_Z      := 1612	
global desiredLimb     := -30		

global desiredLimbTime := 17186 - betweenP_Z + desiredLimb

;---------------------------------------------------Catgate---------------------------------------------------

global CatGateTime     := 29540 	

;---------------------------------------------------Timer---------------------------------------------------

global SecondsElapsed := 0
global IsRunning := false

;---------------------------------------------------PixelSearch---------------------------------------------------

global gScreen := Array( Ceil(A_ScreenWidth), Ceil(A_ScreenHeight) )
global gScreenCenter := Array( Ceil(A_ScreenWidth / 2), Ceil(A_ScreenHeight / 2) )
global HalfArea := 40
global startX   := gScreenCenter[1] - HalfArea
global startY   := gScreenCenter[2] - HalfArea
global endX     := gScreenCenter[1] + HalfArea
global endY     := gScreenCenter[2] + HalfArea

;---------------------------------------------------GUI---------------------------------------------------

global g_uiTheme       := {}
ui          := new Ui(g_uiTheme)

;---------------------------------------------------Adding fonts---------------------------------------------------

g_uiTheme.insert("winOL", "594346") 
g_uiTheme.insert("alpOL", 255)      
g_uiTheme.insert("winBG", "212027") 
g_uiTheme.insert("alpBG", 510)      

g_uiTheme.insert("main", "Montserrat Medium") 
g_uiTheme.insert("mainCol", "White")         
g_uiTheme.insert("mainSZ", 10)                

g_uiTheme.insert("main1", "Montserrat Medium")  
g_uiTheme.insert("main1Col", "8D2F23")          
g_uiTheme.insert("main1SZ", 10)                                            

g_uiTheme.insert("main4", "Montserrat Medium")  
g_uiTheme.insert("main4Col", "White")          
g_uiTheme.insert("main4SZ", 10) 

g_uiTheme.insert("main5", "Montserrat Medium")  
g_uiTheme.insert("main5Col", "Green")          
g_uiTheme.insert("main5SZ", 10)  

g_uiTheme.insert("main6", "Montserrat Medium")  
g_uiTheme.insert("main6Col", "Gray")          
g_uiTheme.insert("main6SZ", 10) 

;---------------------------------------------------Setting windows position---------------------------------------------------

bPosX := Ceil(gScreen[1] * 0.029295)
bPosY := Ceil(gScreen[2] * 0.47)

TBPosX := Ceil(gScreen[1] * 0.469)
TBPosY := Ceil(gScreen[2] * 0.105)

DBPosX := Ceil(gScreen[1] * 0.469)
DBPosY := Ceil(gScreen[2] * 0.805)

;---------------------------------------------------Setting windows size---------------------------------------------------

global Body_pos                 := new Vector(bPosX, bPosY)
global Body_size                := new Vector(140, 58)

global ind_BodyHidden_pos       := new Vector(scanX1, scanY1)
global ind_BodyHidden_size      := new Vector(scanW, scanH)

global TimerBody_pos            := new Vector(TBPosX, TBPosY)
global TimerBody_size           := new Vector(120, 40)

global ind_TimerBody_pos        := new Vector(scanX1, scanY1)
global ind_TimerBody_size       := new Vector(scanW, scanH)

global DebugBody_pos            := new Vector(DBPosX, DBPosY)
global DebugBody_size           := new Vector(120, 73)

global ind_DebugBody_pos        := new Vector(scanX1, scanY1)
global ind_DebugBody_size       := new Vector(scanW, scanH)

;---------------------------------------------------Window creation---------------------------------------------------

body        := ui.new_window("body", Body_pos, Body_size, {"margin": 4, "ol": [1,1,1,1]})

;---------------------------------------------------Text creation---------------------------------------------------

body.new_text("CatGate", "Catgate :    ", "Main1", "centre xs ys xm-15 ym-2")
body.new_text("CatGateStart", "0.000", "Main4", "centre xs ys xm+25 ym-2")
body.new_text("LimbTime", "Limb Time :", "Main1", "centre xs ys xm-15 ym+15")
body.new_text("LimbTimeNumber", desiredLimb, "Main", "centre ys xs xm+32 ym+15")
body.new_text("SuspendStatus", "Suspend state", "Main1", "centre xs ys xm-13 ym+32")
body.new_text("SuspendStatusOff", "Off", "Main6", "centre xs ys xm+44 ym+32")
body.new_text("SuspendStatusOn", " ", "Main5", "centre xs ys xm+44 ym+32")
body.show()
Return
;---------------------------------------------------Funcs---------------------------------------------------

Clamp(num, min, max) 
{
    return num > max ? max : num < min ? min : num
}

Border(GuiName, CoordinateArray = "", GuiThickness = 1, GuiColor = "", GuiStatus = "") {
    global
    switch (GuiStatus) {
        case "Destroy": Loop, 4
            Gui, %GuiName%%A_Index%: Destroy
        case "Update": Loop, 4
            Gui, %GuiName%%A_Index%: Color, %GuiColor% 
    }
    if GuiStatus
        Return
    Loop, 4 {
        Gui, %GuiName%%A_Index%: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20
        Gui, %GuiName%%A_Index%: Color, %GuiColor%
        WinSet, Transparent, 255
    }
    X1 := CoordinateArray.1 - GuiThickness
    Y1 := CoordinateArray.2 - GuiThickness
    X2 := CoordinateArray.3
    Y2 := CoordinateArray.4
    W := CoordinateArray.3 - CoordinateArray.1 + (GuiThickness * 2)
    H := CoordinateArray.4 - CoordinateArray.2 + GuiThickness
    Gui, %GuiName%1: Show, x%X1% y%Y1% w%W% h%GuiThickness% NoActivate
    Gui, %GuiName%2: Show, x%X1% y%Y1% w%GuiThickness% h%H% NoActivate  
    Gui, %GuiName%3: Show, x%X1% y%Y2% w%W% h%GuiThickness% NoActivate
    Gui, %GuiName%4: Show, x%X2% y%Y1% w%GuiThickness% h%H% NoActivate
    Return
}

AimLocPinAdv(SearchArea, MouseSpeed, FindText, A_FindText, CorrectionsAmount = 0) {
        MouseSpeed := MouseSpeed < 1 ? 1 : MouseSpeed > 100 ? 100 : MouseSpeed
        PointingAccuracy := Round(Sqrt(MouseSpeed) * 0.74)
        StopAim := Array(gScreenCenter[1] - PointingAccuracy, gScreenCenter[2] - PointingAccuracy, gScreenCenter[1] + PointingAccuracy, gScreenCenter[2] + PointingAccuracy)
        SA := Array(gScreenCenter[1] - SearchArea, gScreenCenter[2] - SearchArea, gScreenCenter[1] + SearchArea, gScreenCenter[2] + SearchArea)
        ; Border("AimLocPin", SA,, "Yellow")
        Loop, {
            FindText(LocPinX, LocPinY, SA[1], SA[2], SA[3], SA[4], A_FindText, A_FindText, FindText)
            if (!LocPinX && !LocPinY) {
                ; Border("AimLocPin",,,, "Destroy")
    Return 1
            }
            moving_X := LocPinX < StopAim[1] ? Floor(((LocPinX - gScreenCenter[1]) / MouseSpeed)) : LocPinX > StopAim[3] ? Ceil(((LocPinX - gScreenCenter[1]) / MouseSpeed)) : 0
            moving_Y := LocPinY < StopAim[2] ? Floor(((LocPinY - gScreenCenter[2]) / MouseSpeed)) : LocPinY > StopAim[4] ? Ceil(((LocPinY - gScreenCenter[2]) / MouseSpeed)) : 0
            if (moving_X = 0 && moving_Y = 0)
                Break
            MoveMouse(moving_X, -moving_Y)
        }
        ; Border("AimLocPin",,, "Lime", "Update")
        if CorrectionsAmount
            Loop, %CorrectionsAmount% {
                FindText(LocPinX, LocPinY, SA[1], SA[2], SA[3], SA[4], A_FindText, A_FindText, FindText)
                moving_X := LocPinX < StopAim[1] ? Floor(((LocPinX - gScreenCenter[1]) / MouseSpeed)) : LocPinX > StopAim[3] ? Ceil(((LocPinX - gScreenCenter[1]) / MouseSpeed)) : 0
                moving_Y := LocPinY < StopAim[2] ? Floor(((LocPinY - gScreenCenter[2]) / MouseSpeed)) : LocPinY > StopAim[4] ? Ceil(((LocPinY - gScreenCenter[2]) / MouseSpeed)) : 0
                MoveMouse(moving_X, -moving_Y)
            }
        ; Border("AimLocPin",,,, "Destroy") 
        Return 0
}

MoveMouse(x,y) {
    Dllcall("SetCursorPos" , "Int", A_ScreenWidth/2, "Int", A_ScreenHeight/2)
    DllCall("mouse_event", "UInt", 0x01, "Int", x, "Int", -y, "UInt", 0, "Int", 0)
    Return
}

InsertDetectShard(startX, startY, endX, endY, color, var){
    Loop {
        PixelSearch, OutX, OutY, startX, startY, endX, endY, color, var, Fast RGB
        found := !ErrorLevel
        if !found
        {
            SendEvent {Blind}{x}
        }
    }   Until found
    return
}

TimeStamp(ByRef StampName = 0) {														
    Return DllCall("QueryPerformanceCounter", "Int64*", StampName)						
}

AimOnPin:
    AimLocPinAdv(100, 2, "|<>0xff00d2@0.84$14.00000001k0D1bwDzXzszwEy030000000000U", 0.1, 100)
return

;---------------------------------------------------Water macro---------------------------------------------------

WaterShields:
{
    Winset, AlwaysOnTop, on, Warframe
    BlockInput, on
    Gosub, AimOnPin
    ; InsertDetectShard(590, 483, 621, 512, 0xB51715, 25)
    Timestamp(Shard)
    SendEvent, {Blind}{Space Down}
    SendEvent, {Blind}{LButton Down} ; activation of arcane rise
    lSleep(65)
    SendEvent, {Blind}{Space Up}
    lSleep(30)
    SendEvent, {Blind}{w Down}
    lSleep(70)
    SendEvent, {Blind}{Shift}
    lSleep(485)
    SendEvent, {Blind}{w Up}
    lSleep(50)
    SendEvent, {Blind}{LButton Up}
    MoveMouse(-2607, -1194)
    SendEvent, {f}
    lSleep(100)
    SendEvent, {RButton down} ; activation of arcane rise
    lSleep(400)
    DebugBody        := ui.new_window("DebugBody", DebugBody_pos, DebugBody_size, {"margin": 4, "ol": [1,1,1,1]})
    DebugBody.new_text("Debug", "Debug", "Main1", "centre xs ys xm ym-1")
    DebugBody.new_text("DebugtimeMid", "Mid time :", "Main1", "centre xs ys xm-26 ym+15")
    DebugBody.new_text("DebugTimeMid", "0.000", "Main4", "centre xs ys xm+30 ym+15")
    DebugBody.new_text("DebugtimeCr", "CR time :", "Main1", "centre xs ys xm-25 ym+30")
    DebugBody.new_text("DebugTimeCR", "0.000", "Main4", "centre xs ys xm+29 ym+30")
    DebugBody.new_text("DebugtimeCL", "CL time :", "Main1", "centre xs ys xm-24 ym+45")
    DebugBody.new_text("DebugTimeCL", "0.000", "Main4", "centre xs ys xm+29 ym+45")
    ; lSleep(CRLimb, Shard) ; debug to aim on CR
    ; gosub, CrWater        ;
    Catting := Shard + (MidLimb * 10000)
    Loop{   
            ; Border("CR",[0, 397, 74, 441],,"red") ; debug
            PixelSearch,,, 0, 397, 74, 441, 0x8ff65e, 55, Fast RGB ; enemy highlight color -> Pallets -> Ifnested -> 1 column 5 row, enemy hightligh intensity = 50
            Found := !ErrorLevel
            if Found
            {
                Timestamp(CR)
                gosub, CrWater
                return
            }
            Timestamp(afterCR)
        } Lsleep(MidLimb * 10000) ;Until afterCR >= Catting
    lSleep(MidLimb, Shard)
    SendEvent {n}
    TimeStamp(Mid)                                     ; debug
    WaterDebugMid := MeasureTime(Shard, Mid)           ;
    DebugBody.edit_text("DebugTimeMid", WaterDebugMid) ; 
    MoveMouse(89, 1914)
    lSleep(20)
    SendEvent, {blind}{Shift}}
    MoveMouse(-6354, -1970)
    lsleep(CLLimb, Shard)    
    SendEvent {n}
    TimeStamp(CL)                                    ; debug
    WaterDebugCl:=MeasureTime(Shard, CL)             ; 
    DebugBody.edit_text("DebugTimeCL", WaterDebugCL) ;  
    SendEvent, {RButton up}
    Winset, AlwaysOnTop, off, Warframe
    BlockInput, off
    DebugBody.show()
    lSleep(10000)
    DebugBody.hide()
    return
    
    CrWater:
    Border("CR",,,,"Destroy") ; debug
    MoveMouse(-2070, 505)
    lsleep(CRLimb, Shard)
    SendEvent {Blind}{n}
    TimeStamp(CRT)                                   ; debug
    WaterDebugCR:=MeasureTime(Shard, CRT)            ;
    DebugBody.edit_text("DebugTimeCR", WaterDebugCR) ;     
    BlockInput, off
    lSleep(400)
    SendEvent, {Blind}{RButton up}
    Winset, AlwaysOnTop, off, Warframe
    DebugBody.show()
    lSleep(10000)
    DebugBody.hide()
    return
}

;---------------------------------------------------Catgate macro---------------------------------------------------

CatGateAndTeralyst:

    Border("PlainsGate",[931, 518, 996, 545],,"red") ; debug
	Loop
		PixelSearch, , , 931, 518, 996, 545, 0x989585, 25, Fast RGB
	Until (ErrorLevel = 0)

	SendEvent, {Insert}
	TimeStamp(CatgateStart)
	
    Border("OperatorEnergy",[1841, 1008, 1893, 1057],,"red") ; debug

	Loop
		PixelSearch, , , 1841, 1008, 1893, 1057, 0x2ce3ea, 25, Fast RGB
	Until (ErrorLevel = 0)
    
    TimerBody   := ui.new_window("TimerBody", TimerBody_pos, TimerBody_size, {"margin": 4, "ol": [1,1,1,1]})
    TimerBody.new_text("Timer", "Timer", "Main1", "centre xs ys xm-20 ym+8")
    TimerBody.new_text("Time", "00:00", "Main4", "centre xs ys xm+20 ym+8")
    ui.show()
    Gosub, StartStop

	TimeStamp(CatgateEnd)

	lSleep(200)

    Border("PlainsGate",,,,"Destroy")
    Border("OperatorEnergy",,,,"Destroy")

	SendEvent, {Insert}

    catgateTimeElapsed := Round((CatgateEnd - CatgateStart) /Frequency, 3)			
	body.edit_text("CatGateStart", catgateTimeElapsed)

	lSleep(CatGateTime, CatgateEnd)
	Gosub, LimbMacro
Return

;---------------------------------------------------Limb macro---------------------------------------------------

LimbMacro:
    Loop, 4 {
        TimeStamp(BeforePropa)														
        SendEvent, {v}
        SendEvent, {2}

        lSleep(300)																	
        
		SendEvent, {5}
		lSleep(700)																	
		SendEvent, {f}

        lSleep(betweenP_Z, BeforePropa)												

        TimeStamp(BeforeZenith)														
        SendEvent, {n}

        lSleep(100)																	
        SendEvent, {f}

	    lSleep(15300 , BeforeZenith)												
        lSleep(desiredLimbTime, BeforeZenith)										
    }

    BeforePropa := 0, BeforeZenith := 0										
Return

IncreaseLimbTiming:																	
    desiredLimb++
    desiredLimbTime++																																	
    body.edit_text("LimbTimeNumber", desiredLimb)
Return

DecreaseLimbTiming:																	
    desiredLimb--
    desiredLimbTime--
    body.edit_text("LimbTimeNumber", desiredLimb)
Return

; y::
;     Winset, AlwaysOnTop, on, Warframe
;     ttt := 0
;     avg := 0
;     Loop, 1000 {
;         DllCall("QueryPerformanceCounter", "Int64*", aaa)
;         PixelSearch,,, 0, 0, 10, 10, 0x515151, 30, Fast RGB
;         DllCall("QueryPerformanceCounter", "Int64*", bbb)
;         ttt += 1000 * ((bbb - aaa) / Frequency)
;     }
;         MsgBox, % avg := ttt / 1000
;     avg := ttt / 1000
;     Winset, AlwaysOnTop, off, Warframe
;     ; body.edit_text("T2_1", Format("{1:.3f}", avg))
; Return

UpdateTimer:
    SecondsElapsed++
    TimerBody.edit_text("Time", FormatTime(SecondsElapsed))
    If (SecondsElapsed == 422){
        Reload
    }
Return

FormatTime(TotalSeconds) {
    minutes := Floor(TotalSeconds / 60)
    seconds := Mod(TotalSeconds, 60)
    Return Format("{:02}:{:02}", minutes, seconds)
}

; Timer Start/Stop
StartStop:
if (IsRunning) {
    SetTimer, UpdateTimer, Off
    IsRunning := false
} else {
    SetTimer, UpdateTimer, 1000
    IsRunning := true
}
Return

; Reset:
;   SetTimer, UpdateTimer, Off
;   SecondsElapsed := 0
;   GuiControl,, TimerText, 00:00
;   GuiControl,, StartStop, Start
;   IsRunning := false
; Return

;---------------------------------------------------Binds---------------------------------------------------

; *h::
; 	Gosub, LimbMacro
; Return

*j::
	Gosub, CatGateAndTeralyst
Return

*c::
	Gosub, WaterShields
Return

; *v::
; 	Gosub, AimOnPin
; Return

*!WheelUp::
	Gosub, IncreaseLimbTiming
Return

*!WheelDown::
	Gosub, DecreaseLimbTiming
Return

*z:: 
    Suspend, permit
    Winset, AlwaysOnTop, off, Warframe
    BlockInput, off
    Reload
Return

*F12::
	Suspend, Toggle

	If (A_IsSuspended = 1) {
        body.edit_text("SuspendStatusOff", " ")
        body.edit_text("SuspendStatusOn", "On")
        BlockInput, off
		Return
	}

	If (A_IsSuspended = 0) {
        body.edit_text("SuspendStatusOn", " ")
        body.edit_text("SuspendStatusOff", "Off")
        BlockInput, off
		Return
	}
Return

*Delete::
    Suspend, permit
    Winset, AlwaysOnTop, off, Warframe
    BlockInput, off
ExitApp
