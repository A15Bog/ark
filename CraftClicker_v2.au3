#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\bogark.ico
#AutoIt3Wrapper_Outfile=..\BogARK_v1.7.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=A15 in the house
#AutoIt3Wrapper_Res_Description=Bog's ARK AutoRunGatherEatCraft
#AutoIt3Wrapper_Res_Fileversion=1.7.0.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2015
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
	Author: Bog (jeffbogg@gmail.com)
	Date: 06/25/2015
	Script Function: New World Crafting Clicker

	Instructions for Craft Clicker:
	ALT + F6: sets location of craft item button - leave mouse over craft item button while hitting alt + F5 - MUST BE SET BEFORE THE NEXT TWO OPTIONS WILL WORK
	F7: A prompt appears asking you how many items you want to craft, crafts input number
	F6: The item should be crafted 25 times

	Abort:
	ALT + End: If for any reason this script has issues and does not work or gets hung up, ALT+END will kill it.
#ce ----------------------------------------------------------------------------
#include <Timers.au3>
#include <Array.au3>
#include <Misc.au3>

Opt("MouseClickDragDelay", 0) ; Alters the length of the brief pause at the start and end of a mouse drag operation.
Opt("MouseCoordMode", 1) ; Sets the way coords are used in the mouse functions, 0 = relative coords to the active window
Opt("SendCapslockMode", 0)

If Not FileExists(@ScriptDir & "\_Macros.ini") Then
	IniWrite(@ScriptDir & "\_Macros.ini", "Bag", "X", "0")
	IniWrite(@ScriptDir & "\_Macros.ini", "Bag", "Y", "0")
	IniWrite(@ScriptDir & "\_Macros.ini", "Salv", "X", "0")
	IniWrite(@ScriptDir & "\_Macros.ini", "Salv", "Y", "0")
	Sleep(500)
EndIf

HotKeySet("!{F7}", "_SetBagCoords") ; Press 'Alt'+'F7' to set the location of your CRAFT ITEM BUTTON.
HotKeySet("{F8}", "_ClickCraft") ; Press F8 to click your craft item button the input number of times
HotKeySet("!{F9}", "_SetSalvCoords") ; Press 'Alt'+'F9' to set the location of your CRAFT ITEM BUTTON.
HotKeySet("{F10}", "_ClickSalv") ; Press F10 to click your salvage item button the input number of times minus 12
HotKeySet("!{END}", "Terminate") ; Terminate the script
;HotKeySet("{F7}", "handleshow")


Global $Paused
Global $S = 0
Global $BagTargetX = IniRead(@ScriptDir & "\_Macros.ini", "Bag", "X", "0")
Global $BagTargetY = IniRead(@ScriptDir & "\_Macros.ini", "Bag", "Y", "0")
Global $SalvTargetX = IniRead(@ScriptDir & "\_Macros.ini", "Salv", "X", "0")
Global $SalvTargetY = IniRead(@ScriptDir & "\_Macros.ini", "Salv", "Y", "0")
Global $user32dll = DllOpen("user32.dll") ; should be cleaned up at exit
Global $key_down_too_long = 1000 ; if key held down over a second reset it
; Global Array for timer functions corresponding to keys defined below
Global $key_timer[8] = [0, 0, 0, 0, 0, 0, 0, 0]
; Keys of interest are hotkey modifiers for ctrl, alt, win, and shift
Global Const $keys[8] = [0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0x5b, 0x5c]
;0xa0	LSHIFT
;0xa1	RSHIFT
;0xa2	LCTRL
;0xa3	RCTRL
;0xa4	LALT
;0xa5	RALT
;0x5b	LWIN
;0x5c	RWIN
Global $vkvalue = [0xa4, 0x5b, 14, 0xa0, 0xa2]
Global $handle = WinGetHandle("[CLASS:CryENGINE]")

;Func handleshow()
;MsgBox(1, "Handle", WinGetTitle($handle))
;EndFunc

