#include "Constants.agc"
#include "ErrorReporting.agc"
#include "StringUtil.agc"

// background_particle
Global _ThemeLoaderImageFiles As String[76] = ["music_bar", "btn_glow", "btn_toggle_on", "btn_toggle_off", "btn_sort_asc", "btn_sort_desc",
"btn_back", "btn_back_highlight", "btn_next", "btn_next_highlight", "btn_retry", "btn_retry_highlight","btn_bell", "btn_bell_highlight", "btn_left", "btn_left_highlight", "btn_right", "btn_right_highlight", "btn_quit", "btn_quit_highlight", "btn_settings", "btn_settings_highlight",
"musiclistscreen_back", "musiclistscreen_back_empty", "musiclistscreen_dif", "musiclistscreen_lv", "musiclistscreen_fullcombo", "musiclistscreen_score", "musiclistscreen_rating",
"musiclist_back", "musiclist_rating", "musiclist_hold", "musiclist_lv", "musiclist_spinning_disk", "musiclist_cover_default", "test_marker_back",
"gamescreen_back", "gamescreen_score", "gamescreen_dif", "gamescreen_lv", "gamescreen_newrecord",
"hold_arrow", "hold_arrow_border", "hold_arrow_glow", "hold_glow", "hold_laser", 
"starthere", "gamescreen_ready", "gamebg_go", 
"gamebg_shutter_top", "gamebg_shutter_bottom", "gamebg_shutter_back", "gamebg_shutter_back_fade1", "gamebg_shutter_back_fade2",
"gamebg_combo_zero", "gamebg_combo_num", "gamebg_combo_text",
"gamebg_fullcombo", "gamebg_fullcombo_backfade",
"gamebg_excellent", "gamebg_excellent_backfade",
"gamebg_cleared", "gamebg_cleared_backfade", "gamebg_cleared_small",
"gamebg_failed", "gamebg_failed_backfade", "gamebg_failed_small",
"gamebg_rating", "gamebg_rating_exc", "gamebg_rating_sss", "gamebg_rating_ss", "gamebg_rating_s", "gamebg_rating_a", "gamebg_rating_b", "gamebg_rating_c", "gamebg_rating_d", "gamebg_rating_e"]
Global _ThemeLoaderSoundFiles As String[25] = ["snd_left", "snd_right", "snd_bell", "snd_ok", "snd_clap", "snd_toggle_on", "snd_toggle_off",
"snd_voice_ready", "snd_voice_go", "snd_voice_result", 
"snd_voice_selectmusic", "snd_voice_basic", "snd_voice_advanced", "snd_voice_extreme", 
"snd_voice_early", "snd_voice_good", "snd_voice_perfect", "snd_voice_late", 
"snd_fullcombo", "snd_voice_fullcombo", "snd_excellent", "snd_voice_excellent", 
"snd_cleared", "snd_voice_cleared", "snd_failed", "snd_voice_failed"]
Global _ThemeLoaderMusicFiles As String[1] = ["bgm_musiclist", "bgm_result"]

Type _ThemeLoaderItems
	Name As String
	ID As Integer
	Path As String
EndType
Global _ThemeLoaderImages As _ThemeLoaderItems[]
Global _ThemeLoaderSounds As _ThemeLoaderItems[]
Global _ThemeLoaderMusic As _ThemeLoaderItems[]

Type _ThemeLoaderLayoutFloatItem
	Key As String
	Value As Float
EndType
Global _ThemeLoaderLayoutFloat As _ThemeLoaderLayoutFloatItem[]

Type ThemeColor
	Red As Integer
	Green As Integer
	Blue As Integer
EndType
Type _ThemeLoaderLayoutColorItem
	Key As String
	Value As ThemeColor
EndType
Global _ThemeLoaderLayoutColor As _ThemeLoaderLayoutColorItem[]
Global _ThemeLoaderEmptyColor As ThemeColor


Global _PerfectColorImage As Integer
Function GetPerfectColorImage()
	If _PerfectColorImage = 0
		themeCol As ThemeColor
		themeCol = GetThemeColor("effect_perfect_color")
		_PerfectColorImage = CreateImageColor(themeCol.Red, themeCol.Green, themeCol.Blue, 255)
	EndIf
EndFunction _PerfectColorImage

