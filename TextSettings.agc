#include "Constants.agc"
#include "StringUtil.agc"

Global _TextSettingsKeysEnable As Integer = 1
Global _TextSettingsKeys As Integer[17] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_Q, KEY_W, KEY_E, KEY_R, KEY_A, KEY_S, KEY_D, KEY_F, KEY_Z, KEY_X, KEY_C, KEY_V, KEY_SPACE]
Global _TextSettingsGpiosEnable As Integer = 0
Global _TextSettingsGpios As Integer[17] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global _TextSettingsSectionStarts As Float[4] = [0.0,  0.000, 0.020, 0.035, 0.150]
Global _TextSettingsSectionWeights As Float[4] = [0.0,  0.03, 0.10, 0.20, 0.50]

Function LoadTextSettings()
	If Not GetFileExists("raw:" + GetReadPath() + "settings.txt") Then ExitFunction
	fileId = OpenToRead("/settings.txt")
	CheckError()
	If fileId = 0 Then ExitFunction
	
	line As String
	While Not FileEOF(fileId)
		line = ReadLine(fileId)
		// Remove Comment (//)
		commentIndex = FindString(line, "//")
		If commentIndex > 0 Then line = Left(line, commentIndex - 1)
		// If a=b type
		If FindStringCount(line, "=") >= 1
			key$ = Lower(Trim(Left(line, FindString(line, "=") - 1)))
			value$ = Lower(Trim(Right(line, Len(line) - FindString(line, "="))))
			If Len(key$) = 3 And key$ = "key"
				_TextSettingsKeysEnable = IfInteger(Val(value$) = 1, 1, 0)
			ElseIf Len(key$) >= 4 And Left(key$, 3) = "key"
				numberStr$ = Mid(key$, 4, Len(key$)-3)
				numberVal = Val(numberStr$)
				If FindCharsCount(numberStr$, "0123456789") = Len(numberStr$) And numberVal >= 1 And numberVal <= 17
					_TextSettingsKeys[numberVal] = Val(value$)
				EndIf
			ElseIf Len(key$) = 4 And key$ = "gpio"
				If Val(value$) = 2
					_TextSettingsGpiosEnable = 2
				ElseIf Val(value$) = 1
					_TextSettingsGpiosEnable = 1
				Else
					_TextSettingsGpiosEnable = 0
				EndIf
			ElseIf Len(key$) >= 5 And Left(key$, 4) = "gpio"
				numberStr$ = Mid(key$, 5, Len(key$)-4)
				numberVal = Val(numberStr$)
				If FindCharsCount(numberStr$, "0123456789") = Len(numberStr$) And numberVal >= 1 And numberVal <= 17
					_TextSettingsGpios[numberVal] = Val(value$)
				EndIf
			Else
				Select ReplaceChars(key$, "1234", "*", 1)
					Case "section*_start":
						value = Val(value$)
						If value < 0.000 Then value = 0.000
						If value > 1.000 Then value = 1.000
						_TextSettingsSectionStarts[Val(Mid(key$, 8, 1))] = Val(value$)
					EndCase
					Case "section*_weight":
						value = Val(value$)
						If value < 0.00 Then value = 0.00
						If value > 1.00 Then value = 1.00
						_TextSettingsSectionWeights[Val(Mid(key$, 8, 1))] = Val(value$)
					EndCase
				EndSelect
			EndIf
		EndIf
	EndWhile
	CloseFile(fileId)
	
	//InvokeError(Str(GetTextSettingsSectionStarts(1)) + " " + Str(GetTextSettingsSectionStarts(2)) + " " + Str(GetTextSettingsSectionStarts(3)) + " " + Str(GetTextSettingsSectionStarts(4)) + " ")
	//InvokeError(Str(GetTextSettingsSectionWeights(1)) + " " + Str(GetTextSettingsSectionWeights(2)) + " " + Str(GetTextSettingsSectionWeights(3)) + " " + Str(GetTextSettingsSectionWeights(4)) + " ")
EndFunction

Function GetTextSettingsKeyEnable()
EndFunction _TextSettingsKeysEnable

Function GetTextSettingsGpioEnable()
EndFunction _TextSettingsGpiosEnable

Function GetTextSettingsKeyCode(btnIdx As Integer)
EndFunction _TextSettingsKeys[btnIdx]

Function GetTextSettingsGpio(idx As Integer)
EndFunction _TextSettingsGpios[idx]

Function GetTextSettingsSectionStarts(idx As Integer)
EndFunction _TextSettingsSectionStarts[idx]

Function GetTextSettingsSectionWeights(idx As Integer)
EndFunction _TextSettingsSectionWeights[idx]