Func unstick_keys($force_unstick = False)
	Local $i

	;Format of DllCall to press/release a key
	;DllCall($dll,"int","keybd_event","int",$vkvalue,"int",0,"long",0,"long",0) 		;To press a key
	;DllCall($user32dll,"int","keybd_event","int",$vkvalue,"int",0,"long",2,"long",0) 	;To release a key

	If $force_unstick Then
		For $vkvalue In $keys
			DllCall($user32dll, "int", "keybd_event", "int", $vkvalue, "int", 0, "long", 2, "long", 0) ;Release each key
		Next
	Else
		$i = 0
		For $vkvalue In $keys
			If _IsPressed($vkvalue) Then
				If $key_timer[$i] = 0 Then
					$key_timer[$i] = _Timer_Init() ; initialize a timer to watch this key
				ElseIf TimerDiff($key_timer[$i]) >= $key_down_too_long Then ; check elapsed time
					DllCall($user32dll, "int", "keybd_event", "int", $vkvalue, "int", 0, "long", 2, "long", 0) ; release the key
					$key_timer[$i] = 0 ; reset the timer
				EndIf
			EndIf
			$i = $i + 1
		Next
	EndIf
EndFunc   ;==>unstick_keys

; Idle
While 1
	Sleep(10)
WEnd

Func _SetBagCoords()
	$MousePos = MouseGetPos()
	IniWrite(@ScriptDir & "\_Macros.ini", "Bag", "X", $MousePos[0])
	IniWrite(@ScriptDir & "\_Macros.ini", "Bag", "Y", $MousePos[1])
	$BagTargetX = $MousePos[0]
	$BagTargetY = $MousePos[1]
	unstick_keys()
EndFunc   ;==>_SetBagCoords

Func _ClickCraft()
	Local $clicknum
	Local $sAnswer = InputBox("Set coodinate then...", "How Many Items Do You Want To Craft?", "100")
	$MousePos = MouseGetPos()
	Do
		MouseMove($BagTargetX, $BagTargetY, 1)
		Sleep(50)
		MouseClick("left")
		Sleep(150)
		MouseMove($BagTargetX, $BagTargetY, 1)
		Sleep(50)
		MouseClick("left")
		Sleep(150)
		MouseMove($BagTargetX, $BagTargetY, 1)
		Sleep(50)
		MouseClick("left")
		Sleep(150)
		MouseMove($BagTargetX, $BagTargetY, 1)
		Sleep(50)
		MouseClick("left")
		Sleep(150)
		MouseMove($BagTargetX, $BagTargetY, 1)
		Sleep(50)
		MouseClick("left")
		Sleep(50)
		unstick_keys()
		$clicknum = $clicknum + 1
	Until $clicknum = $sAnswer
 EndFunc   ;==>_ClickCraft

Func _SetSalvCoords()
	$MousePos1 = MouseGetPos()
	IniWrite(@ScriptDir & "\_Macros.ini", "Salv", "X", $MousePos1[0])
	IniWrite(@ScriptDir & "\_Macros.ini", "Salv", "Y", $MousePos1[1])
	$SalvTargetX = $MousePos1[0]
	$SalvTargetY = $MousePos1[1]
	unstick_keys()
 EndFunc   ;==>_SetBagCoords

Func _ClickSalv()
	Local $clicknumb
	Local $sAnswerb = InputBox("Set coodinate then...", "How Many Items Do You Want To Salvage?", "100")
	$MousePos1 = MouseGetPos()
	Do
		MouseMove($SalvTargetX, $SalvTargetY, 1)
		Sleep(250)
		MouseClick("left")
		Sleep(150)
		Send("{ENTER}")
		Sleep(50)
		$clicknumb = $clicknumb + 1
	Until $clicknumb = $sAnswerb - 9
 EndFunc   ;==>_ClickSalv

Func Terminate()
	Exit
	unstick_keys(True)
	DllClose($user32dll)
	GUIDelete()
EndFunc   ;==>Terminate