Global _GreatColorImage As Integer
Function GetGreatColorImage()
	If _GreatColorImage = 0
		themeCol As ThemeColor
		themeCol = GetThemeColor("effect_great_color")
		_GreatColorImage = CreateImageColor(themeCol.Red, themeCol.Green, themeCol.Blue, 255)
	EndIf
EndFunction _GreatColorImage

Global _GoodColorImage As Integer
Function GetGoodColorImage()
	If _GoodColorImage = 0
		themeCol As ThemeColor
		themeCol = GetThemeColor("effect_good_color")
		_GoodColorImage = CreateImageColor(themeCol.Red, themeCol.Green, themeCol.Blue, 255)
	EndIf
EndFunction _GoodColorImage

Global _BadColorImage As Integer
Function GetBadColorImage()
	If _BadColorImage = 0
		themeCol As ThemeColor
		themeCol = GetThemeColor("effect_bad_color")
		_BadColorImage = CreateImageColor(themeCol.Red, themeCol.Green, themeCol.Blue, 255)
	EndIf
EndFunction _BadColorImage


Function GetThemeValue(szKey As String)
	idx = _ThemeLoaderLayoutFloat.Find(szKey)
	If idx >= 0 Then ExitFunction _ThemeLoaderLayoutFloat[idx].Value
EndFunction 0.0

Function GetThemeColor(szKey As String)
	idx = _ThemeLoaderLayoutColor.Find(szKey)
	If idx >= 0 Then ExitFunction _ThemeLoaderLayoutColor[idx].Value
EndFunction _ThemeLoaderEmptyColor

Function GetThemeImage(szName As String)
	i = _ThemeLoaderImages.Find(szName)
	If i < 0 Then ExitFunction 0
	If _ThemeLoaderImages[i].ID <= 0
		If Not GetFileExists(_ThemeLoaderImages[i].Path) Then ExitFunction 0
		_ThemeLoaderImages[i].ID = LoadImageResized(_ThemeLoaderImages[i].Path, 0.5, 0.5, 0) //LoadImage(_ThemeLoaderImages[i].Path)
		halfPath$ = RemovePathExtension(_ThemeLoaderImages[i].Path) + "@half." + GetPathExtension(_ThemeLoaderImages[i].Path)
		If GetSettingsUseHalfSizeImage()
			If GetFileExists(halfPath$)
				_ThemeLoaderImages[i].ID = LoadImage(halfPath$)
			Else
				_ThemeLoaderImages[i].ID = LoadImageResized(_ThemeLoaderImages[i].Path, 0.5, 0.5, 0)
			EndIf
		Else
			If GetFileExists(_ThemeLoaderImages[i].Path)
				_ThemeLoaderImages[i].ID = LoadImage(_ThemeLoaderImages[i].Path)
			ElseIf GetFileExists(halfPath$)
				_ThemeLoaderImages[i].ID = LoadImage(halfPath$)
			Else
				_ThemeLoaderImages[i].ID = LoadImage(_ThemeLoaderImages[i].Path)
			EndIf
		EndIf
		CheckError()
	EndIf
EndFunction _ThemeLoaderImages[i].ID

Function DeleteThemeImage(szName As String)
	i = _ThemeLoaderImages.Find(szName)
	If i < 0 Then ExitFunction
	If _ThemeLoaderImages[i].ID > 0
		DeleteImage(_ThemeLoaderImages[i].ID)
		_ThemeLoaderImages[i].ID = 0
		CheckError()
	EndIf
EndFunction

Function DeleteAllThemeImage()
	For i = 0 To _ThemeLoaderImages.Length
		If GetImageExists(_ThemeLoaderImages[i].ID)
			DeleteImage(_ThemeLoaderImages[i].ID)
			_ThemeLoaderImages[i].ID = 0
			CheckError()
		EndIf
	Next
EndFunction

Function GetThemeSound(szName As String)
	i = _ThemeLoaderSounds.Find(szName)
	If i < 0 Then ExitFunction 0
	If _ThemeLoaderSounds[i].ID <= 0
		If Not GetFileExists(_ThemeLoaderSounds[i].Path) Then ExitFunction 0
		_ThemeLoaderSounds[i].ID = LoadSound(_ThemeLoaderSounds[i].Path)
		CheckError()
	EndIf
EndFunction _ThemeLoaderSounds[i].ID

