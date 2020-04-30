#include "Constants.agc"
#include "ErrorReporting.agc"

Global _SettingsInitialized As Integer = 0

Type _SettingsValuesType
	Theme As String
	Language As String
	Marker As String
	SortingMode As Integer
	NotesDelayOffset As Float  // -1.0 ~ 1.0
	InputTiming As Float // -30ms ~ 30ms
	//JudgementMarkerFrameNumber As Integer  // 14~17
	AutoPlay As Integer
	MusicVolume As Integer // 0~100
	SoundVolume As Integer // 0~100
	ClapVolume As Integer // 0~100
	PlayClap As Integer
	ClapTiming As Float
	UseHalfSizeTexture As Integer
	SimpleEffect As Integer
	HighlightHoldMarker As Integer
	ShowFps As Integer
	ShowAverageInputTiming As Integer
	AverageInputTimingCounts As Integer
	USTop As Float
	USLeft As Float
	USRight As Float
	LSBottom As Float
	LSLeft As Float
	LSRight As Float
	LSSpacing As Float
	LSSpacingVisible As Integer
	PerfectRange As Float
	GreatRange As Float
	GoodRange As Float
	BadRange As Float
EndType

Global _SettingsValues As _SettingsValuesType

Function GetSettingsTheme()
EndFunction _SettingsValues.Theme
Function GetSettingsLanguage()
EndFunction _SettingsValues.Language
Function GetSettingsMarker()
EndFunction _SettingsValues.Marker
Function GetSettingsSortingMode()
EndFunction _SettingsValues.SortingMode
Function GetSettingsNotesDelayOffset()
EndFunction _SettingsValues.NotesDelayOffset
Function GetSettingsInputTiming()
EndFunction _SettingsValues.InputTiming
Function GetSettingsAutoPlay()
EndFunction _SettingsValues.AutoPlay
Function GetSettingsMusicVolume()
EndFunction _SettingsValues.MusicVolume
Function GetSettingsSoundVolume()
EndFunction _SettingsValues.SoundVolume
Function GetSettingsClapVolume()
EndFunction _SettingsValues.ClapVolume
Function GetSettingsPlayClap()
EndFunction _SettingsValues.PlayClap
Function GetSettingsClapTiming()
EndFunction _SettingsValues.ClapTiming
Function GetSettingsUseHalfSizeImage()
EndFunction _SettingsValues.UseHalfSizeTexture
Function GetSettingsSimpleEffect()
EndFunction _SettingsValues.SimpleEffect
Function GetSettingsHighlightHoldMarker()
EndFunction _SettingsValues.HighlightHoldMarker
Function GetSettingsShowFps()
EndFunction _SettingsValues.ShowFps
Function GetSettingsShowAverageInputTiming()
EndFunction _SettingsValues.ShowAverageInputTiming
Function GetSettingsAverageInputTimingCounts()
EndFunction _SettingsValues.AverageInputTimingCounts
Function GetSettingsUSTop()
EndFunction _SettingsValues.USTop
Function GetSettingsUSLeft()
EndFunction _SettingsValues.USLeft
Function GetSettingsUSRight()
EndFunction _SettingsValues.USRight
Function GetSettingsLSBottom()
EndFunction _SettingsValues.LSBottom
Function GetSettingsLSLeft()
EndFunction _SettingsValues.LSLeft
Function GetSettingsLSRight()
EndFunction _SettingsValues.LSRight
Function GetSettingsLSSpacing()
EndFunction _SettingsValues.LSSpacing
Function GetSettingsLSSpacingVisible()
EndFunction _SettingsValues.LSSpacingVisible
Function GetSettingsPerfectRange()
EndFunction _SettingsValues.PerfectRange
Function GetSettingsGreatRange()
EndFunction _SettingsValues.GreatRange
Function GetSettingsGoodRange()
EndFunction _SettingsValues.GoodRange
Function GetSettingsBadRange()
EndFunction _SettingsValues.BadRange

Function SetSettingsTheme(szName As String)
	If Not GetFileExists(THEMES_PATH + szName + "/layout.txt")
		InvokeError("Failed to set theme to " + szName)
		ExitFunction 0
	EndIf
	_SettingsValues.Theme = szName
EndFunction 1
Function SetSettingsLanguage(szName As String)
	If Lower(szName) <> "auto" And Not GetFileExists(LANG_PATH + szName)
		InvokeError("Failed to set language to " + szName)
		ExitFunction 0
	EndIf
	/*If Not SetLanguage(szName)
		InvokeError("Failed to set language to " + szName)
		ExitFunction 0
	EndIf*/
	_SettingsValues.Language = szName
