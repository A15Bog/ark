#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\bogark.ico
#AutoIt3Wrapper_Outfile=..\BogARK_v1.5.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=A15 in the house
#AutoIt3Wrapper_Res_Description=Bog's ARK AutoRunGatherEatCraft
#AutoIt3Wrapper_Res_Fileversion=1.5.0.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2015
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
	Author: Bog (jeffbogg@gmail.com)
	Date: 06/25/2015
	Script Function: ARK Auto-Run, Auto-Gather, Auto-Use 50 of 0-9 key, Auto-Craft

	Instructions for Auto-Run,Auto-Gather,Auto-Eat:
	TILDE KEY: toggle for autorun using w
	ALT + TILDE KEY: toggle for autogather using e
	ALT + 0-9: will hit the respective number key 50 times

	Instructions for Auto-Craft:
	ALT + F5: sets location of craft item button - leave mouse over craft item button while hitting alt + F5 - MUST BE SET BEFORE THE NEXT TWO OPTIONS WILL WORK
	F5: A prompt appears asking you how many items you want to craft, crafts input number
	F6: The item should be crafted 25 times

	Abort:
	ALT + End: If for any reason this script has issues and does not work or gets hung up, ALT+END will kill it.
#ce ----------------------------------------------------------------------------
#include <Timers.au3>
#include <Array.au3>
#include <Misc.au3>
#include <SendMessage.au3>



Opt("MouseClickDragDelay", 0) ; Alters the length of the brief pause at the start and end of a mouse drag operation.
Opt("MouseCoordMode", 1) ; Sets the way coords are used in the mouse functions, 0 = relative coords to the active window
Opt("SendCapslockMode", 0)

If Not FileExists(@ScriptDir & "\_Macros.ini") Then
	IniWrite(@ScriptDir & "\_Macros.ini", "Bag", "X", "0")
	IniWrite(@ScriptDir & "\_Macros.ini", "Bag", "Y", "0")
	Sleep(500)
EndIf

HotKeySet("{`}", "run_toggle") ; Press 'Tilde' key once to autorun, again to stop.
HotKeySet("!{`}", "gather_loop") ; Press Alt + 'Tilde' key once to auto-gather, again to stop.
HotKeySet("!{1}", "_Auto1") ; Press '1' 50 Times
HotKeySet("!{2}", "_Auto2") ; Press '1' 50 Times
HotKeySet("!{3}", "_Auto3") ; Press '1' 50 Times
HotKeySet("!{4}", "_Auto4") ; Press '1' 50 Times
HotKeySet("!{5}", "_Auto5") ; Press '1' 50 Times
HotKeySet("!{6}", "_Auto6") ; Press '1' 50 Times
HotKeySet("!{7}", "_Auto7") ; Press '1' 50 Times
HotKeySet("!{8}", "_Auto8") ; Press '1' 50 Times
HotKeySet("!{9}", "_Auto9") ; Press '1' 50 Times
HotKeySet("!{0}", "_Auto0") ; Press '1' 50 Times
HotKeySet("{F5}", "_ClickCraft") ; Press F5 to click your craft item button the input number of times
HotKeySet("{F6}", "_ClickCraft25") ; Press F6 to click your craft item button 25 times
HotKeySet("!{F5}", "_SetBagCoords") ; Press 'Alt'+'F5' to set the location of your CRAFT ITEM BUTTON.
HotKeySet("!{END}", "Terminate") ; Terminate the script
;HotKeySet("{F7}", "handleshow")


Global $Paused
Global $autorun = 0
Global $S = 0
Global $auto1 = 0
Global $auto2 = 0
Global $auto3 = 0
Global $auto4 = 0
Global $auto5 = 0
Global $auto6 = 0
Global $auto7 = 0
Global $auto8 = 0
Global $auto9 = 0
Global $auto0 = 0
Global $BagTargetX = IniRead(@ScriptDir & "\_Macros.ini", "Bag", "X", "0")
Global $BagTargetY = IniRead(@ScriptDir & "\_Macros.ini", "Bag", "Y", "0")
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
Global $handle = WinGetHandle("[TITLE:ARK: Survival Evolved; CLASS:UnrealWindow]")

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

Func run_toggle()
	Local $WM_RBUTTONDOWN = 0x0204
	Local $WM_RBUTTONUP = 0x0205
	If $autorun = 0 Then
		Sleep(100)
		_SendMessage($handle, $WM_RBUTTONDOWN)
		Sleep(100)
		$autorun = 1
		unstick_keys()
		HotKeySet("{`}")
		HotKeySet("{`}", "run_toggle")
	Else
		Sleep(100)
		_SendMessage($handle, $WM_RBUTTONUP)
		Sleep(100)
		$autorun = 0
		unstick_keys()
		HotKeySet("{`}")
		HotKeySet("{`}", "run_toggle")
	EndIf