Function DeleteThemeSound(szName As String)
	i = _ThemeLoaderSounds.Find(szName)
	If i < 0 Then ExitFunction
	If _ThemeLoaderSounds[i].ID > 0
		DeleteSound(_ThemeLoaderSounds[i].ID)
		_ThemeLoaderSounds[i].ID = 0
	EndIf
EndFunction

Function DeleteAllThemeSound()
	For i = 0 To _ThemeLoaderSounds.Length
		If GetSoundExists(_ThemeLoaderSounds[i].ID)
			If GetSoundsPlaying(_ThemeLoaderSounds[i].ID) Then StopSound(_ThemeLoaderSounds[i].ID)
			DeleteSound(_ThemeLoaderSounds[i].ID)
			_ThemeLoaderSounds[i].ID = 0
			CheckError()
		EndIf
	Next
EndFunction

Function GetThemeMusic(szName As String)
	i = _ThemeLoaderMusic.Find(szName)
	If i < 0 Then ExitFunction 0
	If _ThemeLoaderMusic[i].ID <= 0
		If Not GetFileExists(_ThemeLoaderMusic[i].Path) Then ExitFunction 0
		_ThemeLoaderMusic[i].ID = LoadMusic(_ThemeLoaderMusic[i].Path)
		CheckError()
	EndIf
EndFunction _ThemeLoaderMusic[i].ID

Function DeleteThemeMusic(szName As String)
	i = _ThemeLoaderMusic.Find(szName)
	If i < 0 Then ExitFunction
	If _ThemeLoaderMusic[i].ID > 0
		DeleteMusic(_ThemeLoaderMusic[i].ID)
		_ThemeLoaderMusic[i].ID = 0
	EndIf
EndFunction

Function DeleteAllThemeMusic()
	For i = 0 To _ThemeLoaderMusic.Length
		If GetMusicExists(_ThemeLoaderMusic[i].ID)
			DeleteMusic(_ThemeLoaderMusic[i].ID)
			_ThemeLoaderMusic[i].ID = 0
			CheckError()
		EndIf
	Next
EndFunction