EndFunction 1
Function SetSettingsMarker(szName As String)
	If Not GetFileExists(MARKERS_PATH + szName + "/marker.png")
		InvokeError("Failed to set marker to " + szName)
		ExitFunction 0
	EndIf
	_SettingsValues.Marker = szName
EndFunction 1
Function SetSettingsSortingMode(iValue As Integer)
	_SettingsValues.SortingMode = iValue
EndFunction
Function SetSettingsNotesDelayOffset(fValue As Float)
	If fValue < -0.2  // -200ms
		_SettingsValues.NotesDelayOffset = -0.2
	ElseIf 0.2 < fValue  // 200ms
		_SettingsValues.NotesDelayOffset = 0.2
	Else
		_SettingsValues.NotesDelayOffset = fValue
	EndIf
EndFunction 1
Function SetSettingsInputTiming(fValue As Float)
	If fValue < -0.1  // -50ms 
		_SettingsValues.InputTiming = -0.1
	ElseIf 0.1 < fValue   // 50ms
		_SettingsValues.InputTiming = 0.1
	Else
		_SettingsValues.InputTiming = fValue
	EndIf
EndFunction 1
Function SetSettingsAutoPlay(iValue As Integer)
	If iValue = 0 
		_SettingsValues.AutoPlay = 0
	Else
		_SettingsValues.AutoPlay = 1
	EndIf
EndFunction 1
Function SetSettingsMusicVolume(iValue As Integer)
	If iValue < 0
		_SettingsValues.MusicVolume = 0
	ElseIf 100 < iValue
		_SettingsValues.MusicVolume = 100
	Else
		_SettingsValues.MusicVolume = iValue
	EndIf
EndFunction 1
Function SetSettingsSoundVolume(iValue As Integer)
	If iValue < 0
		_SettingsValues.SoundVolume = 0
	ElseIf 100 < iValue
		_SettingsValues.SoundVolume = 100
	Else
		_SettingsValues.SoundVolume = iValue
	EndIf
EndFunction 1
Function SetSettingsClapVolume(iValue As Integer)
	If iValue < 0
		_SettingsValues.ClapVolume = 0
	ElseIf 100 < iValue
		_SettingsValues.ClapVolume = 100
	Else
		_SettingsValues.ClapVolume = iValue
	EndIf
EndFunction 1
Function SetSettingsPlayClap(iValue As Integer)
	If iValue = 0 
		_SettingsValues.PlayClap = 0
	Else
		_SettingsValues.PlayClap = 1
	EndIf
EndFunction 1
Function SetSettingsClapTiming(fValue As Float)
	If fValue < -0.1  // -50ms 
		_SettingsValues.ClapTiming = -0.1
	ElseIf 0.1 < fValue   // 50ms
		_SettingsValues.ClapTiming = 0.1
	Else
		_SettingsValues.ClapTiming = fValue
	EndIf
EndFunction 1
Function SetSettingsUseHalfSizeImage(iValue As Integer)
	If iValue = 0 
		_SettingsValues.UseHalfSizeTexture = 0
	Else
		_SettingsValues.UseHalfSizeTexture = 1
	EndIf
EndFunction 1
Function SetSettingsSimpleEffect(iValue As Integer)
	If iValue = 0 
		_SettingsValues.SimpleEffect = 0
	Else
		_SettingsValues.SimpleEffect = 1
	EndIf
EndFunction 1
Function SetSettingsHighlightHoldMarker(iValue As Integer)
	If iValue = 0
		_SettingsValues.HighlightHoldMarker = 0
	Else
		_SettingsValues.HighlightHoldMarker = 1
	EndIf
EndFunction 1
Function SetSettingsShowFps(iValue As Integer)
	If iValue = 0 
		_SettingsValues.ShowFps = 0
	Else
		_SettingsValues.ShowFps = 1
	EndIf
EndFunction 1
Function SetSettingsShowAverageInputTiming(iValue As Integer)
	If iValue = 0 
		_SettingsValues.ShowAverageInputTiming = 0
	Else
		_SettingsValues.ShowAverageInputTiming = 1
	EndIf
EndFunction 1
Function SetSettingsAverageInputTimingCounts(iValue As Integer)
	If iValue < 1
		_SettingsValues.AverageInputTimingCounts = 1
	ElseIf 100 < iValue
		_SettingsValues.AverageInputTimingCounts = 100
	Else
		_SettingsValues.AverageInputTimingCounts = iValue
	EndIf
