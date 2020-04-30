#include "Constants.agc"
#include "ThemeLoader.agc"
#include "TextSettings.agc"

Global _JButtonStateInitialized As Integer = 0

Global _JButtonStateGpioEnable As Integer = 0
Global _JButtonStateGpioError As Integer = 0
Global _JButtonStateGpios As Integer[16]

Global _JButtonStateSpriteIds As Integer[]

Global _JButtonStateKeyEnable As Integer = 0
Global _JButtonStateKeyCodes As Integer[16]

Global _JButtonStateStates As Integer[16]
Global _JButtonStatePrevStates As Integer[16]
Global _JButtonStatePressed As Integer[16]
Global _JButtonStateReleased As Integer[16]

//Global _JButtonStatePressingTime As Float[16]

Function UpdateJButtonStates()
	If Not _JButtonStateInitialized
		For i = 0 To 16
			_JButtonStatePressed[i] = 0
			_JButtonStateReleased[i] = 0
			_JButtonStatePrevStates[i] = 0
		Next
		_JButtonStateGpioEnable = GetTextSettingsGpioEnable()
		_JButtonStateKeyEnable = GetTextSettingsKeyEnable()
		For i = 1 To 17
			idxToSave = 0
			If i < 17 Then idxToSave = i
			_JButtonStateKeyCodes[idxToSave] = GetTextSettingsKeyCode(i)
			If _JButtonStateGpioEnable
				_JButtonStateGpios[idxToSave] = OpenToRead("gpio:" + Str(GetTextSettingsGpio(i)))
				CheckError()
				If _JButtonStateGpios[idxToSave] = 0 Then _JButtonStateGpioError = 1
			EndIf
		Next
		_JButtonStateInitialized = 1
	EndIf
	
	// Key
	If _JButtonStateKeyEnable
		For i = 0 To 16
			_JButtonStateStates[i] = GetRawKeyState(_JButtonStateKeyCodes[i])
		Next
	EndIf
	
	// GPIO
	If Not _JButtonStateGpioError
		If _JButtonStateGpioEnable = 1
			For i = 0 To 16
				_JButtonStateStates[i] = ReadByte(_JButtonStateGpios[i])
			Next
		ElseIf _JButtonStateGpioEnable = 2
			For i = 0 To 16
				_JButtonStateStates[i] = Not ReadByte(_JButtonStateGpios[i])
			Next
		EndIf
	EndIf
	
	// State
	For i = 0 To 16
		_JButtonStatePressed[i] = 0
		_JButtonStateReleased[i] = 0
		
		If _JButtonStateStates[i] <> _JButtonStatePrevStates[i]
			_mainIdleTime = 0.0
			If _JButtonStateStates[i] = 1
				_JButtonStatePressed[i] = 1
			Else
				_JButtonStateReleased[i] = 1
			EndIf
		EndIf
		_JButtonStatePrevStates[i] = _JButtonStateStates[i]
	Next
	
	// Sprite Indicater
	If _JButtonStateSpriteIds.Length < 0
		For i = 1 To 16
			glowSprite = CreateSprite(GetThemeImage("btn_glow"))
			SetSpritePosition(glowSprite, GetJButtonX(_JButtonStateSpriteIds.Length+2), GetJButtonY(_JButtonStateSpriteIds.Length+2))
			SetSpriteSize(glowSprite, GetJButtonSize(), GetJButtonSize())
			SetSpriteDepth(glowSprite, DEPTH_BUTTON_GLOW)
			SetSpriteVisible(glowSprite, 0)
			_JButtonStateSpriteIds.Insert(glowSprite)
		Next
	EndIf
	For i = 1 To 16
		SetSpriteVisible(_JButtonStateSpriteIds[i-1], _JButtonStateStates[i])
	Next
EndFunction

Function GetJButtonPressing(iBtn As Integer)
	If iBtn >= 0 And iBtn <= 16 Then ExitFunction _JButtonStateStates[iBtn]
EndFunction 0

Function GetJButtonPressed(iBtn As Integer)
	If iBtn >= 0 And iBtn <= 16 Then ExitFunction _JButtonStatePressed[iBtn]
EndFunction 0

Function SetJButtonGlowImage()
	For i = 0 To _JButtonStateSpriteIds.Length
		SetSpriteImage(_JButtonStateSpriteIds[i], GetThemeImage("btn_glow"))
	Next
EndFunction

/*
Function GetJButtonPressingTime(iBtn As Integer)
	If iBtn >= 0 And iBtn <= 16 Then ExitFunction _JButtonStatePressingTime[iBtn]
EndFunction 0.0
*/