Global _ThemeLoaderName As String = ""
Function LoadTheme(szName As String)
	szName = ReplaceString(szName, "/", "", -1)
	If szName = "" Then ExitFunction
	// Load Layout
	layoutFile = OpenToRead(THEMES_PATH + szName + "/layout.txt")
	If layoutFile = 0
		//InvokeError("Theme layout file is not existing! (" + szName + ")")
		Message("Failed to load theme.")
		End
		ExitFunction
	EndIf
	If _ThemeLoaderName <> ""  // loading again
		DeleteImage(_PerfectColorImage)
		_PerfectColorImage = 0
		DeleteImage(_GreatColorImage)
		_GreatColorImage = 0
		DeleteImage(_GoodColorImage)
		_GoodColorImage = 0
		DeleteImage(_BadColorImage)
		_BadColorImage = 0
		
		
		DeleteAllThemeImage()
		While _ThemeLoaderImages.Length >= 0
			_ThemeLoaderImages.Remove()
		EndWhile
		//DeleteAllImages()
		
		StopMusic()
		DeleteAllThemeMusic()
		While _ThemeLoaderMusic.Length >= 0
			_ThemeLoaderMusic.Remove()
		EndWhile
		
		DeleteAllThemeSound()
		While _ThemeLoaderSounds.Length >= 0
			_ThemeLoaderSounds.Remove()
		EndWhile
		
		While _ThemeLoaderLayoutColor.Length >= 0
			_ThemeLoaderLayoutColor.Remove()
		EndWhile
		While _ThemeLoaderLayoutFloat.Length >= 0
			_ThemeLoaderLayoutFloat.Remove()
		EndWhile
	EndIf
	_ThemeLoaderName = szName
	filePath As String = ""
	item As _ThemeLoaderItems
	
	line As String
	While FileEOF(layoutFile) = 0
		line = ReadLine(layoutFile)
		// Remove Comment (//)
		commentIndex = FindString(line, "//")
		If commentIndex > 0 Then line = Left(line, commentIndex - 1)
		// If a=b type
		If FindStringCount(line, "=") >= 1
			leftPart$ = Lower(Trim(Left(line, FindString(line, "=") - 1)))
			rightPart$ = Trim(Right(line, Len(line) - FindString(line, "=")))
			If CountStringTokens2(rightPart$, ",") = 3
				colorLayoutIdx = _ThemeLoaderLayoutColor.Find(leftPart$)
				If colorLayoutIdx < 0
					colorItem As _ThemeLoaderLayoutColorItem
					colorItem.Key = leftPart$
					colorItem.Value.Red = Val(GetStringToken2(rightPart$, ",", 1))
					colorItem.Value.Green = Val(GetStringToken2(rightPart$, ",", 2))
					colorItem.Value.Blue = Val(GetStringToken2(rightPart$, ",", 3))
					_ThemeLoaderLayoutColor.InsertSorted(colorItem)
				Else
					_ThemeLoaderLayoutColor[colorLayoutIdx].Value.Red= Val(GetStringToken2(rightPart$, ",", 1))
					_ThemeLoaderLayoutColor[colorLayoutIdx].Value.Green = Val(GetStringToken2(rightPart$, ",", 2))
					_ThemeLoaderLayoutColor[colorLayoutIdx].Value.Blue = Val(GetStringToken2(rightPart$, ",", 3))
				EndIf
			Else
				floatLayoutIdx = _ThemeLoaderLayoutFloat.Find(leftPart$)
				If floatLayoutIdx < 0
					floatItem As _ThemeLoaderLayoutFloatItem
					floatItem.Key = leftPart$
					floatItem.Value = ValFloat(rightPart$)
					_ThemeLoaderLayoutFloat.InsertSorted(floatItem)
				Else
					_ThemeLoaderLayoutFloat[floatLayoutIdx].Value = ValFloat(rightPart$)
				EndIf
			EndIf
		EndIf
	EndWhile
	CloseFile(layoutFile)

	
	// Load Images
	For i = 0 To _ThemeLoaderImageFiles.Length Step 1
		If _ThemeLoaderImageFiles[i] = "" Then Continue
		filePath = THEMES_PATH + szName + "/" + _ThemeLoaderImageFiles[i] + ".png"
		halfPath$ = RemovePathExtension(filePath) + "@half." + GetPathExtension(filePath)
		If GetFileExists(filePath) Or GetFileExists(halfPath$)
			item.Name = _ThemeLoaderImageFiles[i]
			item.Path = filePath
			
			If GetSettingsUseHalfSizeImage()
				If GetFileExists(halfPath$)
					item.ID = LoadImage(halfPath$)
				Else
					item.ID = LoadImageResized(filePath, 0.5, 0.5, 0)
				EndIf
			Else
				If GetFileExists(filePath)
					item.ID = LoadImage(filePath)
				ElseIf GetFileExists(halfPath$)
					item.ID = LoadImage(halfPath$)
				Else
					item.ID = LoadImage(filePath)
				EndIf
			EndIf
			
			CheckError()
			_ThemeLoaderImages.InsertSorted(item)
		Else
			//missingFilePath = filePath
			InvokeError("Some theme file is missing: " + filePath)
		EndIf
	Next i
	
	// Load Sounds
	For i = 0 To _ThemeLoaderSoundFiles.Length Step 1
		If _ThemeLoaderSoundFiles[i] = "" Then Continue
		filePath = THEMES_PATH + szName + "/" + _ThemeLoaderSoundFiles[i] + ".wav"
		If GetFileExists(filePath)
			item.Name = _ThemeLoaderSoundFiles[i]
			item.Path = filePath
			item.ID = LoadSound(filePath)
			CheckError()
			_ThemeLoaderSounds.InsertSorted(item)
		Else
			//missingFilePath = filePath
			InvokeError("Some theme file is missing: " + filePath)
		EndIf
	Next i
	
	// Load Music
	For i = 0 To _ThemeLoaderMusicFiles.Length Step 1
		If _ThemeLoaderMusicFiles[i] = "" Then Continue
		filePath = THEMES_PATH + szName + "/" + _ThemeLoaderMusicFiles[i] + ".mp3"
		If GetFileExists(filePath)
			item.Name = _ThemeLoaderMusicFiles[i]
			item.Path = filePath
			item.ID = LoadMusic(filePath)
			CheckError()
			_ThemeLoaderMusic.InsertSorted(item)
		Else
			//missingFilePath = filePath
			InvokeError("Some theme file is missing: " + filePath)
		EndIf
	Next i
	
	/*
	If missingFilePath <> ""
		Message("Failed to load theme." + Chr(10) + "Make sure theme files exist." + Chr(10) + "Theme: " + szName + Chr(10) + "Missing File: " + missingFilePath)
		End
	EndIf
	*/
EndFunction