EndFunction
Function SetSettingsUSTop(fValue As Float)
	If fValue < -10
		_SettingsValues.USTop = -10
		ExitFunction 1
	EndIf
	If fValue + (RESOLUTION_WIDTH - _SettingsValues.USLeft - _SettingsValues.USRight) * 10.0 / 16.0 > RESOLUTION_HEIGHT - (_SettingsValues.LSBottom + RESOLUTION_WIDTH - _SettingsValues.LSLeft - _SettingsValues.LSRight)
		ExitFunction 0
	EndIf
	_SettingsValues.USTop = fValue
EndFunction 1
Function SetSettingsLSBottom(fValue As Float)
	If fValue < -10
		_SettingsValues.LSBottom = -10
		ExitFunction 1
	EndIf
	If _SettingsValues.USTop + (RESOLUTION_WIDTH - _SettingsValues.USLeft - _SettingsValues.USRight) * 10.0 / 16.0 > RESOLUTION_HEIGHT - (fValue + RESOLUTION_WIDTH - _SettingsValues.LSLeft - _SettingsValues.LSRight)
		ExitFunction 0
	EndIf
	_SettingsValues.LSBottom = fValue
EndFunction 1
Function SetSettingsUSLeft(fValue As Float)
	If fValue < -10
		_SettingsValues.USLeft = -10
		ExitFunction 1
	EndIf
	If _SettingsValues.USTop + (RESOLUTION_WIDTH - fValue - _SettingsValues.USRight) * 10.0 / 16.0 > RESOLUTION_HEIGHT - (_SettingsValues.LSBottom + RESOLUTION_WIDTH - _SettingsValues.LSLeft - _SettingsValues.LSRight)
		ExitFunction 0
	EndIf
	If fValue + _SettingsValues.USRight > RESOLUTION_WIDTH * 0.2
		ExitFunction 0
	EndIf
	_SettingsValues.USLeft = fValue
EndFunction 1
Function SetSettingsUSRight(fValue As Float)
	If fValue < -10
		_SettingsValues.USRight = -10
		ExitFunction 1
	EndIf
	If _SettingsValues.USTop + (RESOLUTION_WIDTH - _SettingsValues.USLeft - fValue) * 10.0 / 16.0 > RESOLUTION_HEIGHT - (_SettingsValues.LSBottom + RESOLUTION_WIDTH - _SettingsValues.LSLeft - _SettingsValues.LSRight)
		ExitFunction 0
	EndIf
	If _SettingsValues.USLeft + fValue > RESOLUTION_WIDTH * 0.2
		ExitFunction 0
	EndIf
	_SettingsValues.USRight = fValue
EndFunction 1
Function SetSettingsLSLeft(fValue As Float)
	If fValue < -10
		_SettingsValues.LSLeft = -10
		ExitFunction 1
	EndIf
	If _SettingsValues.USTop + (RESOLUTION_WIDTH - _SettingsValues.USLeft - _SettingsValues.USRight) * 10.0 / 16.0 > RESOLUTION_HEIGHT - (_SettingsValues.LSBottom + RESOLUTION_WIDTH - fValue - _SettingsValues.LSRight)
		ExitFunction 0
	EndIf
	If fValue + _SettingsValues.LSRight > RESOLUTION_WIDTH * 0.2
		ExitFunction 0
	EndIf
	If _SettingsValues.LSSpacing / ((RESOLUTION_WIDTH - fValue - _SettingsValues.LSRight - _SettingsValues.LSSpacing * 3.0) / 4.0) > 0.5
		ExitFunction 0
	EndIf
	_SettingsValues.LSLeft = fValue
EndFunction 1
Function SetSettingsLSRight(fValue As Float)
	If fValue < -10
		_SettingsValues.LSRight = -10
		ExitFunction 1
	EndIf
	If _SettingsValues.USTop + (RESOLUTION_WIDTH - _SettingsValues.USLeft - _SettingsValues.USRight) * 10.0 / 16.0 > RESOLUTION_HEIGHT - (_SettingsValues.LSBottom + RESOLUTION_WIDTH - _SettingsValues.LSLeft - fValue)
		ExitFunction 0
	EndIf
	If _SettingsValues.LSLeft + fValue > RESOLUTION_WIDTH * 0.2
		ExitFunction 0
	EndIf
	If _SettingsValues.LSSpacing / ((RESOLUTION_WIDTH - _SettingsValues.LSLeft - fValue - _SettingsValues.LSSpacing * 3.0) / 4.0) > 0.5
		ExitFunction 0
	EndIf
	_SettingsValues.LSRight = fValue