EndFunc   ;==>run_toggle
; Idle
While 1
	Sleep(10)
WEnd

Func gather_loop()
	If $S = 1 Then
		$S = 0
	ElseIf $S = 0 Then
		$S = 1
	EndIf
	While $S
		ControlSend($handle, Default, $handle, "{e}")
		Sleep(100)
		unstick_keys()
	WEnd
EndFunc   ;==>gather_loop

Func _Auto1()
	Local $auto1
	Do
		ControlSend($handle, Default, $handle, "1")
		Sleep(50)
		unstick_keys(True)
		$auto1 = $auto1 + 1
	Until $auto1 > 49
EndFunc   ;==>_Auto1

Func _Auto2()
	Local $auto2
	Do
		ControlSend($handle, Default, $handle, "2")
		Sleep(50)
		unstick_keys(True)
		$auto2 = $auto2 + 1
	Until $auto2 > 49
EndFunc   ;==>_Auto2

Func _Auto3()
	Local $auto3
	Do
		ControlSend($handle, Default, $handle, "3")
		Sleep(50)
		unstick_keys(True)
		$auto3 = $auto3 + 1
	Until $auto3 > 49
EndFunc   ;==>_Auto3

Func _Auto4()
	Local $auto4
	Do
		ControlSend($handle, Default, $handle, "4")
		Sleep(50)
		unstick_keys(True)
		$auto4 = $auto4 + 1
	Until $auto4 > 49
EndFunc   ;==>_Auto4

Func _Auto5()
	Local $auto5
	Do
		ControlSend($handle, Default, $handle, "5")
		Sleep(50)
		unstick_keys(True)
		$auto5 = $auto5 + 1
	Until $auto5 > 49
EndFunc   ;==>_Auto5

Func _Auto6()
	Local $auto6
	Do
		ControlSend($handle, Default, $handle, "6")
		Sleep(50)
		unstick_keys(True)
		$auto6 = $auto6 + 1
	Until $auto6 > 49
EndFunc   ;==>_Auto6

Func _Auto7()
	Local $auto7
	Do
		ControlSend($handle, Default, $handle, "7")
		Sleep(50)
		unstick_keys(True)
		$auto7 = $auto7 + 1
	Until $auto7 > 49
EndFunc   ;==>_Auto7

Func _Auto8()
	Local $auto8
	Do
		ControlSend($handle, Default, $handle, "8")
		Sleep(50)
		unstick_keys(True)
		$auto8 = $auto8 + 1
	Until $auto8 > 49
EndFunc   ;==>_Auto8

Func _Auto9()
	Local $auto9
	Do
		ControlSend($handle, Default, $handle, "9")
		Sleep(50)
		unstick_keys(True)
		$auto9 = $auto9 + 1
	Until $auto9 > 49
EndFunc   ;==>_Auto9

Func _Auto0()
	Local $auto0
	Do
		ControlSend($handle, Default, $handle, "0")
		Sleep(50)
		unstick_keys(True)
		$auto0 = $auto0 + 1
	Until $auto0 > 49
EndFunc   ;==>_Auto0

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
	Local $sAnswer = InputBox("Set coodinate then...", "How Many Items Do You Want To Craft?", "20")
	$MousePos = MouseGetPos()
	Do
		MouseMove($BagTargetX, $BagTargetY, 1)
		Sleep(50)
		ControlClick($handle, "", "[CLASS:UnrealWindow; INSTANCE:1]")
		Sleep(150)
		unstick_keys()
		$clicknum = $clicknum + 1
	Until $clicknum = $sAnswer
EndFunc   ;==>_ClickCraft

Func _ClickCraft25()
	Local $clicknum1
	Do
		MouseMove($BagTargetX, $BagTargetY, 1)
		Sleep(50)
		ControlClick($handle, "", "[CLASS:UnrealWindow; INSTANCE:1]")
		Sleep(150)
		unstick_keys()
		$clicknum1 = $clicknum1 + 1
	Until $clicknum1 > 24
EndFunc   ;==>_ClickCraft25

Func Terminate()
	Exit
	unstick_keys(True)
	DllClose($user32dll)
	GUIDelete()
EndFunc   ;==>Terminate