EndFunction 1
Function SetSettingsLSSpacing(fValue As Float)
	If fValue < 0
		_SettingsValues.LSSpacing = 0
		ExitFunction 1
	EndIf
	If fValue / ((RESOLUTION_WIDTH - _SettingsValues.LSLeft - _SettingsValues.LSRight - fValue * 3.0) / 4.0) > 0.5
		ExitFunction 0
	EndIf
	_SettingsValues.LSSpacing = fValue
EndFunction 1
Function SetSettingsLSSpacingVisible(iValue As Integer)
	If iValue = 0 
		_SettingsValues.LSSpacingVisible = 0
	Else
		_SettingsValues.LSSpacingVisible = 1
	EndIf
EndFunction 1
Function SetSettingsPerfectRange(fValue As Float)
	If fValue < 0.001  // 1ms
		_SettingsValues.PerfectRange = 0.001
	ElseIf _SettingsValues.GreatRange < fValue  // 500ms
		_SettingsValues.PerfectRange = _SettingsValues.GreatRange
	Else
		_SettingsValues.PerfectRange = fValue
	EndIf
EndFunction 1
Function SetSettingsGreatRange(fValue As Float)
	If fValue < _SettingsValues.PerfectRange  // 1ms
		_SettingsValues.GreatRange = _SettingsValues.PerfectRange
	ElseIf _SettingsValues.GoodRange < fValue  // 500ms
		_SettingsValues.GreatRange = _SettingsValues.GoodRange
	Else
		_SettingsValues.GreatRange = fValue
	EndIf
EndFunction 1
Function SetSettingsGoodRange(fValue As Float)
	If fValue < _SettingsValues.GreatRange  // 1ms
		_SettingsValues.GoodRange = _SettingsValues.GreatRange
	ElseIf _SettingsValues.BadRange < fValue  // 500ms
		_SettingsValues.GoodRange = _SettingsValues.BadRange
	Else
		_SettingsValues.GoodRange = fValue
	EndIf
EndFunction 1
Function SetSettingsBadRange(fValue As Float)
	If fValue < _SettingsValues.GoodRange  // 1ms
		_SettingsValues.BadRange = _SettingsValues.GoodRange
	ElseIf 0.5 < fValue  // 500ms
		_SettingsValues.BadRange = 0.5
	Else
		_SettingsValues.BadRange = fValue
	EndIf
EndFunction 1

Function _SettingsGetInitializedValues()
	initVals As _SettingsValuesType
	initVals.Theme = "Rasbeat"
	initVals.Language = "auto"
	initVals.Marker = "Shutter"
	initVals.SortingMode = 0
	initVals.NotesDelayOffset = 0.0//0.06
	initVals.InputTiming = 0.0
	initVals.AutoPlay = 0
	initVals.MusicVolume = 80
	initVals.SoundVolume = 80
	initVals.ClapVolume = 80
	initVals.PlayClap = 0
	initVals.ClapTiming = 0.0
	initVals.UseHalfSizeTexture = 1
	initVals.SimpleEffect = 0
	initVals.HighlightHoldMarker = 0
	initVals.ShowFps = 0
	initVals.ShowAverageInputTiming = 0
	initVals.AverageInputTimingCounts = 30
	initVals.USTop = 0.0
	initVals.USLeft = 0.0
	initVals.USRight = 0.0
	initVals.LSBottom = 0.0
	initVals.LSLeft = 0.0
	initVals.LSRight = 0.0
	initVals.LSSpacing = 50.0
	initVals.LSSpacingVisible = 1
	initVals.PerfectRange = 0.050
	initVals.GreatRange = 0.100
	initVals.GoodRange = 0.200
	initVals.BadRange = 0.400
EndFunction initVals

Function ReadSettingsFromFile()
	newSettings As _SettingsValuesType
	newSettings = _SettingsGetInitializedValues()
	If Not _SettingsInitialized
		_SettingsInitialized = 1
		_SettingsValues = newSettings
	EndIf
	
	file = OpenToRead("/settings.dat")
	CheckError()
	If file = 0 Then ExitFunction
	failedToRead = 0
	
	pos = GetFilePos(file)
	newSettings.Theme = ReadString2(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.Language = ReadString2(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.Marker = ReadString2(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.SortingMode = ReadInteger(file)
	If pos = GetFilePos(file) then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.NotesDelayOffset = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.InputTiming = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.AutoPlay = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.MusicVolume = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.SoundVolume = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.ClapVolume = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.PlayClap = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.ClapTiming = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.UseHalfSizeTexture = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.SimpleEffect = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.HighlightHoldMarker = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.ShowFps = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.ShowAverageInputTiming = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.AverageInputTimingCounts = ReadInteger(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.USTop = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.USLeft = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.USRight = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.LSBottom = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.LSLeft = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.LSRight = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.LSSpacing = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.LSSpacingVisible = ReadByte(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.PerfectRange = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.GreatRange = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.GoodRange = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	pos = GetFilePos(file)
	newSettings.BadRange = ReadFloat(file)
	If pos = GetFilePos(file) Then failedToRead = 1
	
	If failedToRead
		InvokeError("Failed to read settings file.")
		ExitFunction
	EndIf
	
	_SettingsValues = _SettingsGetInitializedValues()
	SetSettingsTheme(newSettings.Theme)
	SetSettingsLanguage(newSettings.Language)
	SetSettingsMarker(newSettings.Marker)
	SetSettingsSortingMode(newSettings.SortingMode)
	SetSettingsNotesDelayOffset(newSettings.NotesDelayOffset)
	SetSettingsInputTiming(newSettings.InputTiming)
	SetSettingsAutoPlay(newSettings.AutoPlay)
	SetSettingsMusicVolume(newSettings.MusicVolume)
	SetSettingsSoundVolume(newSettings.SoundVolume)
	SetSettingsClapVolume(newSettings.ClapVolume)
	SetSettingsPlayClap(newSettings.PlayClap)
	SetSettingsClapTiming(newSettings.ClapTiming)
	SetSettingsUseHalfSizeImage(newSettings.UseHalfSizeTexture)
	SetSettingsSimpleEffect(newSettings.SimpleEffect)
	SetSettingsHighlightHoldMarker(newSettings.HighlightHoldMarker)
	SetSettingsShowFps(newSettings.ShowFps)
	SetSettingsShowAverageInputTiming(newSettings.ShowAverageInputTiming)
	SetSettingsAverageInputTimingCounts(newSettings.AverageInputTimingCounts)
	_SettingsValues.USTop = newSettings.USTop
	_SettingsValues.USLeft = newSettings.USLeft
	_SettingsValues.USRight = newSettings.USRight
	_SettingsValues.LSBottom = newSettings.LSBottom
	_SettingsValues.LSLeft = newSettings.LSLeft
	_SettingsValues.LSRight = newSettings.LSRight
	_SettingsValues.LSSpacing = newSettings.LSSpacing
	_SettingsValues.LSSpacingVisible = newSettings.LSSpacingVisible
	_SettingsValues.PerfectRange = newSettings.PerfectRange
	_SettingsValues.GreatRange = newSettings.GreatRange
	_SettingsValues.GoodRange = newSettings.GoodRange
	_SettingsValues.BadRange = newSettings.BadRange
EndFunction

Function WriteSettingsToFile()
	file = OpenToWrite("raw:" + GetReadPath() + "settings.dat")
	CheckError()
	If file = 0 Then ExitFunction
	
	WriteString2(file, _SettingsValues.Theme)
	WriteString2(file, _SettingsValues.Language)
	WriteString2(file, _SettingsValues.Marker)
	WriteInteger(file, _SettingsValues.SortingMode)
	WriteFloat(file, _SettingsValues.NotesDelayOffset)
	WriteFloat(file, _SettingsValues.InputTiming)
	WriteByte(file, _SettingsValues.AutoPlay)
	WriteByte(file, _SettingsValues.MusicVolume)
	WriteByte(file, _SettingsValues.SoundVolume)
	WriteByte(file, _SettingsValues.ClapVolume)
	WriteByte(file, _SettingsValues.PlayClap)
	WriteFloat(file, _SettingsValues.ClapTiming)
	WriteByte(file, _SettingsValues.UseHalfSizeTexture)
	WriteByte(file, _SettingsValues.SimpleEffect)
	WriteByte(file, _SettingsValues.HighlightHoldMarker)
	WriteByte(file, _SettingsValues.ShowFps)
	WriteByte(file, _SettingsValues.ShowAverageInputTiming)
	WriteInteger(file, _SettingsValues.AverageInputTimingCounts)
	WriteFloat(file, _SettingsValues.USTop)
	WriteFloat(file, _SettingsValues.USLeft)
	WriteFloat(file, _SettingsValues.USRight)
	WriteFloat(file, _SettingsValues.LSBottom)
	WriteFloat(file, _SettingsValues.LSLeft)
	WriteFloat(file, _SettingsValues.LSRight)
	WriteFloat(file, _SettingsValues.LSSpacing)
	WriteByte(file, _SettingsValues.LSSpacingVisible)
	WriteFloat(file, _SettingsValues.PerfectRange)
	WriteFloat(file, _SettingsValues.GreatRange)
	WriteFloat(file, _SettingsValues.GoodRange)
	WriteFloat(file, _SettingsValues.BadRange)
	
	CloseFile(file)
EndFunction
