#include "Constants.agc"
#include "JMemoParser.agc"
#include "GridDrawing.agc"
#include "Localizing.agc"
#include "ThemeLoader.agc"
#include "ErrorReporting.agc"
#include "ScreenFading.agc"
#include "NoteTimingOffsets.agc"

// Public property
Global SceneInGameMemoFile As String = ""
Global SceneInGameAutoplay As Integer = 0
Global SceneInGameRetry As Integer = 0

// Scene
Global _SceneInGameLooping As Integer = 0
Global _SceneInGameLifeTime As Float

// State
#constant _SceneInGameStateNone (0)
#constant _SceneInGameStateError (1)
#constant _SceneInGameStatePreparing (2)
#constant _SceneInGameStatePlaying (3)
#constant _SceneInGameStateResult (4)
Global _SceneInGameState As Integer

// Memo and music
Global _SceneInGameMemo As JMemo
Global _SceneInGameMusicId As Integer

// Time sync
Global _SceneInGamePrevReportedTime As Float  // Reported by GetMusicPosition()
Global _SceneInGameMusicTime As Float
Global _SceneInGameLastTime As Float

// Memo table indexes
Global _SceneInGameMemoTableMarkerIndex As Integer
Global _SceneInGameMemoTableTimeIndex As Integer
Global _SceneInGameMemoTableTimeIndexForClap As Integer
Global _SceneInGameCompletlyJudgedTableIndex As Integer
Global _SceneIngameMemoTableBeatTimingIndex As Integer

// Error
Global _SceneInGameError As JMemoError
Global _SceneInGameErrorTextId As Integer
Global _SceneInGameErrorOkSpriteButtonId As Integer

// Preparing
Global _SceneInGamePreparingReadySpriteId As Integer
Global _SceneInGamePreparingReady As Integer
Global _SceneInGamePreparingGoSpriteId As Integer
Global _SceneInGamePreparingGo As Integer
Global _SceneInGamePreparingStartHereSpriteIds As Integer[]

// Background shutter sprite
Global _SceneInGameBackgroundShutterTopSpriteId As Integer
Global _SceneInGameBackgroundShutterBottomSpriteId As Integer
Global _SceneInGameBackgroundShutterBackSpriteId As Integer
Global _SceneInGameBackgroundShutterBackFade1SpriteId As Integer
Global _SceneInGameBackgroundShutterBackFade2SpriteId As Integer
Global _SceneInGameBackgroundShutterBackFade2Alpha As Float
Global _SceneInGameBackgroundShutterFactor As Float

// Combo sprite
Global _SceneInGameComboDigitSpriteIds As Integer[]
Global _SceneInGameComboZeroSpriteId As Integer
Global _SceneInGameComboTextSpriteId As Integer

// Upper screen sprite
Global _SceneInGameUpperScreenBackgroundSpriteId As Integer
Global _SceneInGameUpperScreenDifficultySpriteId As Integer
Global _SceneInGameUpperScreenLevelSpriteId As Integer
Global _SceneInGameUpperScreenTitleTextId As Integer
Global _SceneInGameUpperScreenArtistTextId As Integer
Global _SceneInGameUpperScreenBpmTextId As Integer
Global _SceneInGameUpperScreenNotesTextId As Integer
Global _SceneInGameUpperScreenMusicLength1TextId As Integer
Global _SceneInGameUpperScreenMusicLength2TextId As Integer
Global _SceneInGameUpperScreenScoreDigitSpriteIds As Integer[]
Global _SceneInGameUpperScreenCoverImageId As Integer
Global _SceneInGameUpperScreenCoverSpriteId As Integer
Global _SceneInGameUpperScreenMusicBarDotSpriteIds As Integer[]
Global _SceneInGameUpperScreenMusicBarBarSpriteId As Integer
Global _SceneInGameUpperScreenMusicBarStartX As Float
Global _SceneInGameUpperScreenMusicBarEndX As Float
Global _SceneInGameUpperScreenMusicBarY As Float
Global _SceneInGameCompletlyJudgedMusicBarIndex As Integer
Global _SceneInGameUpperScreenNewRecordSpriteId As Integer
Global _SceneInGameUpperScreenIsNewRecord As Integer

// Score
Global _SceneInGameScore As Integer // 0~900000
Global _SceneInGameBonusScore As Integer // 0~100000
Global _SceneInGamePerfectCount As Integer
Global _SceneInGameGreatCount As Integer
Global _SceneInGameGoodCount As Integer
Global _SceneInGameBadCount As Integer
Global _SceneInGameMissCount As Integer
Global _SceneInGameBonusCount As Integer
Global _SceneInGamePrevComboCount As Integer
Global _SceneInGameComboCount As Integer
Global _SceneInGameComboChangedTime As Float

// Result
Global _SceneInGameResultTime As Float
Global _SceneInGameResultFullComboSpriteId As Integer
Global _SceneInGameResultFullComboBackFadeSpriteId As Integer
Global _SceneInGameResultClearedBigSpriteId As Integer
Global _SceneInGameResultClearedSmallSpriteIds As Integer[]
Global _SceneInGameResultClearedBackFadeSpriteId As Integer
Global _SceneInGameResultRatingTextSpriteId As Integer
Global _SceneInGameResultRatingCharSpriteId As Integer
Global _SceneInGameResultNextSpriteButtonId As Integer
Global _SceneInGameResultRetrySpriteButtonId As Integer

// Marker
Type _SceneInGameMarker
	Time As Float
	SpriteId As Integer
	JButtonIndex As Integer
EndType
Global _SceneInGameMarkerImage As Integer
Global _SceneInGameMarkerHighlightImage As Integer
Global _SceneInGameJudgementEffectImages As Integer[4]
Global _SceneInGameMarkers As _SceneInGameMarker[]
Global _SceneInGameJudgementEffectSprites As Integer[]
Global _SceneInGameJudgementEffectPlayingTimes As Float[]

Type _SceneInGameArrow
	ButtonIndex As Integer  // 1~16
	ArrowIndex As Integer  // 1~16
	Time As Float  
	EndTime As Float
	LaserAlphaFactor As Float  // 0.0~1.0  laser and arrow border
	ButtonGlowAlphaFactor As Float  //0.0~1.0
	Angle As Float
	SinAngle As Float
	CosAngle As Float
	ArrowSizeFactor As Float  // 0.0~0.5 0.5~1.0
	ArrowSpriteId As Integer
	ArrowGlowSpriteId As Integer
	ArrowGlowAlphaFactor As Float
	ArrowBorderSpriteId As Integer
	LaserSpriteId As Integer
	ButtonGlowSpriteId As Integer
	Holding As Integer
	TableIndex As Integer
	NeedToRemove As Integer
EndType
Global _SceneInGameArrows As _SceneInGameArrow[]
Global _SceneInGameHoldArrowImageId As Integer
Global _SceneInGameHoldArrowBorderImageId As Integer
Global _SceneInGameHoldArrowGlowImageId As Integer
Global _SceneInGameHoldGlowImageId As Integer
Global _SceneInGameHoldLaserImageId As Integer

// Main loop
Function SceneInGameLoop()
	result = SceneResultContinue
	inc _SceneInGameLifeTime, GetFrameTime()
	
	If Not _SceneInGameLooping
		StartScreenFadeIn()
		ResetTimer()
		_SceneInGameLooping = 1
		_SceneInGameState = _SceneInGameStateNone
		_SceneInGameLifeTime = 0.0
				
		_SceneInGameDeleteResourcesAndInitializeVars()
		
		// Parse memo
		While _SceneInGameMemo.Table.Length >= 0
			_SceneInGameMemo.Table.Remove()
		EndWhile
		While _SceneInGameMemo.BeatTimings.Length >= 0
			_SceneInGameMemo.BeatTimings.Remove()
		EndWhile
		_SceneInGameMemo = JMemoParser_Parse(SceneInGameMemoFile, _SceneInGameError, IfFloat(SceneInGameAutoplay, -0.0333, 0.0))
		
		// Average Input Timing
		While MainAverageInputTimingValues.Length >= 0
			MainAverageInputTimingValues.Remove()
		EndWhile
		MainAverageInputTimingValuesSum = 0.0
		
		// If error
		If _SceneInGameError.Code > 0
			_SceneInGameState = _SceneInGameStateError
		// If no error
		Else
			//SetSyncRate(0, 0)
			
			// Set state
			_SceneInGameState = _SceneInGameStatePreparing
			
			// 디버그
			If _SceneInGameMemo.Sha256String <> SceneMusicListSelectedMemoSha256String
				InvokeError("Memo's hash is mismatching. You need to update music library.")
			EndIf
			
			//InvokeError("NotesCount: " + Str(_SceneInGameMemo.NotesCount))
			//InvokeError("TableLength: " + Str(_SceneInGameMemo.Table.Length))
			//InvokeError("MbarLength: " + Str(_SceneInGameMemo.MusicBar.Length))
			//InvokeError("FinalMusicBarEnd: " + Str(_SceneInGameMemo.MusicBar[119].TableIndexEnd))
			
			// Load music and init vars
			_SceneInGameMusicId = LoadMusic(MUSIC_PATH + _SceneInGameMemo.MusicFile)
			CheckError()
			If GetMusicPlaying() Then StopMusic()
			PlayMusic(_SceneInGameMusicId)
			SeekMusic(30, 0)
			StopMusic()
			CheckError()
			
			// Load marker image
			_SceneInGameMarkerImage = LoadImage(MARKERS_PATH + GetSettingsMarker() + "/marker.png")
			If GetSettingsHighlightHoldMarker() And GetFileExists(MARKERS_PATH + GetSettingsMarker() + "/highlight.png")
				_SceneInGameMarkerHighlightImage = LoadImage(MARKERS_PATH + GetSettingsMarker() + "/highlight.png")
			Else
				_SceneInGameMarkerHighlightImage = 0
			EndIf
			If Not GetSettingsSimpleEffect()
				_SceneInGameJudgementEffectImages[1] = LoadImage(MARKERS_PATH + GetSettingsMarker() + "/bad.png")
				CheckError()
				_SceneInGameJudgementEffectImages[2] = LoadImage(MARKERS_PATH + GetSettingsMarker() + "/good.png")
				CheckError()
				_SceneInGameJudgementEffectImages[3] = LoadImage(MARKERS_PATH + GetSettingsMarker() + "/great.png")
				CheckError()
				_SceneInGameJudgementEffectImages[4] = LoadImage(MARKERS_PATH + GetSettingsMarker() + "/perfect.png")
				CheckError()
			EndIf
			
			// Create StartHere
			For i = 0 To 15 Step 1
				If i > _SceneInGameMemo.NotesCount - 1 Then Exit
				If _SceneInGameMemo.Table[i].Time <> _SceneInGameMemo.Table[0].Time Then Exit
				startHereSprite = CreateSprite(GetThemeImage("starthere"))
				SetSpriteSize(startHereSprite, GetJButtonSize(), GetJButtonSize())
				SetSpritePosition(startHereSprite, GetJButtonX(_SceneInGameMemo.Table[i].Button), GetJButtonY(_SceneInGameMemo.Table[i].Button))
				SetSpriteDepth(startHereSprite, DEPTH_START_HERE)
				_SceneInGamePreparingStartHereSpriteIds.Insert(startHereSprite)
			Next i
			
			// Create Ready
			_SceneInGamePreparingReadySpriteId = CreateSprite(GetThemeImage("gamescreen_ready"))
			SetSpriteSize(_SceneInGamePreparingReadySpriteId, GetUpperScreenWidth() * 0.5, GetUpperScreenWidth() * 0.25)
			SetSpriteDepth(_SceneInGamePreparingReadySpriteId, DEPTH_SCREEN_READY)
			SetSpriteColorAlpha(_SceneInGamePreparingReadySpriteId, 0)
			_SceneInGamePreparingReady = 0
			
			// Create Go
			_SceneInGamePreparingGoSpriteId = CreateSprite(GetThemeImage("gamebg_go"))
			SetSpritePosition(_SceneInGamePreparingGoSpriteId, GetLowerScreenX(), GetLowerScreenY() + GetLowerScreenHeight() * 0.25)
			SetSpriteSize(_SceneInGamePreparingGoSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight() * 0.5)
			SetSpriteDepth(_SceneInGamePreparingGoSpriteId, DEPTH_BG_GO)
			SetSpriteColorAlpha(_SceneInGamePreparingGoSpriteId, 0)
			_SceneInGamePreparingGo = 0
			
			// Create shutter background
			//back
			_SceneInGameBackgroundShutterBackSpriteId = CreateSprite(GetThemeImage("gamebg_shutter_back"))
			SetSpriteDepth(_SceneInGameBackgroundShutterBackSpriteId, DEPTH_BG_SHUTTER_BACK)
			SetSpritePosition(_SceneInGameBackgroundShutterBackSpriteId, GetLowerScreenX(), GetLowerScreenY())
			SetSpriteSize(_SceneInGameBackgroundShutterBackSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
			SetSpriteTransparency(_SceneInGameBackgroundShutterBackSpriteId, 0)
			//back fade 1
			_SceneInGameBackgroundShutterBackFade1SpriteId = CreateSprite(GetThemeImage("gamebg_shutter_back_fade1"))
			SetSpriteColorAlpha(_SceneInGameBackgroundShutterBackFade1SpriteId, 0)
			SetSpriteDepth(_SceneInGameBackgroundShutterBackFade1SpriteId, DEPTH_BG_SHUTTER_BACK_FADE1)
			SetSpritePosition(_SceneInGameBackgroundShutterBackFade1SpriteId, GetLowerScreenX(), GetLowerScreenY())
			SetSpriteSize(_SceneInGameBackgroundShutterBackFade1SpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
			//back fade 2
			_SceneInGameBackgroundShutterBackFade2SpriteId = CreateSprite(GetThemeImage("gamebg_shutter_back_fade2"))
			SetSpriteColorAlpha(_SceneInGameBackgroundShutterBackFade2SpriteId, 0)
			SetSpriteDepth(_SceneInGameBackgroundShutterBackFade2SpriteId, DEPTH_BG_SHUTTER_BACK_FADE2)
			SetSpritePosition(_SceneInGameBackgroundShutterBackFade2SpriteId, GetLowerScreenX(), GetLowerScreenY())
			SetSpriteSize(_SceneInGameBackgroundShutterBackFade2SpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
			//top shutter
			_SceneInGameBackgroundShutterTopSpriteId = CreateSprite(GetThemeImage("gamebg_shutter_top"))
			SetSpriteDepth(_SceneInGameBackgroundShutterTopSpriteId, DEPTH_BG_SHUTTER_TOP)
			SetSpritePosition(_SceneInGameBackgroundShutterTopSpriteId, GetLowerScreenX(), GetLowerScreenY())
			SetSpriteSize(_SceneInGameBackgroundShutterTopSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
			//bottom shutter
			_SceneInGameBackgroundShutterBottomSpriteId = CreateSprite(GetThemeImage("gamebg_shutter_bottom"))
			SetSpriteDepth(_SceneInGameBackgroundShutterBottomSpriteId, DEPTH_BG_SHUTTER_BOTTOM)
			SetSpritePosition(_SceneInGameBackgroundShutterBottomSpriteId, GetLowerScreenX(), GetLowerScreenY())
			SetSpriteSize(_SceneInGameBackgroundShutterBottomSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
			
			// load hold image
			_SceneInGameHoldArrowImageId = GetThemeImage("hold_arrow")
			_SceneInGameHoldArrowBorderImageId = GetThemeImage("hold_arrow_border")
			_SceneInGameHoldArrowGlowImageId = GetThemeImage("hold_arrow_glow")
			_SceneInGameHoldGlowImageId = GetThemeImage("hold_glow")
			_SceneInGameHoldLaserImageId = GetThemeImage("hold_laser")
			
			// Create combo
			_SceneInGameComboTextSpriteId = CreateSprite(GetThemeImage("gamebg_combo_text"))
			SetSpriteSize(_SceneInGameComboTextSpriteId, GetJButtonSize(), GetJButtonSize())
			SetSpritePosition(_SceneInGameComboTextSpriteId, GetJButtonX(11), GetJButtonY(11))
			SetSpriteDepth(_SceneInGameComboTextSpriteId, DEPTH_COMBO)
			SetSpriteColorAlpha(_SceneInGameComboTextSpriteId, 0)
			comboNumImage = GetThemeImage("gamebg_combo_num")
			_SceneInGameComboDigitSpriteIds.Insert(CreateSprite(comboNumImage))
			SetSpriteSize(_SceneInGameComboDigitSpriteIds[0], GetLowerScreenWidth() * 0.22, GetLowerScreenHeight() * 0.44) 
			SetSpriteAnimation(_SceneInGameComboDigitSpriteIds[0], GetImageWidth(comboNumImage) / 5, GetImageHeight(comboNumImage) / 2, 10)
			SetSpriteDepth(_SceneInGameComboDigitSpriteIds[0], DEPTH_COMBO)
			SetSpriteColorAlpha(_SceneInGameComboDigitSpriteIds[0], 0)
			_SceneInGameComboDigitSpriteIds.Insert(CloneSprite(_SceneInGameComboDigitSpriteIds[0]))
			_SceneInGameComboDigitSpriteIds.Insert(CloneSprite(_SceneInGameComboDigitSpriteIds[0]))
			_SceneInGameComboDigitSpriteIds.Insert(CloneSprite(_SceneInGameComboDigitSpriteIds[0]))
			_SceneInGameComboZeroSpriteId = CloneSprite(_SceneInGameComboDigitSpriteIds[0])
			SetSpriteImage(_SceneInGameComboZeroSpriteId, GetThemeImage("gamebg_combo_zero"))
			SetSpriteDepth(_SceneInGameComboZeroSpriteId, DEPTH_COMBO_ZERO)
			SetSpritePosition(_SceneInGameComboZeroSpriteId, GetLowerScreenX() + (GetLowerScreenWidth() - GetSpriteWidth(_SceneInGameComboZeroSpriteId)) * 0.5, GetLowerScreenY() + GetLowerScreenHeight() * 0.5 - GetSpriteHeight(_SceneInGameComboZeroSpriteId) * 0.63)
			//SetSpriteVisible(_SceneInGameComboZeroSpriteId, 1)
			//SetSpriteColorAlpha(_SceneInGameComboZeroSpriteId, 0) 
			
			// Create upper screen background
			_SceneInGameUpperScreenBackgroundSpriteId = CreateSprite(GetThemeImage("gamescreen_back"))
			SetSpriteSize(_SceneInGameUpperScreenBackgroundSpriteId, GetUpperScreenWidth(), GetUpperScreenHeight())
			SetSpritePosition(_SceneInGameUpperScreenBackgroundSpriteId, GetUpperScreenX(), GetUpperScreenY())
			SetSpriteDepth(_SceneInGameUpperScreenBackgroundSpriteId, DEPTH_SCREEN_BACK)
			SetSpriteTransparency(_SceneInGameUpperScreenBackgroundSpriteId, 0)
			
			// Create upper screen cover image
			If _SceneInGameMemo.CoverFile <> ""
				_SceneInGameUpperScreenCoverImageId = LoadImage(MUSIC_PATH + _SceneInGameMemo.CoverFile)
				_SceneInGameUpperScreenCoverSpriteId = CreateSprite(_SceneInGameUpperScreenCoverImageId)
				SetSpriteSize(_SceneInGameUpperScreenCoverSpriteId, GetUpperScreenWidth()  * GetThemeValue("ig_cover_width"), GetUpperScreenHeight()  * GetThemeValue("ig_cover_height"))
				SetSpritePosition(_SceneInGameUpperScreenCoverSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_cover_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_cover_y"))
				SetSpriteDepth(_SceneInGameUpperScreenCoverSpriteId, DEPTH_SCREEN_COVER)
				SetSpriteTransparency(_SceneInGameUpperScreenCoverSpriteId, 0)
			EndIf
			
			// Create upper screen score
			scoreNumImage = GetThemeImage("gamescreen_score")
			_SceneInGameUpperScreenScoreDigitSpriteIds.Insert(CreateSprite(scoreNumImage))
			SetSpriteSize(_SceneInGameUpperScreenScoreDigitSpriteIds[0], GetUpperScreenWidth() * GetThemeValue("ig_score_width"), GetUpperScreenHeight() * GetThemeValue("ig_score_height")) 
			SetSpriteAnimation(_SceneInGameUpperScreenScoreDigitSpriteIds[0], GetImageWidth(scoreNumImage) / 5, GetImageHeight(scoreNumImage) / 2, 10)
			SetSpriteDepth(_SceneInGameUpperScreenScoreDigitSpriteIds[0], DEPTH_SCREEN_TEXTS)
			SetSpriteFrame(_SceneInGameUpperScreenScoreDigitSpriteIds[0], 1)
			SetSpritePosition(_SceneInGameUpperScreenScoreDigitSpriteIds[0], GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_score_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_score_y"))
			For i = 1 To 6
				spriteId = CloneSprite(_SceneInGameUpperScreenScoreDigitSpriteIds[_SceneInGameUpperScreenScoreDigitSpriteIds.Length])
				SetSpriteX(spriteId, GetSpriteX(spriteId) - GetSpriteWidth(spriteId) * (1.0 + GetThemeValue("ig_score_spacing")))
				SetSpriteVisible(spriteId, 0)
				_SceneInGameUpperScreenScoreDigitSpriteIds.Insert(spriteId)
			Next i
			
			// Create upper screen text
			_SceneInGameUpperScreenTitleTextId = CreateText(_SceneInGameMemo.Title)
			SetTextDepth(_SceneInGameUpperScreenTitleTextId, DEPTH_SCREEN_TEXTS)
			If GetLanguageBoldFont() <> 0
				SetTextFont(_SceneInGameUpperScreenTitleTextId, GetLanguageBoldFont())
			Else
				SetTextFont(_SceneInGameUpperScreenTitleTextId, GetLanguageFont())
				SetTextBold(_SceneInGameUpperScreenTitleTextId, 1)
			EndIf
			SetTextAlignment(_SceneInGameUpperScreenTitleTextId, GetThemeValue("ig_title_align"))
			color As ThemeColor
			color = GetThemeColor("ig_title_color")
			SetTextColor(_SceneInGameUpperScreenTitleTextId, color.Red, color.Green, color.Blue, 255)
			SetTextPosition(_SceneInGameUpperScreenTitleTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_title_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_title_y"))
			SetTextSize(_SceneInGameUpperScreenTitleTextId, GetUpperScreenWidth() * GetThemeValue("ig_title_size") * GetLanguageFontScale())
			SetTextLineSpacing(_SceneInGameUpperScreenTitleTextId, GetTextSize(_SceneInGameUpperScreenTitleTextId) * GetLanguageFontLineSpacing())
			SetTextMaxWidth(_SceneInGameUpperScreenTitleTextId, GetUpperScreenWidth() * GetThemeValue("ig_title_maxwidth"))
			Select GetThemeValue("ig_title_valign")
				Case 1.0:
					SetTextY(_SceneInGameUpperScreenTitleTextId, GetTextY(_SceneInGameUpperScreenTitleTextId) - GetTextTotalHeight(_SceneInGameUpperScreenTitleTextId) * 0.5)
				EndCase
				Case 2.0:
					SetTextY(_SceneInGameUpperScreenTitleTextId, GetTextY(_SceneInGameUpperScreenTitleTextId) - GetTextTotalHeight(_SceneInGameUpperScreenTitleTextId))
				EndCase
			EndSelect
			_SceneInGameUpperScreenArtistTextId = CreateText(_SceneInGameMemo.Artist)
			SetTextDepth(_SceneInGameUpperScreenArtistTextId, DEPTH_SCREEN_TEXTS)
			SetTextFont(_SceneInGameUpperScreenArtistTextId, GetLanguageFont())
			SetTextAlignment(_SceneInGameUpperScreenArtistTextId, GetThemeValue("ig_artist_align"))
			color = GetThemeColor("ig_artist_color")
			SetTextColor(_SceneInGameUpperScreenArtistTextId, color.Red, color.Green, color.Blue, 255)
			SetTextPosition(_SceneInGameUpperScreenArtistTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_artist_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_artist_y"))
			SetTextSize(_SceneInGameUpperScreenArtistTextId, GetUpperScreenWidth() * GetThemeValue("ig_artist_size") * GetLanguageFontScale())
			SetTextLineSpacing(_SceneInGameUpperScreenArtistTextId, GetTextSize(_SceneInGameUpperScreenArtistTextId) * GetLanguageFontLineSpacing())
			SetTextMaxWidth(_SceneInGameUpperScreenArtistTextId, GetUpperScreenWidth() * GetThemeValue("ig_artist_maxwidth"))
			Select GetThemeValue("ig_artist_valign")
				Case 1.0:
					SetTextY(_SceneInGameUpperScreenArtistTextId, GetTextY(_SceneInGameUpperScreenArtistTextId) - GetTextTotalHeight(_SceneInGameUpperScreenArtistTextId) * 0.5)
				EndCase
				Case 2.0:
					SetTextY(_SceneInGameUpperScreenArtistTextId, GetTextY(_SceneInGameUpperScreenArtistTextId) - GetTextTotalHeight(_SceneInGameUpperScreenArtistTextId))
				EndCase
			EndSelect
			_SceneInGameUpperScreenBpmTextId = CreateText(_SceneInGameMemo.Tempo)
			SetTextDepth(_SceneInGameUpperScreenBpmTextId, DEPTH_SCREEN_TEXTS)
			SetTextFont(_SceneInGameUpperScreenBpmTextId, GetLanguageFont())
			SetTextAlignment(_SceneInGameUpperScreenBpmTextId, GetThemeValue("ig_bpm_align"))
			color = GetThemeColor("ig_bpm_color")
			SetTextColor(_SceneInGameUpperScreenBpmTextId, color.Red, color.Green, color.Blue, 255)
			SetTextPosition(_SceneInGameUpperScreenBpmTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_bpm_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_bpm_y"))
			SetTextSize(_SceneInGameUpperScreenBpmTextId, GetUpperScreenWidth() * GetThemeValue("ig_bpm_size") * GetLanguageFontScale())
			SetTextLineSpacing(_SceneInGameUpperScreenBpmTextId, GetTextSize(_SceneInGameUpperScreenBpmTextId) * GetLanguageFontLineSpacing())
			Select GetThemeValue("ig_bpm_valign")
				Case 1.0:
					SetTextY(_SceneInGameUpperScreenBpmTextId, GetTextY(_SceneInGameUpperScreenBpmTextId) - GetTextTotalHeight(_SceneInGameUpperScreenBpmTextId) * 0.5)
				EndCase
				Case 2.0:
					SetTextY(_SceneInGameUpperScreenBpmTextId, GetTextY(_SceneInGameUpperScreenBpmTextId) - GetTextTotalHeight(_SceneInGameUpperScreenBpmTextId))
				EndCase
			EndSelect
			
			_SceneInGameUpperScreenNotesTextId = CreateText(IfString(_SceneInGameMemo.HoldsCount, Str(_SceneInGameMemo.NotesCount+_SceneInGameMemo.HoldsCount)+"("+Str(_SceneInGameMemo.HoldsCount)+")", Str(_SceneInGameMemo.NotesCount)))
			SetTextDepth(_SceneInGameUpperScreenNotesTextId, DEPTH_SCREEN_TEXTS)
			SetTextFont(_SceneInGameUpperScreenNotesTextId, GetLanguageFont())
			SetTextAlignment(_SceneInGameUpperScreenNotesTextId, GetThemeValue("ig_notes_align"))
			color = GetThemeColor("ig_notes_color")
			SetTextColor(_SceneInGameUpperScreenNotesTextId, color.Red, color.Green, color.Blue, 255)
			SetTextPosition(_SceneInGameUpperScreenNotesTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_notes_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_notes_y"))
			SetTextSize(_SceneInGameUpperScreenNotesTextId, GetUpperScreenWidth() * GetThemeValue("ig_notes_size") * GetLanguageFontScale())
			SetTextLineSpacing(_SceneInGameUpperScreenNotesTextId, GetTextSize(_SceneInGameUpperScreenNotesTextId) * GetLanguageFontLineSpacing())
			Select GetThemeValue("ig_notes_valign")
				Case 1.0:
					SetTextY(_SceneInGameUpperScreenNotesTextId, GetTextY(_SceneInGameUpperScreenNotesTextId) - GetTextTotalHeight(_SceneInGameUpperScreenNotesTextId) * 0.5)
				EndCase
				Case 2.0:
					SetTextY(_SceneInGameUpperScreenNotesTextId, GetTextY(_SceneInGameUpperScreenNotesTextId) - GetTextTotalHeight(_SceneInGameUpperScreenNotesTextId))
				EndCase
			EndSelect
			
			_SceneInGameUpperScreenMusicLength1TextId = CreateText("0:00")
			SetTextDepth(_SceneInGameUpperScreenMusicLength1TextId, DEPTH_SCREEN_TEXTS)
			SetTextFont(_SceneInGameUpperScreenMusicLength1TextId, GetLanguageFont())
			SetTextAlignment(_SceneInGameUpperScreenMusicLength1TextId, GetThemeValue("ig_musicplayhead1_align"))
			color = GetThemeColor("ig_musicplayhead1_color")
			SetTextColor(_SceneInGameUpperScreenMusicLength1TextId, color.Red, color.Green, color.Blue, 255)
			SetTextPosition(_SceneInGameUpperScreenMusicLength1TextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_musicplayhead1_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_musicplayhead1_y"))
			SetTextSize(_SceneInGameUpperScreenMusicLength1TextId, GetUpperScreenWidth() * GetThemeValue("ig_musicplayhead1_size") * GetLanguageFontScale())
			SetTextLineSpacing(_SceneInGameUpperScreenMusicLength1TextId, GetTextSize(_SceneInGameUpperScreenMusicLength1TextId) * GetLanguageFontLineSpacing())
			Select GetThemeValue("ig_musicplayhead1_valign")
				Case 1.0:
					SetTextY(_SceneInGameUpperScreenMusicLength1TextId, GetTextY(_SceneInGameUpperScreenMusicLength1TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength1TextId) * 0.5)
				EndCase
				Case 2.0:
					SetTextY(_SceneInGameUpperScreenMusicLength1TextId, GetTextY(_SceneInGameUpperScreenMusicLength1TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength1TextId))
				EndCase
			EndSelect
			musicLength = Round(_SceneInGameMemo.Length)
			musicLengthColon$ = ":"
			If Mod(musicLength, 60) < 10 Then musicLengthColon$ = ":0"
			_SceneInGameUpperScreenMusicLength2TextId = CreateText("-" + Str(musicLength / 60) + musicLengthColon$ + Str(Mod(musicLength, 60)))
			SetTextDepth(_SceneInGameUpperScreenMusicLength2TextId, DEPTH_SCREEN_TEXTS)
			SetTextFont(_SceneInGameUpperScreenMusicLength2TextId, GetLanguageFont())
			SetTextAlignment(_SceneInGameUpperScreenMusicLength2TextId, GetThemeValue("ig_musicplayhead2_align"))
			color = GetThemeColor("ig_musicplayhead2_color")
			SetTextColor(_SceneInGameUpperScreenMusicLength2TextId, color.Red, color.Green, color.Blue, 255)
			SetTextPosition(_SceneInGameUpperScreenMusicLength2TextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_musicplayhead2_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_musicplayhead2_y"))
			SetTextSize(_SceneInGameUpperScreenMusicLength2TextId, GetUpperScreenWidth() * GetThemeValue("ig_musicplayhead2_size") * GetLanguageFontScale())
			SetTextLineSpacing(_SceneInGameUpperScreenMusicLength2TextId, GetTextSize(_SceneInGameUpperScreenMusicLength2TextId) * GetLanguageFontLineSpacing())
			Select GetThemeValue("ig_musicplayhead2_valign")
				Case 1.0:
					SetTextY(_SceneInGameUpperScreenMusicLength2TextId, GetTextY(_SceneInGameUpperScreenMusicLength2TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength2TextId) * 0.5)
				EndCase
				Case 2.0:
					SetTextY(_SceneInGameUpperScreenMusicLength2TextId, GetTextY(_SceneInGameUpperScreenMusicLength2TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength2TextId))
				EndCase
			EndSelect
			
			// Create upper screen difficulty and level and newrecord
			_SceneInGameUpperScreenDifficultySpriteId = CreateSprite(GetThemeImage("gamescreen_dif"))
			SetSpritePosition(_SceneInGameUpperScreenDifficultySpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_dif_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_dif_y"))
			SetSpriteSize(_SceneInGameUpperScreenDifficultySpriteId, GetUpperScreenWidth() * GetThemeValue("ig_dif_width"), GetUpperScreenHeight() * GetThemeValue("ig_dif_height"))
			SetSpriteAnimation(_SceneInGameUpperScreenDifficultySpriteId, GetImageWidth(GetThemeImage("gamescreen_dif")), GetImageHeight(GetThemeImage("gamescreen_dif")) / 3, 3)
			SetSpriteDepth(_SceneInGameUpperScreenDifficultySpriteId, DEPTH_SCREEN_TEXTS)
			Select _SceneInGameMemo.Difficulty
				Case JMemoDifficultyBasic:
					SetSpriteFrame(_SceneInGameUpperScreenDifficultySpriteId, 1)
				EndCase
				Case JMemoDifficultyAdvanced:
					SetSpriteFrame(_SceneInGameUpperScreenDifficultySpriteId, 2)
				EndCase
				Case JMemoDifficultyExtreme:
					SetSpriteFrame(_SceneInGameUpperScreenDifficultySpriteId, 3)
				EndCase
				Case Default:
					SetSpriteVisible(_SceneInGameUpperScreenDifficultySpriteId, 0)
				EndCase
			EndSelect
			_SceneInGameUpperScreenLevelSpriteId = CreateSprite(GetThemeImage("gamescreen_lv"))
			SetSpritePosition(_SceneInGameUpperScreenLevelSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_lv_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_lv_y"))
			SetSpriteSize(_SceneInGameUpperScreenLevelSpriteId, GetUpperScreenWidth() * GetThemeValue("ig_lv_width"), GetUpperScreenHeight() * GetThemeValue("ig_lv_height"))
			SetSpriteDepth(_SceneInGameUpperScreenLevelSpriteId, DEPTH_SCREEN_TEXTS)
			SetSpriteAnimation(_SceneInGameUpperScreenLevelSpriteId, GetImageWidth(GetThemeImage("gamescreen_lv")) / 5, GetImageHeight(GetThemeImage("gamescreen_lv")) / 2, 10)
			//SetSpriteFrame(_SceneInGameUpperScreenLevelSpriteId, 16)
			If 1 <= _SceneInGameMemo.Level And _SceneInGameMemo.Level <= 10
				SetSpriteFrame(_SceneInGameUpperScreenLevelSpriteId, _SceneInGameMemo.Level)
			Else
				SetSpriteVisible(_SceneInGameUpperScreenLevelSpriteId, 0)
			EndIf
			_SceneInGameUpperScreenNewRecordSpriteId = CreateSprite(GetThemeImage("gamescreen_newrecord"))
			SetSpritePosition(_SceneInGameUpperScreenNewRecordSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_newrecord_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_newrecord_y"))
			SetSpriteSize(_SceneInGameUpperScreenNewRecordSpriteId, GetUpperScreenWidth() * GetThemeValue("ig_newrecord_width"), GetUpperScreenHeight() * GetThemeValue("ig_newrecord_height"))
			SetSpriteDepth(_SceneInGameUpperScreenNewRecordSpriteId, DEPTH_SCREEN_TEXTS)
			SetSpriteColorAlpha(_SceneInGameUpperScreenNewRecordSpriteId, 0)
			
			// Create upper screen music bar
			musicBarImage = GetThemeImage("music_bar")
			musicBarDotWidth# = GetUpperScreenWidth() * GetThemeValue("ig_mbar_width") / 120.0//0.00625
			_SceneInGameUpperScreenMusicBarStartX = GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("ig_mbar_x")
			_SceneInGameUpperScreenMusicBarEndX = _SceneInGameUpperScreenMusicBarStartX + GetUpperScreenWidth() * GetThemeValue("ig_mbar_width") //musicBarDotWidth# * 120.0
			_SceneInGameUpperScreenMusicBarY = GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_mbar_y")
			For i = 0 To 119
				musicBarDot = CreateSprite(musicBarImage)
				SetSpriteAnimation(musicBarDot, GetImageWidth(musicBarImage) * 0.125, GetImageHeight(musicBarImage), 8)
				SetSpriteFrame(musicBarDot, MaxI(1, _SceneInGameMemo.MusicBar[i].Color + 1))
				
				If 0 < _SceneInGameMemo.MusicBar[i].Level And _SceneInGameMemo.MusicBar[i].Level <= 8
					SetSpriteSize(musicBarDot, musicBarDotWidth#, musicBarDotWidth# * _SceneInGameMemo.MusicBar[i].Level)
					SetSpriteX(musicBarDot, _SceneInGameUpperScreenMusicBarStartX + GetSpriteWidth(musicBarDot) * i)
					SetSpriteY(musicBarDot, _SceneInGameUpperScreenMusicBarY + GetSpriteWidth(musicBarDot) * (8 - _SceneInGameMemo.MusicBar[i].Level))
					SetSpriteUVScale(musicBarDot, 1.0, 8.0 / _SceneInGameMemo.MusicBar[i].Level)
					SetSpriteUVOffset(musicBarDot, 0.0, (8 - _SceneInGameMemo.MusicBar[i].Level) * 0.125)
					SetSpriteDepth(musicBarDot, DEPTH_SCREEN_MUSIC_BAR_DOT)
				Else
					SetSpriteVisible(musicBarDot, 0)
				EndIf
				_SceneInGameUpperScreenMusicBarDotSpriteIds.Insert(musicBarDot)
			Next
			
			_SceneInGameUpperScreenMusicBarBarSpriteId = CreateSprite(musicBarImage)
			SetSpriteAnimation(_SceneInGameUpperScreenMusicBarBarSpriteId, GetImageWidth(musicBarImage) * 0.5, GetImageHeight(musicBarImage), 2)
			SetSpriteFrame(_SceneInGameUpperScreenMusicBarBarSpriteId, 2)
			SetSpriteSize(_SceneInGameUpperScreenMusicBarBarSpriteId, musicBarDotWidth# * 4.0 * GetThemeValue("ig_mbar_scale"), musicBarDotWidth# * 8.0 * GetThemeValue("ig_mbar_scale"))
			SetSpriteX(_SceneInGameUpperScreenMusicBarBarSpriteId, _SceneInGameUpperScreenMusicBarStartX - GetSpriteWidth(_SceneInGameUpperScreenMusicBarBarSpriteId) * 0.5)
			SetSpriteY(_SceneInGameUpperScreenMusicBarBarSpriteId, _SceneInGameUpperScreenMusicBarY + GetSpriteWidth(_SceneInGameUpperScreenMusicBarDotSpriteIds[0])*4.0 - GetSpriteHeight(_SceneInGameUpperScreenMusicBarBarSpriteId) * 0.5)
			SetSpriteDepth(_SceneInGameUpperScreenMusicBarBarSpriteId, DEPTH_SCREEN_MUSIC_BAR_BAR)
		EndIf
	EndIf
	
	Select _SceneInGameState
		Case _SceneInGameStateError:
			If _SceneInGameErrorTextId = 0
				_SceneInGameErrorTextId = CreateText(ReplaceString(GetLocalizedString("LIBRARY_ERROR_N_CODE_C"), "%c", Str(_SceneInGameError.Code), 1) + Chr(10) + GetLocalizedString(_SceneInGameError.Message))
				SetTextColor(_SceneInGameErrorTextId, 255, 0, 255, 255)
				SetTextFont(_SceneInGameErrorTextId, GetLanguageFont())
				SetTextSize(_SceneInGameErrorTextId, GetUpperScreenWidth() * 0.05 * GetLanguageFontScale())
				SetTextLineSpacing(_SceneInGameErrorTextId, GetTextSize(_SceneInGameErrorTextId) * GetLanguageFontLineSpacing())
				SetTextAlignment(_SceneInGameErrorTextId, 1)
				SetTextPosition(_SceneInGameErrorTextId, GetUpperScreenX() + GetUpperScreenWidth() * 0.5, GetUpperScreenY() + GetUpperScreenHeight() * 0.5)
				SetTextMaxWidth(_SceneInGameErrorTextId, GetUpperScreenWidth() * 0.7)
				_SceneInGameErrorOkSpriteButtonId = CreateSpriteButton(16, SpriteButtonTypeBack)
			EndIf
			
			If GetSpriteButtonPressed(_SceneInGameErrorOkSpriteButtonId) Then DismissSpriteButton(_SceneInGameErrorOkSpriteButtonId, 1)
			If GetSpriteButtonDismissed(_SceneInGameErrorOkSpriteButtonId)
				DeleteText(_SceneInGameErrorTextId)
				DeleteSpriteButton(_SceneInGameErrorOkSpriteButtonId)
				result = SceneResultEnd
			EndIf
		EndCase
		Case _SceneInGameStatePreparing:
			// Process Ready
			If _SceneInGameLifeTime >= INGAME_PREPARING_READY_START
				If Not _SceneInGamePreparingReady Then PlaySound(GetThemeSound("snd_voice_ready"))
				_SceneInGamePreparingReady = 1
				readyProgress# = (_SceneInGameLifeTime - INGAME_PREPARING_READY_START) / (INGAME_PREPARING_READY_END - INGAME_PREPARING_READY_START)
				If _SceneInGameLifeTime < INGAME_PREPARING_READY_END
					screenCenterX# = GetUpperScreenX() + GetUpperScreenWidth() / 2.0
					readyWidth# = GetSpriteWidth(_SceneInGamePreparingReadySpriteId)
					readyHeight# = GetSpriteHeight(_SceneInGamePreparingReadySpriteId)
					readyY# = GetUpperScreenY() - readyHeight# + GetUpperScreenHeight()
					If readyProgress# <= 0.3
						readyY# = GetUpperScreenY() - readyHeight# + Sin(readyProgress# / 0.3 * 90.0) * GetUpperScreenHeight()
					ElseIf readyProgress# <= 0.5
						
					Else
						SetSpriteUVOffset(_SceneInGamePreparingReadySpriteId, 0.0, -(1.0 - Cos(((readyProgress# - 0.5) / 0.5) * 90.0)))
					EndIf
					SetSpriteColorAlpha(_SceneInGamePreparingReadySpriteId, 255)
					SetSpritePosition(_SceneInGamePreparingReadySpriteId, screenCenterX# - readyWidth# / 2.0, readyY#)
				Else
					If _SceneInGamePreparingReadySpriteId > 0
						DeleteSprite(_SceneInGamePreparingReadySpriteId)
						_SceneInGamePreparingReadySpriteId = 0
						DeleteThemeImage("gamescreen_ready")
					EndIf
				EndIf
			EndIf
			
			// Process Go
			If _SceneInGameLifeTime >= INGAME_PREPARING_GO_START
				If Not _SceneInGamePreparingGo Then PlaySound(GetThemeSound("snd_voice_go"))
				_SceneInGamePreparingGo = 1
				goProgress# = (_SceneInGameLifeTime - INGAME_PREPARING_GO_START) / (INGAME_PREPARING_GO_END - INGAME_PREPARING_GO_START)
				If _SceneInGameLifeTime < INGAME_PREPARING_GO_END
					goAlpha# = 255.0
					goScale# = 1.0
					goX# = GetLowerScreenX()
					goY# = GetLowerScreenY() + GetLowerScreenHeight() * 0.25
					If goProgress# <= 0.3
						goAlpha# = 255.0 * (goProgress# / 0.3)
						goScale# = 1.1 - 0.1 * (goProgress# / 0.3)
						goX# = GetLowerScreenX() + (1.0 - goScale#) * GetLowerScreenWidth() * 0.5
						goY# = GetLowerScreenY() + (2.0 - goScale#) * GetLowerScreenWidth() * 0.25
					ElseIf goProgress# <= 0.6
						
					Else
						goAlpha# = 255.0 * (1.0 - (goProgress# - 0.6)/ 0.4)
						goScale# = 1.0 - 0.1 * ((goProgress# - 0.6) / 0.4)
						goX# = GetLowerScreenX() + (1.0 - goScale#) * GetLowerScreenWidth() * 0.5
						goY# = GetLowerScreenY() + (2.0 - goScale#) * GetLowerScreenWidth() * 0.25
					EndIf
					SetSpriteColorAlpha(_SceneInGamePreparingGoSpriteId, goAlpha#)
					SetSpriteScale(_SceneInGamePreparingGoSpriteId, goScale#, goScale#)
					SetSpritePosition(_SceneInGamePreparingGoSpriteId, goX#, goY#)
				Else
					If _SceneInGamePreparingGoSpriteId > 0
						DeleteSprite(_SceneInGamePreparingGoSpriteId)
						_SceneInGamePreparingGoSpriteId = 0
						DeleteThemeImage("gamebg_go")
					EndIf
				EndIf
			EndIf
			
			// If lifetime reaching to end time
			If _SceneInGameLifeTime >= INGAME_PREPARING_END
				// initialize music timer
				_SceneInGameMusicTime = _SceneInGameMemo.Table[0].Time - INGAME_WATING_BEFORE_MUSIC_START
				
				// change state
				_SceneInGameState = _SceneInGameStatePlaying
			EndIf
		EndCase
		Case _SceneInGameStatePlaying:
			
			
			/* Update background shutter */
			
			// Get beat bounce factor
			beatBounceFactor As Float
			If _SceneIngameMemoTableBeatTimingIndex <= _SceneInGameMemo.BeatTimings.Length
				While _SceneInGameMemo.BeatTimings[_SceneIngameMemoTableBeatTimingIndex] <= _SceneInGameMusicTime - INGAME_BEATBOUNCE_OFFSET
					inc _SceneIngameMemoTableBeatTimingIndex
					If _SceneIngameMemoTableBeatTimingIndex > _SceneInGameMemo.BeatTimings.Length Then Exit
				EndWhile
				If _SceneIngameMemoTableBeatTimingIndex >= 1
					elapsed# = _SceneInGameMusicTime - INGAME_BEATBOUNCE_OFFSET - _SceneInGameMemo.BeatTimings[_SceneIngameMemoTableBeatTimingIndex-1]
					//bounceTime# = MinF((60.0 / _SceneInGameMemo.Tempo) * 0.5, 0.2)
					//bounceTime# = (_SceneInGameMemo.BeatTimings[1] - _SceneInGameMemo.BeatTimings[0]) * 1.0
					bounceTime# = 0.0
					If _SceneIngameMemoTableBeatTimingIndex > _SceneInGameMemo.BeatTimings.Length
						bounceTime# = (_SceneInGameMemo.BeatTimings[_SceneIngameMemoTableBeatTimingIndex-1] - _SceneInGameMemo.BeatTimings[_SceneIngameMemoTableBeatTimingIndex-2]) * 1.0
					Else
						bounceTime# = (_SceneInGameMemo.BeatTimings[_SceneIngameMemoTableBeatTimingIndex] - _SceneInGameMemo.BeatTimings[_SceneIngameMemoTableBeatTimingIndex-1]) * 1.0
					EndIf
					If elapsed# <= INGAME_BEATBOUNCE_UP_TIME
						beatBounceFactor = elapsed# / INGAME_BEATBOUNCE_UP_TIME
					ElseIf elapsed# <= bounceTime#
						//beatBounceFactor = (-Cos(elapsed# / bounceTime#* 360.0) + 1.0) * 0.5
						beatBounceFactor = Cos(90.0 * (elapsed# - INGAME_BEATBOUNCE_UP_TIME) / (bounceTime# - INGAME_BEATBOUNCE_UP_TIME))
					Else
						beatBounceFactor = 0.0
					EndIf
				Else
					beatBounceFactor = 0.0
				EndIf
			EndIf
			
			shutterFactor# = _SceneInGameBonusScore / 100000.0  // close to open
			
			// dampig shutter factor
			If shutterFactor# > _SceneInGameBackgroundShutterFactor
				_SceneInGameBackgroundShutterFactor = MinF(_SceneInGameBackgroundShutterFactor + GetFrameTime()*0.025, shutterFactor#)
			ElseIf shutterFactor# < _SceneInGameBackgroundShutterFactor
				_SceneInGameBackgroundShutterFactor = MaxF(_SceneInGameBackgroundShutterFactor - GetFrameTime()*0.025, shutterFactor#)
			EndIf
			
			// Shutter uv moving
			_SceneInGameShutterUVChanging(_SceneInGameBackgroundShutterFactor, beatBounceFactor)
			
			// Back Shutter fade 1 alpha
			If shutterFactor# >= 0.5
				SetSpriteColorAlpha(_SceneInGameBackgroundShutterBackFade1SpriteId, ((shutterFactor#-0.5)*2.0)^3 * 255)
				//SetParticlesFrequency(_SceneInGameBackgroundShutterParticlesId, ((shutterFactor#-0.5)*2.0)^4 * 6.0)
			Else
				SetSpriteColorAlpha(_SceneInGameBackgroundShutterBackFade1SpriteId, 0.0)
				//SetParticlesFrequency(_SceneInGameBackgroundShutterParticlesId, 0.0)
			EndIf
			
			// Back Shutter fade 2 alpha
			If shutterFactor# = 1.0
				inc _SceneInGameBackgroundShutterBackFade2Alpha, GetFrameTime() * 500.0
				If _SceneInGameBackgroundShutterBackFade2Alpha > 255.0 Then _SceneInGameBackgroundShutterBackFade2Alpha = 255.0
				SetSpriteColorAlpha(_SceneInGameBackgroundShutterBackFade2SpriteId, _SceneInGameBackgroundShutterBackFade2Alpha)
			Else
				dec _SceneInGameBackgroundShutterBackFade2Alpha, GetFrameTime() * 255.0
				If _SceneInGameBackgroundShutterBackFade2Alpha < 0.0 Then _SceneInGameBackgroundShutterBackFade2Alpha = 0.0
				SetSpriteColorAlpha(_SceneInGameBackgroundShutterBackFade2SpriteId, _SceneInGameBackgroundShutterBackFade2Alpha)
			EndIf
			
			/* Update Score */
			
			totalNotes = _SceneInGameMemo.NotesCount + _SceneInGameMemo.HoldsCount
			_SceneInGameScore = _SceneInGamePerfectCount * 900000 / totalNotes
			inc _SceneInGameScore, _SceneInGameGreatCount * 630000 / totalNotes
			inc _SceneInGameScore, _SceneInGameGoodCount * 360000 / totalNotes
			inc _SceneInGameScore, _SceneInGameBadCount * 90000 / totalNotes
			If _SceneInGameBonusCount < 0 Then _SceneInGameBonusCount = 0
			If _SceneInGameBonusCount > totalNotes Then _SceneInGameBonusCount = totalNotes 
			_SceneInGameBonusScore = _SceneInGameBonusCount * 100000 / totalNotes
			_SceneInGameUpdateScoreSprites(_SceneInGameScore)
			
			
			/* Update Combo */
			
			comboChangingElapsed# = Timer() - _SceneInGameComboChangedTime
			If _SceneInGameComboCount >= 5 And _SceneInGameComboCount < 10000
				comboAlpha = GetSpriteColorAlpha(_SceneInGameComboTextSpriteId) + MaxI(1, GetFrameTime() * 255 / 0.25)
				comboCopy = _SceneInGameComboCount
				comboDigitCount = 0
				digitWidth# = GetSpriteWidth(_SceneInGameComboDigitSpriteIds[0])
				digitHeight# = GetSpriteHeight(_SceneInGameComboDigitSpriteIds[0])
				centerX# = GetLowerScreenX() + (GetLowerScreenWidth() - digitWidth#) / 2.0
				centerY# = GetLowerScreenY() + (GetLowerScreenHeight() - digitHeight#) / 2.0 - digitHeight# * 0.13
				
				maxMove# = GetLowerScreenHeight() * 0.01
				If comboChangingElapsed# <= INGAME_COMBO_DIGIT_SHAKING_TIME / 2.0
					inc centerY#, (comboChangingElapsed# / (INGAME_COMBO_DIGIT_SHAKING_TIME / 2.0) * maxMove#)
				ElseIf comboChangingElapsed# <= INGAME_COMBO_DIGIT_SHAKING_TIME
					inc centerY#, maxMove# - ((comboChangingElapsed# - INGAME_COMBO_DIGIT_SHAKING_TIME / 2.0) / (INGAME_COMBO_DIGIT_SHAKING_TIME / 2.0) * maxMove#)
				EndIf
				
				While comboCopy > 0
					comboCopy = comboCopy / 10
					inc comboDigitCount
				EndWhile
				comboCopy = _SceneInGameComboCount
				For i = 0 To _SceneInGameComboDigitSpriteIds.Length
					If i + 1 <= comboDigitCount
						//SetSpriteVisible(_SceneInGameComboDigitSpriteIds[i], 1)
						SetSpriteColorAlpha(_SceneInGameComboDigitSpriteIds[i], comboAlpha)
						SetSpriteFrame(_SceneInGameComboDigitSpriteIds[i], Mod(comboCopy, 10) + 1)
						comboCopy = comboCopy / 10
						SetSpritePosition(_SceneInGameComboDigitSpriteIds[i], centerX# + (comboDigitCount / 2.0 - (i + 0.5)) * digitWidth#, centerY#)
					Else
						//SetSpriteVisible(_SceneInGameComboDigitSpriteIds[i], 0)
						SetSpriteColorAlpha(_SceneInGameComboDigitSpriteIds[i], 0)
					EndIf
				Next
				//SetSpriteVisible(_SceneInGameComboTextSpriteId, 1)
				SetSpriteColorAlpha(_SceneInGameComboTextSpriteId, comboAlpha)
			Else
				comboAlpha = GetSpriteColorAlpha(_SceneInGameComboTextSpriteId) - MinI(GetSpriteColorAlpha(_SceneInGameComboTextSpriteId), MaxI(1, GetFrameTime() * 255 / 0.25))
				For i = 0 To _SceneInGameComboDigitSpriteIds.Length
					//SetSpriteVisible(_SceneInGameComboDigitSpriteIds[i], 0)
					SetSpriteColorAlpha(_SceneInGameComboDigitSpriteIds[i], comboAlpha)
				Next
				//SetSpriteVisible(_SceneInGameComboTextSpriteId, 0)
				SetSpriteColorAlpha(_SceneInGameComboTextSpriteId, comboAlpha)
			EndIf
			If _SceneInGamePrevComboCount <> _SceneInGameComboCount And comboChangingElapsed# > INGAME_COMBO_DIGIT_SHAKING_TIME
				_SceneInGameComboChangedTime = Timer()
				_SceneInGamePrevComboCount = _SceneInGameComboCount
			EndIf
			zeroAlpha = GetSpriteColorAlpha(_SceneInGameComboZeroSpriteId)
			If zeroAlpha > 0
				SetSpriteColorAlpha(_SceneInGameComboZeroSpriteId, MaxI(1, zeroAlpha - GetFrameTime() * 255))
			EndIf
			
			/* Update playhead */
			ph1 = Round(_SceneInGameMusicTime)
			ph1Colon$ = ":"
			If Mod(ph1, 60) < 10 Then ph1Colon$ = ":0"
			ph2 = Round(_SceneInGameMemo.Length) - ph1
			ph2Colon$ = ":"
			If Mod(ph2, 60) < 10 Then ph2Colon$ = ":0"
			If ph1 >= 0 And ph2 >= 0
				SetTextString(_SceneInGameUpperScreenMusicLength1TextId, Str(ph1 / 60) + ph1Colon$ + Str(Mod(ph1, 60)))
				SetTextY(_SceneInGameUpperScreenMusicLength1TextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_musicplayhead1_y"))
				Select GetThemeValue("ig_musicplayhead1_valign")
					Case 1.0:
						SetTextY(_SceneInGameUpperScreenMusicLength1TextId, GetTextY(_SceneInGameUpperScreenMusicLength1TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength1TextId) * 0.5)
					EndCase
					Case 2.0:
						SetTextY(_SceneInGameUpperScreenMusicLength1TextId, GetTextY(_SceneInGameUpperScreenMusicLength1TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength1TextId))
					EndCase
				EndSelect
				SetTextString(_SceneInGameUpperScreenMusicLength2TextId, "-" + Str(ph2 / 60) + ph2Colon$ + Str(Mod(ph2, 60)))
				SetTextY(_SceneInGameUpperScreenMusicLength2TextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("ig_musicplayhead2_y"))
				Select GetThemeValue("ig_musicplayhead2_valign")
					Case 1.0:
						SetTextY(_SceneInGameUpperScreenMusicLength2TextId, GetTextY(_SceneInGameUpperScreenMusicLength2TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength2TextId) * 0.5)
					EndCase
					Case 2.0:
						SetTextY(_SceneInGameUpperScreenMusicLength2TextId, GetTextY(_SceneInGameUpperScreenMusicLength2TextId) - GetTextTotalHeight(_SceneInGameUpperScreenMusicLength2TextId))
					EndCase
				EndSelect
			EndIf
			
			/* Update music bar */
			
			// update bar position
			progress# = MinF(1.0, MaxF(0.0, (_SceneInGameMusicTime - _SceneInGameMemo.Table[0].Time) / (_SceneInGameMemo.Length - _SceneInGameMemo.Table[0].Time)))
			SetSpriteX(_SceneInGameUpperScreenMusicBarBarSpriteId, _SceneInGameUpperScreenMusicBarStartX +  progress# * (_SceneInGameUpperScreenMusicBarEndX - _SceneInGameUpperScreenMusicBarStartX) - GetSpriteWidth(_SceneInGameUpperScreenMusicBarBarSpriteId) * 0.5)
			
			// update dots
			If SceneInGameAutoplay
				For i = _SceneInGameCompletlyJudgedMusicBarIndex To 119//_SceneInGameMemo.MusicBar.Length
					If _SceneInGameMemo.MusicBar[i].TableIndexEnd < _SceneInGameMemoTableTimeIndex
						_SceneInGameMemo.MusicBar[i].Color = 4
						SetSpriteFrame(_SceneInGameUpperScreenMusicBarDotSpriteIds[i], 4)
						_SceneInGameCompletlyJudgedMusicBarIndex = i
					Else
						Exit
					EndIf
				Next
			Else
				For i = _SceneInGameCompletlyJudgedMusicBarIndex To 119//_SceneInGameMemo.MusicBar.Length
					If _SceneInGameMemo.MusicBar[i].TableIndexEnd <= _SceneInGameCompletlyJudgedTableIndex
						frameNo = 4
						For j = _SceneInGameMemo.MusicBar[i].TableIndexStart To _SceneInGameMemo.MusicBar[i].TableIndexEnd
							// 1miss 2bad 3good 4great 5perfect
							Select frameNo
								Case 4:
									If _SceneInGameMemo.Table[j].Judged < 5
										frameNo = 3
										If _SceneInGameMemo.Table[j].Judged < 3 Then frameNo = 2
									EndIf
								EndCase
								Case 3:
									If _SceneInGameMemo.Table[j].Judged < 3 Then frameNo = 2
								EndCase
								Case Default:
									Exit
								EndCase
							EndSelect
						Next
						_SceneInGameMemo.MusicBar[i].Color = frameNo
						SetSpriteFrame(_SceneInGameUpperScreenMusicBarDotSpriteIds[i], frameNo)
						_SceneInGameCompletlyJudgedMusicBarIndex = i
					Else
						Exit
					EndIf
				Next
			EndIf
			
			
			/* Delete not playing markers and effects */
			
			For i = 0 To _SceneInGameMarkers.Length Step 1
				If GetSpritePlaying(_SceneInGameMarkers[i].SpriteId) = 0
					DeleteSprite(_SceneInGameMarkers[i].SpriteId)
					_SceneInGameMarkers.Remove(i)
					dec i
				EndIf
			Next i
			_SceneInGameDeleteNotPlayingJudgementEffects()
			
			
			/* Delete StartHere */
			
			If _SceneInGamePreparingStartHereSpriteIds.Length >= 0
				dismissStart# = _SceneInGameMemo.Table[0].Time + INGAME_START_HERE_DISMISSING_OFFSET - INGAME_START_HERE_DISMISSING_TIME
				dismissEnd# = _SceneInGameMemo.Table[0].Time + INGAME_START_HERE_DISMISSING_OFFSET
				If _SceneInGameMusicTime >= dismissEnd#
					DeleteSpritesInArray(_SceneInGamePreparingStartHereSpriteIds)
				EndIf
				If _SceneInGameMusicTime >= dismissStart#
					For i = 0 To _SceneInGamePreparingStartHereSpriteIds.Length Step 1
						SetSpriteColorAlpha(_SceneInGamePreparingStartHereSpriteIds[i], 255 - 255 * (_SceneInGameMusicTime - dismissStart#) / (dismissEnd# - dismissStart#))
					Next i
				EndIf
			EndIf
			
			
			/* update hold arrows and delete not playing */
			
			For i = 0 To _SceneInGameArrows.Length
				If _SceneInGameMusicTime >= _SceneInGameArrows[i].EndTime Or Not _SceneInGameArrows[i].Holding And _SceneInGameMusicTime > _SceneInGameArrows[i].Time + GetSettingsBadRange()
					//DeleteSprite(_SceneInGameArrows[i].ArrowSpriteId)
					//DeleteSprite(_SceneInGameArrows[i].ArrowGlowSpriteId)
					//DeleteSprite(_SceneInGameArrows[i].ButtonGlowSpriteId)
					//DeleteSprite(_SceneInGameArrows[i].LaserSpriteId)
					//DeleteSprite(_SceneInGameArrows[i].ArrowBorderSpriteId)
					_SceneInGameArrows[i].NeedToRemove = 1
					//_SceneInGameArrows.Remove(i)
					//dec i
				Else
					//angleSin# = Sin(GetSpriteAngle(_SceneInGameArrows[i].ArrowSpriteId))
					//angleCos# = Cos(GetSpriteAngle(_SceneInGameArrows[i].ArrowSpriteId))
					sinAngle# = _SceneInGameArrows[i].SinAngle  // 0 1 0 -1
					cosAngle# = _SceneInGameArrows[i].CosAngle  // 1 0 -1 0
					inc _SceneInGameArrows[i].LaserAlphaFactor, GetFrameTime() / 0.4
					SetSpriteColorAlpha(_SceneInGameArrows[i].LaserSpriteId, _SceneInGameArrows[i].LaserAlphaFactor * 255)
					SetSpriteColorAlpha(_SceneInGameArrows[i].ArrowBorderSpriteId, _SceneInGameArrows[i].LaserAlphaFactor * 255)
					
					// arrow pos and size
					If _SceneInGameArrows[i].ArrowSizeFactor < 0.5
						inc _SceneInGameArrows[i].ArrowSizeFactor, GetFrameTime() / 0.2  //0.0~0.5
						If _SceneInGameArrows[i].ArrowSizeFactor > 0.5 Then _SceneInGameArrows[i].ArrowSizeFactor = 0.5
						SetSpriteSize(_SceneInGameArrows[i].ArrowSpriteId, GetJButtonSize() * (0.5 - (0.5 - _SceneInGameArrows[i].ArrowSizeFactor) * Abs(cosAngle#)), GetJButtonSize() * (0.5 - (0.5 - _SceneInGameArrows[i].ArrowSizeFactor) * Abs(sinAngle#)))
						SetSpriteX(_SceneInGameArrows[i].ArrowSpriteId, GetJButtonX(_SceneInGameArrows[i].ArrowIndex) + GetJButtonSize() * (0.25 + (0.25*sinAngle#) + ((0.5 - _SceneInGameArrows[i].ArrowSizeFactor) * 0.5) * Abs(cosAngle#)))
						SetSpriteY(_SceneInGameArrows[i].ArrowSpriteId, GetJButtonY(_SceneInGameArrows[i].ArrowIndex) + GetJButtonSize() * (0.25 + (-0.25*cosAngle#) + ((0.5 - _SceneInGameArrows[i].ArrowSizeFactor) * 0.5) * Abs(sinAngle#)))
					ElseIf _SceneInGameArrows[i].Holding
						inc _SceneInGameArrows[i].ArrowSizeFactor, GetFrameTime()/0.2  //0.5~1.0
						If _SceneInGameArrows[i].ArrowSizeFactor > 1.0 Then _SceneInGameArrows[i].ArrowSizeFactor = 1.0
						SetSpriteSize(_SceneInGameArrows[i].ArrowSpriteId, GetJButtonSize() * (0.5 - (0.5 - _SceneInGameArrows[i].ArrowSizeFactor)), GetJButtonSize() * (0.5 - (0.5 - _SceneInGameArrows[i].ArrowSizeFactor)))
						SetSpriteX(_SceneInGameArrows[i].ArrowSpriteId, GetJButtonX(_SceneInGameArrows[i].ArrowIndex) + GetJButtonSize() * ((0.5*sinAngle# * (1.0 - (_SceneInGameArrows[i].ArrowSizeFactor*2.0 - 1.0) ))  + 1.0 - _SceneInGameArrows[i].ArrowSizeFactor) * 0.5)
						SetSpriteY(_SceneInGameArrows[i].ArrowSpriteId, GetJButtonY(_SceneInGameArrows[i].ArrowIndex) + GetJButtonSize() * ((-0.5*cosAngle# * (1.0 - (_SceneInGameArrows[i].ArrowSizeFactor*2.0 - 1.0) ))  + 1.0 - _SceneInGameArrows[i].ArrowSizeFactor) * 0.5)
					EndIf
					
					// Laser pos and size
					If Abs(sinAngle#) > 0.5
						//horz
						SetSpriteSize(_SceneInGameArrows[i].LaserSpriteId, Abs(GetJButtonX(_SceneInGameArrows[i].ArrowIndex) - GetJButtonX(_SceneInGameArrows[i].ButtonIndex)), GetJButtonSize() * 0.5)
					Else
						//vert
						SetSpriteSize(_SceneInGameArrows[i].LaserSpriteId, GetJButtonSize() * 0.5, Abs(GetJButtonY(_SceneInGameArrows[i].ArrowIndex) - GetJButtonY(_SceneInGameArrows[i].ButtonIndex)))
					EndIf
					SetSpriteX(_SceneInGameArrows[i].LaserSpriteId, GetJButtonX(_SceneInGameArrows[i].ArrowIndex) + GetJButtonSize() * 0.25 * Abs(cosAngle#))
					SetSpriteY(_SceneInGameArrows[i].LaserSpriteId, GetJButtonY(_SceneInGameArrows[i].ArrowIndex) + GetJButtonSize() * 0.25 * Abs(sinAngle#))
					If _SceneInGameArrows[i].ArrowIndex > _SceneInGameArrows[i].ButtonIndex
						SetSpriteX(_SceneInGameArrows[i].LaserSpriteId, GetSpriteX(_SceneInGameArrows[i].LaserSpriteId) - (GetJButtonX(_SceneInGameArrows[i].ArrowIndex) - GetJButtonX(_SceneInGameArrows[i].ButtonIndex+1) + GetJButtonSpacing()) * sinAngle#)
						SetSpriteY(_SceneInGameArrows[i].LaserSpriteId, GetSpriteY(_SceneInGameArrows[i].LaserSpriteId) + (GetJButtonY(_SceneInGameArrows[i].ArrowIndex) - GetJButtonY(_SceneInGameArrows[i].ButtonIndex+4) + GetJButtonSpacing()) * cosAngle#)
					EndIf
					
					// move by offset
					If _SceneInGameArrows[i].Holding
						// move arrow
						arrowProg# = MaxF(0.0, (_SceneInGameMusicTime - _SceneInGameArrows[i].Time) / (_SceneInGameArrows[i].EndTime - _SceneInGameArrows[i].Time))
						moveX# = (GetJButtonX(_SceneInGameArrows[i].ButtonIndex) - GetJButtonX(_SceneInGameArrows[i].ArrowIndex)) * arrowProg#
						moveY# = (GetJButtonY(_SceneInGameArrows[i].ButtonIndex) - GetJButtonY(_SceneInGameArrows[i].ArrowIndex)) * arrowProg#
						SetSpriteX(_SceneInGameArrows[i].ArrowSpriteId, GetSpriteX(_SceneInGameArrows[i].ArrowSpriteId) + moveX#)
						SetSpriteY(_SceneInGameArrows[i].ArrowSpriteId, GetSpriteY(_SceneInGameArrows[i].ArrowSpriteId) + moveY#)
						
						// move laser
						SetSpriteSize(_SceneInGameArrows[i].LaserSpriteId, GetSpriteWidth(_SceneInGameArrows[i].LaserSpriteId) - Abs(moveX#), GetSpriteHeight(_SceneInGameArrows[i].LaserSpriteId) - Abs(moveY#))
						If cosAngle# > 0.5
							//moveY
							SetSpriteY(_SceneInGameArrows[i].LaserSpriteId, GetSpriteY(_SceneInGameArrows[i].LaserSpriteId) + moveY#)
						ElseIf sinAngle# < -0.5
							//moveX
							SetSpriteX(_SceneInGameArrows[i].LaserSpriteId, GetSpriteX(_SceneInGameArrows[i].LaserSpriteId) + moveX#)
						EndIf
						
						// glowing
						inc _SceneInGameArrows[i].ButtonGlowAlphaFactor, GetFrameTime() / 0.333
						If _SceneInGameArrows[i].ButtonGlowAlphaFactor > 1.0 Then _SceneInGameArrows[i].ButtonGlowAlphaFactor = 1.0
						
						If Not GetSpritePlaying(_SceneInGameArrows[i].ButtonGlowSpriteId) Then PlaySprite(_SceneInGameArrows[i].ButtonGlowSpriteId, 30, 1)
						
						inc _SceneInGameArrows[i].ArrowGlowAlphaFactor, GetFrameTime() / 0.333
						If _SceneInGameArrows[i].ArrowGlowAlphaFactor > 2.0 Then dec _SceneInGameArrows[i].ArrowGlowAlphaFactor, 2.0
					Else
						//_SceneInGameArrows[i].ArrowGlowAlphaFactor = 0.5
						dec _SceneInGameArrows[i].ButtonGlowAlphaFactor, GetFrameTime() / 0.2
						If _SceneInGameArrows[i].ButtonGlowAlphaFactor < 0.0 Then _SceneInGameArrows[i].ButtonGlowAlphaFactor = 0.0
					EndIf
					SetSpriteColorAlpha(_SceneInGameArrows[i].ButtonGlowSpriteId, _SceneInGameArrows[i].ButtonGlowAlphaFactor * 255)
					
					// arrow glow pos
					SetSpritePosition(_SceneInGameArrows[i].ArrowGlowSpriteId, GetSpriteX(_SceneInGameArrows[i].ArrowSpriteId), GetSpriteY(_SceneInGameArrows[i].ArrowSpriteId))
					SetSpriteSize(_SceneInGameArrows[i].ArrowGlowSpriteId, GetSpriteWidth(_SceneInGameArrows[i].ArrowSpriteId), GetSpriteHeight(_SceneInGameArrows[i].ArrowSpriteId))
					SetSpriteColorAlpha(_SceneInGameArrows[i].ArrowGlowSpriteId, IfFloat(_SceneInGameArrows[i].ArrowGlowAlphaFactor > 1.0, 255 - (_SceneInGameArrows[i].ArrowGlowAlphaFactor - 1.0) * 255, _SceneInGameArrows[i].ArrowGlowAlphaFactor * 255))
				EndIf
			Next
			
			
			/* Get music playhead */
			
			
			If _SceneInGameLastTime < 0 Then _SceneInGameLastTime = Timer()
			inc _SceneInGameMusicTime, Timer() - _SceneInGameLastTime
			_SceneInGameLastTime = Timer()
			reportedTime# = GetMusicPosition()
			reportingWeight# = 0.00
			If _SceneInGameMusicTime < 0.15 
				reportingWeight# = 0.50
			Else
				dif# = Abs(_SceneInGameMusicTime - reportedTime#)
				If dif# >= GetTextSettingsSectionStarts(1)
					If dif# < GetTextSettingsSectionStarts(2)
						reportingWeight# = GetTextSettingsSectionWeights(1)
					ElseIf dif# < GetTextSettingsSectionStarts(3)
						reportingWeight# = GetTextSettingsSectionWeights(2)
					ElseIf dif# < GetTextSettingsSectionStarts(4)
						reportingWeight# = GetTextSettingsSectionWeights(3)
					Else
						reportingWeight# = GetTextSettingsSectionWeights(4)
					EndIf
				EndIf
			EndIf
			
			
//			Print((_SceneInGameMusicTime - reportedTime#))
//			Print(Str(_SceneInGameMemo.NotesCount) + "  " +Str(_SceneInGameMemo.HoldsCount))
			If GetMusicPlaying()
				If reportedTime# <> _SceneInGamePrevReportedTime
					_SceneInGameMusicTime = _SceneInGameMusicTime*(1.0 - reportingWeight#) + reportedTime# * reportingWeight#
					_SceneInGamePrevReportedTime = reportedTime#
				EndIf
			ElseIf _SceneInGameMusicTime >= 0.0 And _SceneInGameMusicTime <= 5.0
				SetMusicFileVolume(_SceneInGameMusicId, GetSettingsMusicVolume())
				PlayMusic(_SceneInGameMusicId)
				//SeekMusic(_SceneInGameMusicTime, 0)
				//_SceneInGamePrevReportedTime = GetMusicPosition()
				//_SceneInGameMusicTime = GetMusicPosition()
				_SceneInGameMusicTime = 0.0
			EndIf
			
			
			/* Appear markers */
			
			// Create markers
			If _SceneInGameMemoTableMarkerIndex <= _SceneInGameMemo.NotesCount - 1
				While _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].Time - 1.0/MARKER_FPS * 15.5 /*GetSettingsJudgementMarkerFrameNumber()*/ <= _SceneInGameMusicTime
					If Not _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].Judged
						marker As _SceneInGameMarker
						marker.JButtonIndex = _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].Button
						markerImageId = _SceneInGameMarkerImage
						If _SceneInGameMarkerHighlightImage > 0
							If _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].ArrowIndex > 0 Then markerImageId = _SceneInGameMarkerHighlightImage
						EndIf
						marker.SpriteId = CreateSprite(markerImageId)
						//If _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].ArrowIndex > 0 Then SetSpriteColor(marker.SpriteId, 160, 160, 255, 255)
						SetSpriteAnimation(marker.SpriteId, GetImageWidth(markerImageId) / 5, GetImageHeight(markerImageId) / 5, 25)
						SetSpriteSize(marker.SpriteId, GetJButtonSize(), GetJButtonSize())
						SetSpritePosition(marker.SpriteId, GetJButtonX(marker.JButtonIndex), GetJButtonY(marker.JButtonIndex))
						SetSpriteDepth(marker.SpriteId, DEPTH_MARKER)
						PlaySprite(marker.SpriteId, MARKER_FPS, 0)  // ADJUST HERE
						marker.Time =  _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].Time
						_SceneInGameMarkers.Insert(marker)
					EndIf
					
					If _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].ArrowIndex > 0
						// If has hold
						arrow As _SceneInGameArrow
						arrow.Time = _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].Time
						arrow.EndTime = _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].HoldingEndTime
						arrow.ButtonIndex = _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].Button
						arrow.ArrowIndex = _SceneInGameMemo.Table[_SceneInGameMemoTableMarkerIndex].ArrowIndex
						arrow.LaserAlphaFactor = 0.0
						arrow.ArrowSizeFactor = 0.0
						arrow.ButtonGlowAlphaFactor = 0.0
						arrow.Holding = 0//SceneInGameAutoplay
						arrow.ArrowGlowAlphaFactor = 0.0
						arrow.TableIndex = _SceneInGameMemoTableMarkerIndex
						arrow.NeedToRemove = 0
						
						//sin 0 1 0 -1
						//cos 1 0 -1 0
						//0    0,0, 0,1, 1,0, 1,1
						//90   0,1, 1,1, 0,0, 1,0
						//180  1,1, 1,0, 0,1, 0,0
						//270  1,0, 0,0, 1,1, 0,1
						
						arrow.ArrowSpriteId = CreateSprite(_SceneInGameHoldArrowImageId)
						SetSpriteDepth(arrow.ArrowSpriteId, DEPTH_ARROW)
						
						arrow.LaserSpriteId = CreateSprite(GetThemeImage("hold_laser"))
						SetSpriteDepth(arrow.LaserSpriteId, DEPTH_LASER)
						SetSpriteColorAlpha(arrow.LaserSpriteId, 0)
						
						arrow.ButtonGlowSpriteId = CreateSprite(_SceneInGameHoldGlowImageId)
						SetSpriteAnimation(arrow.ButtonGlowSpriteId, GetImageWidth(_SceneInGameHoldGlowImageId) / 4.0, GetImageHeight(_SceneInGameHoldGlowImageId) / 4.0, 16)
						SetSpriteSize(arrow.ButtonGlowSpriteId, GetJButtonSize(), GetJButtonSize())
						SetSpritePosition(arrow.ButtonGlowSpriteId, GetJButtonX(arrow.ButtonIndex), GetJButtonY(arrow.ButtonIndex))
						SetSpriteDepth(arrow.ButtonGlowSpriteId, DEPTH_HOLDGLOW)
						SetSpriteColorAlpha(arrow.ButtonGlowSpriteId, 0)
						
						arrow.ArrowBorderSpriteId = CreateSprite(_SceneInGameHoldArrowBorderImageId)
						SetSpriteSize(arrow.ArrowBorderSpriteId, GetJButtonSize(), GetJButtonSize())
						SetSpritePosition(arrow.ArrowBorderSpriteId, GetJButtonX(arrow.ButtonIndex), GetJButtonY(arrow.ButtonIndex))
						SetSpriteDepth(arrow.ArrowBorderSpriteId, DEPTH_ARROWBORDER)
						SetSpriteColorAlpha(arrow.ArrowBorderSpriteId, 0)
						
						arrow.ArrowGlowSpriteId = CreateSprite(_SceneInGameHoldArrowGlowImageId)
						SetSpriteDepth(arrow.ArrowGlowSpriteId, DEPTH_ARROWGLOW)
						SetSpriteColorAlpha(arrow.ArrowGlowSpriteId, 0)
						
						arrowAngle = 0
						If (arrow.ArrowIndex-1) / 4 = (arrow.ButtonIndex-1) / 4  //horz
							If arrow.ArrowIndex < arrow.ButtonIndex
								arrowAngle = 270
								SetSpriteUV(arrow.ArrowBorderSpriteId, 1,0, 0,0, 1,1, 0,1)
								SetSpriteUV(arrow.ArrowGlowSpriteId, 1,0, 0,0, 1,1, 0,1)
								SetSpriteUV(arrow.ArrowSpriteId, 1,0, 0,0, 1,1, 0,1)
								SetSpriteUV(arrow.LaserSpriteId, 1,0, 0,0, 1,1, 0,1)
							Else
								arrowAngle = 90
								SetSpriteUV(arrow.ArrowBorderSpriteId, 0,1, 1,1, 0,0, 1,0)
								SetSpriteUV(arrow.ArrowGlowSpriteId, 0,1, 1,1, 0,0, 1,0)
								SetSpriteUV(arrow.ArrowSpriteId, 0,1, 1,1, 0,0, 1,0)
								SetSpriteUV(arrow.LaserSpriteId, 0,1, 1,1, 0,0, 1,0)
							EndIf
						ElseIf arrow.ArrowIndex > arrow.ButtonIndex  //vert
							arrowAngle = 180
							SetSpriteUV(arrow.ArrowBorderSpriteId, 1,1, 1,0, 0,1, 0,0)
							SetSpriteUV(arrow.ArrowGlowSpriteId, 1,1, 1,0, 0,1, 0,0)
							SetSpriteUV(arrow.ArrowSpriteId, 1,1, 1,0, 0,1, 0,0)
							SetSpriteUV(arrow.LaserSpriteId, 1,1, 1,0, 0,1, 0,0)
						EndIf
						arrow.SinAngle = Sin(arrowAngle)
						arrow.CosAngle = Cos(arrowAngle)
						
						_SceneInGameArrows.InsertSorted(arrow)
					EndIf
					
					inc _SceneInGameMemoTableMarkerIndex
					If _SceneInGameMemoTableMarkerIndex > _SceneInGameMemo.NotesCount - 1 Then Exit
				EndWhile
			EndIf
			
			
			/* Process input and judgement */
			
			// Get nearest past time index
			If _SceneInGameMemoTableTimeIndex <= _SceneInGameMemo.NotesCount - 1
				While _SceneInGameMemo.Table[_SceneInGameMemoTableTimeIndex].Time <= _SceneInGameMusicTime
					inc _SceneInGameMemoTableTimeIndex
					If _SceneInGameMemoTableTimeIndex > _SceneInGameMemo.NotesCount - 1 Then Exit
				EndWhile
			EndIf
			
			// If autoplay mode
			If SceneInGameAutoplay
				playClap = 0
				If _SceneInGameMemoTableTimeIndexForClap <= _SceneInGameMemo.NotesCount - 1
					While _SceneInGameMemo.Table[_SceneInGameMemoTableTimeIndexForClap].Time <= _SceneInGameMusicTime - GetSettingsClapTiming()
						playClap = 1
						inc _SceneInGameMemoTableTimeIndexForClap
						If _SceneInGameMemoTableTimeIndexForClap > _SceneInGameMemo.NotesCount - 1 Then Exit
					EndWhile
				EndIf
				If playClap And GetSettingsPlayClap() Then SetSoundInstanceVolume(PlaySound(GetThemeSound("snd_clap")), GetSettingsClapVolume())
				For i = 0 To _SceneInGameMarkers.Length Step 1
					If GetSpriteCurrentFrame(_SceneInGameMarkers[i].SpriteId) >= Round(MARKER_FPS*0.5 + 1.0) //GetSettingsJudgementMarkerFrameNumber()
						_SceneInGameInvokeJudgementEffect(_SceneInGameMarkers[i].JButtonIndex, 5)
						inc _SceneInGamePerfectCount
						inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_PERFECTGREAT
						inc _SceneInGameComboCount
						DeleteSprite(_SceneInGameMarkers[i].SpriteId)
						_SceneInGameMarkers.Remove(i)
						dec i
					EndIf
				Next i
				For i = 0 To _SceneInGameArrows.Length
					If _SceneInGameArrows[i].Time <= _SceneInGameMusicTime + GetFrameTime()
						_SceneInGameArrows[i].Holding = 1
					EndIf
					If _SceneInGameMusicTime >= _SceneInGameArrows[i].EndTime And Not _SceneInGameArrows[i].NeedToRemove
						_SceneInGameInvokeJudgementEffect(_SceneInGameArrows[i].ButtonIndex, 5)
						inc _SceneInGamePerfectCount
						inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_PERFECTGREAT
						inc _SceneInGameComboCount
					EndIf
				Next
			
			// Not autoplay mode
			Else
				// Get nearest memo table index (each button)
				nearestTableIndexes As Integer[16]
				For i = 0 To 16
					nearestTableIndexes[i] = -1
				Next
				iStart = MaxI(_SceneInGameMemoTableTimeIndex - 32, 0) // from forward 32 notes 
				iEnd = MinI(_SceneInGameMemoTableTimeIndex + 32, _SceneInGameMemo.NotesCount - 1) // to backward 32 notes
				For i = iStart To iEnd
					jBtnIdx = _SceneInGameMemo.Table[i].Button
					If nearestTableIndexes[jBtnIdx] = -1
						nearestTableIndexes[jBtnIdx] = i
					ElseIf Abs(_SceneInGameMemo.Table[i].Time - _SceneInGameMusicTime) < Abs(_SceneInGameMemo.Table[nearestTableIndexes[jBtnIdx]].Time - _SceneInGameMusicTime)
						nearestTableIndexes[jBtnIdx] = i
					EndIf
				Next
				
				// Check each pressed button (judge)
				For i = 1 To 16
					arrowIdx = _SceneInGameArrows.Find(i)
					
					If GetJButtonPressed(i)
						If nearestTableIndexes[i] >= 0
							tableIdx = nearestTableIndexes[i]
							If _SceneInGameMemo.Table[tableIdx].Judged = 0
								timediff# = _SceneInGameMusicTime - (_SceneInGameMemo.Table[tableIdx].Time + GetSettingsInputTiming())
								absTimediff# = Abs(timediff#)
								judgement = 0
								If absTimediff# <= GetSettingsPerfectRange()
									judgement = 5  // perfect
									inc _SceneInGamePerfectCount
									inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_PERFECTGREAT
								ElseIf  absTimediff# <= GetSettingsGreatRange()
									judgement = 4  // great
									inc _SceneInGameGreatCount
									inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_PERFECTGREAT
								ElseIf absTimediff# <= GetSettingsGoodRange()
									judgement = 3  // good
									inc _SceneInGameGoodCount
									inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_GOOD
								ElseIf absTimediff# <= GetSettingsBadRange()
									judgement = 2  // bad
									inc _SceneInGameBadCount
									inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_BADMISS
								EndIf
								If judgement > 0
									If GetSettingsPlayClap() Then SetSoundInstanceVolume(PlaySound(GetThemeSound("snd_clap")), GetSettingsClapVolume())
									_SceneInGameMemo.Table[tableIdx].Judged = judgement
									_SceneInGameInvokeJudgementEffect(i, judgement)
									inc _SceneInGameComboCount
									// Delete corresponding marker
									For markerIdx = 0 To _SceneInGameMarkers.Length
										If _SceneInGameMarkers[markerIdx].JButtonIndex = i And _SceneInGameMarkers[markerIdx].Time = _SceneInGameMemo.Table[tableIdx].Time
											DeleteSprite(_SceneInGameMarkers[markerIdx].SpriteId)
											_SceneInGameMarkers.Remove(markerIdx)
											Exit
										EndIf
									Next
									If arrowIdx >= 0
										_SceneInGameArrows[arrowIdx].Holding = 1
									EndIf
									// Average Input Timing
									If GetSettingsShowAverageInputTiming()
										MainAverageInputTimingValues.Insert(timediff#)
										inc MainAverageInputTimingValuesSum, timediff#
										If MainAverageInputTimingValues.Length + 1 > GetSettingsAverageInputTimingCounts()
											dec MainAverageInputTimingValuesSum, MainAverageInputTimingValues[0]
											MainAverageInputTimingValues.Remove(0)
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					If arrowIdx >= 0
						If _SceneInGameArrows[arrowIdx].Holding = 1 And Not GetJButtonPressing(i)
							_SceneInGameArrows[arrowIdx].Holding = 0
							absTimediff# = _SceneInGameArrows[arrowIdx].EndTime - _SceneInGameMusicTime
							judgement = 0
							If absTimediff# <= GetSettingsPerfectRange()
								judgement = 5  // perfect
								inc _SceneInGamePerfectCount
								inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_PERFECTGREAT
							ElseIf  absTimediff# <= GetSettingsGreatRange()
								judgement = 4  // great
								inc _SceneInGameGreatCount
								inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_PERFECTGREAT
							ElseIf absTimediff# <= GetSettingsGoodRange()
								judgement = 3  // good
								inc _SceneInGameGoodCount
								inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_GOOD
							ElseIf absTimediff# <= GetSettingsBadRange()
								judgement = 2  // bad
								inc _SceneInGameBadCount
								inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_BADMISS
							Else
								inc _SceneInGameMissCount
								If _SceneInGameComboCount >= 5
									SetSpriteColorAlpha(_SceneInGameComboZeroSpriteId, 255)
								EndIf
								_SceneInGameMemo.Table[_SceneInGameArrows[arrowIdx].TableIndex].Judged = 1
								_SceneInGameComboCount = 0
							EndIf
							If judgement > 0 And Not _SceneInGameArrows[arrowIdx].NeedToRemove
								_SceneInGameMemo.Table[_SceneInGameArrows[arrowIdx].TableIndex].Judged = MinI(judgement, _SceneInGameMemo.Table[_SceneInGameArrows[arrowIdx].TableIndex].Judged)
								_SceneInGameInvokeJudgementEffect(i, judgement)
								inc _SceneInGameComboCount
							EndIf
							_SceneInGameArrows[arrowIdx].NeedToRemove = 1
						ElseIf _SceneInGameMusicTime >= _SceneInGameArrows[arrowIdx].EndTime And Not _SceneInGameArrows[arrowIdx].NeedToRemove
							inc _SceneInGamePerfectCount
							inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_PERFECTGREAT
							_SceneInGameInvokeJudgementEffect(i, 5)
							inc _SceneInGameComboCount
							_SceneInGameArrows[arrowIdx].NeedToRemove = 1
						EndIf
					EndIf
				Next
				
				
				// Check missed notes
				For i = _SceneInGameCompletlyJudgedTableIndex To _SceneInGameMemo.NotesCount - 1
					If _SceneInGameMemo.Table[i].Judged = 0
						If _SceneInGameMemo.Table[i].Time < _SceneInGameMusicTime - GetSettingsBadRange()
							_SceneInGameMemo.Table[i].Judged = 1
							inc _SceneInGameMissCount
							If _SceneInGameComboCount >= 5
								SetSpriteColorAlpha(_SceneInGameComboZeroSpriteId, 255)
							EndIf
							_SceneInGameComboCount = 0
							
							inc _SceneInGameBonusCount, INGAME_BONUS_COUNT_BADMISS
						Else//If _SceneInGameMemo.Table[i].Time > _SceneInGameMusicTime
							Exit
						EndIf
					EndIf
					_SceneInGameCompletlyJudgedTableIndex = i
				Next
			EndIf
			For i = 0 To _SceneInGameArrows.Length
				If _SceneInGameArrows[i].NeedToRemove
					DeleteSprite(_SceneInGameArrows[i].ArrowSpriteId)
					DeleteSprite(_SceneInGameArrows[i].ArrowGlowSpriteId)
					DeleteSprite(_SceneInGameArrows[i].ButtonGlowSpriteId)
					DeleteSprite(_SceneInGameArrows[i].LaserSpriteId)
					DeleteSprite(_SceneInGameArrows[i].ArrowBorderSpriteId)
					_SceneInGameArrows.Remove(i)
					dec i
				EndIf
			Next
			
			/* Check music end */
			
			If GetJButtonPressed(0) Or ( (DEBUG_MODE And _SceneInGameMusicTime > 3) Or _SceneInGameMusicTime >= _SceneInGameMemo.Length + INGAME_WATING_AFTER_MUSIC_END/* And Not GetMusicPlaying()*/)
				If DEBUG_MODE Then _SceneInGameShutterUVChanging(1.0, 0.0)  //DEBUG
				
				DeleteSpritesInArray(_SceneInGamePreparingStartHereSpriteIds)
				
//				SetSyncRate(30, 0)
				
				// Stop music
				StopMusic()
				
				// hide playhead bar
				SetSpriteVisible(_SceneInGameUpperScreenMusicBarBarSpriteId, 0)
				
				// Delete markers and effects
				While _SceneInGameMarkers.Length >= 0
					DeleteSprite(_SceneInGameMarkers[_SceneInGameMarkers.Length].SpriteId)
					_SceneInGameMarkers.Remove()
				EndWhile
				DeleteSpritesInArray(_SceneInGameJudgementEffectSprites)
				While _SceneInGameJudgementEffectPlayingTimes.Length >= 0
					_SceneInGameJudgementEffectPlayingTimes.Remove()
				EndWhile
				While _SceneInGameArrows.Length >= 0
					DeleteSprite(_SceneInGameArrows[_SceneInGameArrows.Length].ArrowSpriteId)
					DeleteSprite(_SceneInGameArrows[_SceneInGameArrows.Length].ArrowGlowSpriteId)
					DeleteSprite(_SceneInGameArrows[_SceneInGameArrows.Length].ButtonGlowSpriteId)
					DeleteSprite(_SceneInGameArrows[_SceneInGameArrows.Length].LaserSpriteId)
					DeleteSprite(_SceneInGameArrows[_SceneInGameArrows.Length].ArrowBorderSpriteId)
					_SceneInGameArrows.Remove()
				EndWhile
				
				// Play result sound
				PlaySound(GetThemeSound("snd_voice_result"))
				
				// Record!
				If Not SceneInGameAutoplay And Not GetJButtonPressed(0)
					If _SceneInGameScore + _SceneInGameBonusScore > GetMusicRecordsHighScore(_SceneInGameMemo.Sha256String)
						recordItem As MusicRecordsItem
						recordItem.HighScore = _SceneInGameScore + _SceneInGameBonusScore
						recordItem.HighScoredTime = GetUnixTime()
						recordItem.LastPlayedTime = GetUnixTime()
						For i = 0 To 119
							recordItem.MusicBarColors[i] = MaxI(1, _SceneInGameMemo.MusicBar[i].Color)
						Next
						recordItem.ShaString = _SceneInGameMemo.Sha256String
						SetMusicRecords(recordItem)
						_SceneInGameUpperScreenIsNewRecord = 1
					Else
						SetMusicRecordsLastPlayedTime(_SceneInGameMemo.Sha256String, GetUnixTime())
						_SceneInGameUpperScreenIsNewRecord = 0
					EndIf
					If _SceneInGameComboCount = _SceneInGameMemo.NotesCount + _SceneInGameMemo.HoldsCount
						SetMusicRecordsFullCombo(_SceneInGameMemo.Sha256String, 1)
					EndIf
					WriteMusicRecordsToFile()
				EndIf
				
				// Change state
				_SceneInGameResultTime = _SceneInGameLifeTime
				_SceneInGameState = _SceneInGameStateResult
			EndIf
		EndCase
		Case _SceneInGameStateResult
			totalScore = _SceneInGameScore + _SceneInGameBonusScore
			If DEBUG_MODE Then totalScore = 1000000
			elapsed# = _SceneInGameLifeTime - _SceneInGameResultTime
			isFullCombo = _SceneInGameComboCount = _SceneInGameMemo.NotesCount + _SceneInGameMemo.HoldsCount
			If DEBUG_MODE Then isFullCombo = 1
			isExcellent = totalScore >= 1000000
			
			// close shutter
			If _SceneInGameShutterUVChangingLastShutterFactor > 0.0
				_SceneInGameShutterUVChanging(_SceneInGameShutterUVChangingLastShutterFactor - GetFrameTime() * 1.0 / 0.5, 0.0)
			EndIf
			
			// hide combo
			SetSpriteColorAlpha(_SceneInGameComboZeroSpriteId, 0)
			If GetSpriteColorAlpha(_SceneInGameComboTextSpriteId) > 0.0
				For i = 0 To _SceneInGameComboDigitSpriteIds.Length
					SetSpriteColorAlpha(_SceneInGameComboDigitSpriteIds[i], MaxF(GetSpriteColorAlpha(_SceneInGameComboDigitSpriteIds[i]) - GetFrameTime() * 255 / 0.333, 0.0))
				Next
				SetSpriteColorAlpha(_SceneInGameComboTextSpriteId, MaxF(GetSpriteColorAlpha(_SceneInGameComboTextSpriteId) - GetFrameTime() * 255 / 0.333, 0.0))
			EndIf
			
			// increase score
			If isFullCombo
				If elapsed# >= 3.5 Then _SceneInGameUpdateScoreSprites(_SceneInGameScore + MinF(_SceneInGameBonusScore * (elapsed# - 3.5) / 1.0, _SceneInGameBonusScore))
			Else
				If elapsed# >= 0.5 Then _SceneInGameUpdateScoreSprites(_SceneInGameScore + MinF(_SceneInGameBonusScore * (elapsed# - 0.5) / 1.0, _SceneInGameBonusScore))
			EndIf
			
			// Full combo scene
			If isFullCombo And elapsed# >= 1.5 And elapsed# < 4.0
				dec elapsed#, 1.5
				
				// draw full combo text and play sound
				If _SceneInGameResultFullComboSpriteId = 0
					PlaySound(GetThemeSound("snd_fullcombo"))
					PlaySound(GetThemeSound("snd_voice_fullcombo"))
					_SceneInGameResultFullComboSpriteId = CreateSprite(GetThemeImage("gamebg_fullcombo"))
					SetSpriteSize(_SceneInGameResultFullComboSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight() * 0.5)
					//SetSpritePosition(_SceneInGameResultFullComboSpriteId, GetLowerScreenX(), GetLowerScreenY() + GetLowerScreenHeight() * 0.25)
					SetSpriteDepth(_SceneInGameResultFullComboSpriteId, DEPTH_FULLCOMBO)
				EndIf
				
				// draw full combo fading background
				If _SceneInGameResultFullComboBackFadeSpriteId = 0
					_SceneInGameResultFullComboBackFadeSpriteId = CreateSprite(GetThemeImage("gamebg_fullcombo_backfade"))
					SetSpriteSize(_SceneInGameResultFullComboBackFadeSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
					SetSpritePosition(_SceneInGameResultFullComboBackFadeSpriteId, GetLowerScreenX(), GetLowerScreenY())
					SetSpriteDepth(_SceneInGameResultFullComboBackFadeSpriteId, DEPTH_FULLCOMBO_BACKFADE)
				EndIf
				
				// animate full combo text
				If _SceneInGameResultFullComboSpriteId
					fullComboAlpha# = 255.0
					fullComboScale# = 1.0
					If elapsed# < 0.25
						fullComboAlpha# = (elapsed# / 0.25) * 255.0
						fullComboScale# = 1.4 - ((elapsed# / 0.25) * 0.4)
					ElseIf elapsed# < 2.0
						fullComboScale# = 1.0 - (((elapsed# - 0.25) / 32.0))
					Else
						fullComboAlpha# = MaxF(0.0, 255.0 - (elapsed# - 2.0) / 0.5 * 255.0)
						fullComboScale# = 1.0 - (((elapsed# - 0.25) / 32.0))
					EndIf
					SetSpriteColorAlpha(_SceneInGameResultFullComboSpriteId, fullComboAlpha#)
					SetSpriteScale(_SceneInGameResultFullComboSpriteId, fullComboScale#, fullComboScale#)
					SetSpritePosition(_SceneInGameResultFullComboSpriteId, GetLowerScreenX() + GetLowerScreenHeight() * 0.5 - GetSpriteWidth(_SceneInGameResultFullComboSpriteId) * 0.5, GetLowerScreenY() + GetLowerScreenHeight() * 0.5 - GetSpriteHeight(_SceneInGameResultFullComboSpriteId) * 0.5)
				EndIf
				
				// animate full combo fading background
				If _SceneInGameResultFullComboBackFadeSpriteId
					If elapsed# < 0.25
						SetSpriteColorAlpha(_SceneInGameResultFullComboBackFadeSpriteId, (elapsed# / 0.25) * 255.0)
					Else
						SetSpriteColorAlpha(_SceneInGameResultFullComboBackFadeSpriteId, MaxF(0.0, 255.0 - ((elapsed# - 0.25) / 1.0) * 255.0))
					EndIf
				EndIf
				
			// Result scene
			ElseIf (Not isFullCombo And elapsed# >= 1.5) Or (isFullCombo And elapsed# >= 4.7)
				If GetMusicPlaying() = 0
					SetMusicFileVolume(GetThemeMusic("bgm_result"), GetSettingsMusicVolume())
					PlayMusic(GetThemeMusic("bgm_result"), 1)
				EndIf
				// adjust elapsed time
				If Not isFullCombo And elapsed# >= 1.5 Then dec elapsed#, 1.5
				If isFullCombo And elapsed# >= 4.7 Then dec elapsed#, 4.7
				
				// remove fullcombo sprite
				If GetSpriteExists(_SceneInGameResultFullComboSpriteId)
					DeleteSprite(_SceneInGameResultFullComboSpriteId)
					_SceneInGameResultFullComboSpriteId = 0
				EndIf
				If GetSpriteExists(_SceneInGameResultFullComboBackFadeSpriteId)
					DeleteSprite(_SceneInGameResultFullComboBackFadeSpriteId)
					_SceneInGameResultFullComboBackFadeSpriteId = 0
				EndIf
				
				// judge cleared or failed
				isCleared = totalScore >= 800000
				
				// draw back fade
				If _SceneInGameResultClearedBackFadeSpriteId = 0
					If isExcellent
						_SceneInGameResultClearedBackFadeSpriteId = CreateSprite(GetThemeImage("gamebg_excellent_backfade"))
					ElseIf isCleared
						_SceneInGameResultClearedBackFadeSpriteId = CreateSprite(GetThemeImage("gamebg_cleared_backfade"))
					Else
						_SceneInGameResultClearedBackFadeSpriteId = CreateSprite(GetThemeImage("gamebg_failed_backfade"))
					EndIf
					SetSpriteSize(_SceneInGameResultClearedBackFadeSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
					SetSpritePosition(_SceneInGameResultClearedBackFadeSpriteId, GetLowerScreenX(), GetLowerScreenY())
					SetSpriteDepth(_SceneInGameResultClearedBackFadeSpriteId, DEPTH_CLEARED_BACKFADE)
				EndIf
				
				// draw big text
				If _SceneInGameResultClearedBigSpriteId = 0
					If isExcellent
						_SceneInGameResultClearedBigSpriteId = CreateSprite(GetThemeImage("gamebg_excellent"))
						PlaySound(GetThemeSound("snd_excellent"))
						PlaySound(GetThemeSound("snd_voice_excellent"))
					ElseIf isCleared
						_SceneInGameResultClearedBigSpriteId = CreateSprite(GetThemeImage("gamebg_cleared"))
						PlaySound(GetThemeSound("snd_cleared"))
						PlaySound(GetThemeSound("snd_voice_cleared"))
					Else
						_SceneInGameResultClearedBigSpriteId = CreateSprite(GetThemeImage("gamebg_failed"))
						PlaySound(GetThemeSound("snd_failed"))
						PlaySound(GetThemeSound("snd_voice_failed"))
					EndIf
					SetSpriteSize(_SceneInGameResultClearedBigSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight() * 0.25)
					SetSpritePosition(_SceneInGameResultClearedBigSpriteId, GetLowerScreenX(), GetLowerScreenY() + GetLowerScreenHeight() * 0.25)
					SetSpriteDepth(_SceneInGameResultClearedBigSpriteId, DEPTH_CLEARED_BIG)
				EndIf
				
				// draw small texts
				If _SceneInGameResultClearedSmallSpriteIds.Length < 0
					For i = 1 To 6
						If isCleared
							clearedSmall = CreateSprite(GetThemeImage("gamebg_cleared_small"))
						Else
							clearedSmall = CreateSprite(GetThemeImage("gamebg_failed_small"))
						EndIf
						btnIdx = i
						If btnIdx > 4 Then inc btnIdx, 8
						_SceneInGameResultClearedSmallSpriteIds.Insert(clearedSmall)
						SetSpriteSize(clearedSmall, GetJButtonSize(), GetJButtonSize())
						SetSpritePosition(clearedSmall, GetJButtonX(btnIdx), GetJButtonY(btnIdx))
						SetSpriteDepth(clearedSmall, DEPTH_CLEARED_SMALL)
					Next
				EndIf
				
				// draw rating text
				If _SceneInGameResultRatingTextSpriteId = 0
					_SceneInGameResultRatingTextSpriteId = CreateSprite(GetThemeImage("gamebg_rating"))
					SetSpriteSize(_SceneInGameResultRatingTextSpriteId, GetJButtonSize(), GetJButtonSize())
					SetSpritePosition(_SceneInGameResultRatingTextSpriteId, GetJButtonX(10), GetJButtonY(10))
					SetSpriteDepth(_SceneInGameResultRatingTextSpriteId, DEPTH_RATING_TEXT)
				EndIf
				
				// draw rating character
				If _SceneInGameResultRatingCharSpriteId = 0
					imageName As String
					If totalScore >= SCORE_EXC
						imageName = "gamebg_rating_exc"
					ElseIf totalScore >= SCORE_SSS
						imageName = "gamebg_rating_sss"
					ElseIf totalScore >= SCORE_SS
						imageName = "gamebg_rating_ss"
					ElseIf totalScore >= SCORE_S
						imageName = "gamebg_rating_s"
					ElseIf totalScore >= SCORE_A
						imageName = "gamebg_rating_a"
					ElseIf totalScore >= SCORE_B
						imageName = "gamebg_rating_b"
					ElseIf totalScore >= SCORE_C
						imageName = "gamebg_rating_c"
					ElseIf totalScore >= SCORE_D
						imageName = "gamebg_rating_d"
					Else
						imageName = "gamebg_rating_e"
					EndIf
					
					_SceneInGameResultRatingCharSpriteId = CreateSprite(GetThemeImage(imageName))
					SetSpriteSize(_SceneInGameResultRatingCharSpriteId, GetJButtonSize(), GetJButtonSize())
					SetSpritePosition(_SceneInGameResultRatingCharSpriteId, GetJButtonX(11), GetJButtonY(11))
					SetSpriteDepth(_SceneInGameResultRatingCharSpriteId, DEPTH_RATING_CHAR)
				EndIf
				
				// draw buttons
				If _SceneInGameResultRetrySpriteButtonId = 0
					_SceneInGameResultRetrySpriteButtonId = CreateSpriteButton(15, SpriteButtonTypeRetry)
				EndIf
				If _SceneInGameResultNextSpriteButtonId = 0
					_SceneInGameResultNextSpriteButtonId = CreateSpriteButton(16, SpriteButtonTypeQuit)
				EndIf
				
				// animate back fade
				If _SceneInGameResultClearedBackFadeSpriteId
					clearedBackFadeAlpha# = 0.0
					clearedBackFadeScale# = MaxF(1.0, 1.05 - ((elapsed# / 1.13) * 0.05))
					If elapsed# < 0.1
						clearedBackFadeAlpha# = (elapsed# / 0.1) * 255.0
					ElseIf elapsed# < 0.5
						clearedBackFadeAlpha# = 255.0
					Else
						clearedBackFadeAlpha# = MaxF(0.0, 255.0 - ((elapsed# - 0.6) / 1.13) * 255.0)
					EndIf
					SetSpriteColorAlpha(_SceneInGameResultClearedBackFadeSpriteId, clearedBackFadeAlpha#)
					SetSpriteScale(_SceneInGameResultClearedBackFadeSpriteId, clearedBackFadeScale#, clearedBackFadeScale#)
					SetSpritePosition(_SceneInGameResultClearedBackFadeSpriteId, GetLowerScreenX() + GetLowerScreenWidth() * 0.5 - GetSpriteWidth(_SceneInGameResultClearedBackFadeSpriteId) * 0.5, GetLowerScreenY() + GetLowerScreenHeight() * 0.5 - GetSpriteHeight(_SceneInGameResultClearedBackFadeSpriteId) * 0.5)
				EndIf
				
				// animate big text and newrecord
				If _SceneInGameResultClearedBigSpriteId
					clearedBigAlpha# = 255.0
					clearedBigScale# = 1.0
					If elapsed# < 0.25
						clearedBigAlpha# = (elapsed# / 0.25) * 255.0
						clearedBigScale# = 1.2 - ((elapsed# / 0.25) * 0.2)
					EndIf
					If _SceneInGameUpperScreenIsNewRecord Then SetSpriteColorAlpha(_SceneInGameUpperScreenNewRecordSpriteId, clearedBigAlpha#)
					SetSpriteColorAlpha(_SceneInGameResultClearedBigSpriteId, clearedBigAlpha#)
					SetSpriteScale(_SceneInGameResultClearedBigSpriteId, clearedBigScale#, clearedBigScale#)
					SetSpritePosition(_SceneInGameResultClearedBigSpriteId, GetLowerScreenX() + GetLowerScreenHeight() * 0.5 - GetSpriteWidth(_SceneInGameResultClearedBigSpriteId) * 0.5, GetLowerScreenY() + GetLowerScreenHeight() * 0.375 - GetSpriteHeight(_SceneInGameResultClearedBigSpriteId) * 0.5)
				EndIf
				
				// animate small texts
				If _SceneInGameResultClearedSmallSpriteIds.Length >= 0
					For i = 0 To _SceneInGameResultClearedSmallSpriteIds.Length
						SetSpriteColorAlpha(_SceneInGameResultClearedSmallSpriteIds[i], MinF(255.0, (elapsed# / 0.3) * 255.0))
					Next
				EndIf
				
				// animate rating text
				If _SceneInGameResultRatingTextSpriteId
					SetSpriteColorAlpha(_SceneInGameResultRatingTextSpriteId, MinF(255.0, (elapsed# / 0.3) * 255.0))
				EndIf
				
				// animate rating char
				If _SceneInGameResultRatingCharSpriteId
					ratingCharAlpha# = 255.0
					ratingCharScale# = 1.0
					If elapsed# < 0.5
						ratingCharAlpha# = 0.0
					ElseIf elapsed# < 0.5 + 0.25
						ratingCharAlpha# = ((elapsed# - 0.5) / 0.25) * 255.0
						ratingCharScale# = 1.2 - (((elapsed# - 0.5) / 0.25) * 0.2)
					EndIf
					SetSpriteColorAlpha(_SceneInGameResultRatingCharSpriteId, ratingCharAlpha#)
					SetSpriteScale(_SceneInGameResultRatingCharSpriteId, ratingCharScale#, ratingCharScale#)
					SetSpritePosition(_SceneInGameResultRatingCharSpriteId, GetJButtonX(11) + GetJButtonSize() * 0.5 - GetSpriteWidth(_SceneInGameResultRatingCharSpriteId) * 0.5, GetJButtonY(11) + GetJButtonSize() * 0.5 - GetSpriteHeight(_SceneInGameResultRatingCharSpriteId) * 0.5)
				EndIf
				
				// process button pressed
				If GetSpriteButtonPressed(_SceneInGameResultRetrySpriteButtonId)
					SceneInGameRetry = 1
					DismissSpriteButton(_SceneInGameResultRetrySpriteButtonId, 1)
					DismissSpriteButton(_SceneInGameResultNextSpriteButtonId, 1)
				ElseIf GetSpriteButtonPressed(_SceneInGameResultNextSpriteButtonId)
					SceneInGameRetry = 0
					DismissSpriteButton(_SceneInGameResultRetrySpriteButtonId, 1)
					DismissSpriteButton(_SceneInGameResultNextSpriteButtonId, 1)
				EndIf
				If GetSpriteButtonDismissed(_SceneInGameResultRetrySpriteButtonId) And GetSpriteButtonDismissed(_SceneInGameResultNextSpriteButtonId)
					// fade out
					StartScreenFadeOut()
					
					// Reset average input timing
					While MainAverageInputTimingValues.Length >= 0
						MainAverageInputTimingValues.Remove()
					EndWhile
					MainAverageInputTimingValuesSum = 0.0
					
					// if fade out finished
					If GetScreenFadeOutCompleted()
						_SceneInGameDeleteResourcesAndInitializeVars()
						
						DeleteSpriteButton(_SceneInGameResultRetrySpriteButtonId)
						DeleteSpriteButton(_SceneInGameResultNextSpriteButtonId)
						
						result = SceneResultEnd
					EndIf
				EndIf
			EndIf
		EndCase
	EndSelect
	
	If result = SceneResultEnd Then _SceneInGameLooping = 0
EndFunction result

Global _SceneInGameShutterUVChangingLastShutterFactor As Float = 0.0
Function _SceneInGameShutterUVChanging(shutterFactor As Float, beatBounceFactor As Float)
	If shutterFactor < 0.0 Then shutterFactor = 0.0
	If beatBounceFactor < 0.0 Then beatBounceFactor = 0.0
	_SceneInGameShutterUVChangingLastShutterFactor = shutterFactor
	
	// calculate uv values
	shutterScale# = (1.0 + shutterFactor * 0.5) + (beatBounceFactor * 0.02 + beatBounceFactor * 0.025 * shutterFactor)
	shutterOffset#  = (1.0 - 1.0 / shutterScale#) / 2.0
	shutterMove# = ((shutterFactor * 0.67) + (0.008 * beatBounceFactor)) * 1.0 / shutterScale#
	
	// Back Shutter uv
	SetSpriteUVScale(_SceneInGameBackgroundShutterBackSpriteId, shutterScale#, shutterScale#)
	SetSpriteUVOffset(_SceneInGameBackgroundShutterBackSpriteId, shutterOffset#, shutterOffset#)
	SetSpriteUVScale(_SceneInGameBackgroundShutterBackFade1SpriteId, shutterScale#, shutterScale#)
	SetSpriteUVOffset(_SceneInGameBackgroundShutterBackFade1SpriteId, shutterOffset#, shutterOffset#)
	SetSpriteUVScale(_SceneInGameBackgroundShutterBackFade2SpriteId, shutterScale#, shutterScale#)
	SetSpriteUVOffset(_SceneInGameBackgroundShutterBackFade2SpriteId, shutterOffset#, shutterOffset#)
	
	// Top Shutter uv
	SetSpriteUVScale(_SceneInGameBackgroundShutterTopSpriteId, shutterScale#, shutterScale#)
	SetSpriteUVOffset(_SceneInGameBackgroundShutterTopSpriteId, shutterOffset#, shutterOffset# + shutterMove#)
	
	// Bottom Shutter uv
	SetSpriteUVScale(_SceneInGameBackgroundShutterBottomSpriteId, shutterScale#, shutterScale#)
	SetSpriteUVOffset(_SceneInGameBackgroundShutterBottomSpriteId, shutterOffset# , shutterOffset# - shutterMove#)
EndFunction

Function _SceneInGameUpdateScoreSprites(score As Integer)
	If score > 0
		scoreCopy = score
		//scoreDigitCount = 0
		For i = 0 To _SceneInGameUpperScreenScoreDigitSpriteIds.Length
			SetSpriteVisible(_SceneInGameUpperScreenScoreDigitSpriteIds[i], 0)
		Next
		scoreIdx = 0
		While scoreCopy > 0
			SetSpriteFrame(_SceneInGameUpperScreenScoreDigitSpriteIds[scoreIdx], Mod(scoreCopy, 10) + 1)
			scoreCopy = scoreCopy / 10
			SetSpriteVisible(_SceneInGameUpperScreenScoreDigitSpriteIds[scoreIdx], 1)
			inc scoreIdx
		EndWhile
	Else
		SetSpriteVisible(_SceneInGameUpperScreenScoreDigitSpriteIds[0], 1)
		SetSpriteFrame(_SceneInGameUpperScreenScoreDigitSpriteIds[0], 1)
		For i = 1 To _SceneInGameUpperScreenScoreDigitSpriteIds.Length
			SetSpriteVisible(_SceneInGameUpperScreenScoreDigitSpriteIds[i], 0)
		Next
	EndIf
EndFunction

Function _SceneInGameInvokeJudgementEffect(iJBtnIdx As Integer, iJudgement As Integer)
	If iJudgement < 2 Or iJudgement > 5 Then ExitFunction
	spriteId = 0
	If GetSettingsSimpleEffect()
		If iJudgement = 5
			spriteId = CreateSprite(GetPerfectColorImage())
		ElseIf iJudgement = 4
			spriteId = CreateSprite(GetGreatColorImage())
		ElseIf iJudgement = 3
			spriteId = CreateSprite(GetGoodColorImage())
		Else
			spriteId = CreateSprite(GetBadColorImage())
		EndIf
		_SceneInGameJudgementEffectPlayingTimes.Insert(0.0)
	Else
		imageId = _SceneInGameJudgementEffectImages[iJudgement-1]
		spriteId = CreateSprite(imageId)
		SetSpriteAnimation(spriteId, GetImageWidth(imageId) / 4, GetImageHeight(imageId) / 4, 16)
		PlaySprite(spriteId, MARKER_FPS, 0)  // ADJUST HERE
	EndIf
	
	SetSpriteSize(spriteId, GetJButtonSize(), GetJButtonSize())
	SetSpritePosition(spriteId, GetJButtonX(iJBtnIdx), GetJButtonY(iJBtnIdx))
	SetSpriteDepth(spriteId, DEPTH_JUDGEMENT_EFFECT)
	
	_SceneInGameJudgementEffectSprites.Insert(spriteId)
	
EndFunction

Function _SceneInGameDeleteNotPlayingJudgementEffects()
	If GetSettingsSimpleEffect()
		For i = 0 To _SceneInGameJudgementEffectPlayingTimes.Length
			SetSpriteColorAlpha(_SceneInGameJudgementEffectSprites[i], 255 - 255 * (_SceneInGameJudgementEffectPlayingTimes[i] / SIMPLE_EFFECT_PLAYING_TIME))
			inc _SceneInGameJudgementEffectPlayingTimes[i], GetFrameTime()
			If _SceneInGameJudgementEffectPlayingTimes[i] > SIMPLE_EFFECT_PLAYING_TIME
				DeleteSprite(_SceneInGameJudgementEffectSprites[i])
				_SceneInGameJudgementEffectSprites.Remove(i)
				_SceneInGameJudgementEffectPlayingTimes.Remove(i)
				dec i
			EndIf
		Next
	Else
		For i = 0 To _SceneInGameJudgementEffectSprites.Length Step 1
			If GetSpritePlaying(_SceneInGameJudgementEffectSprites[i]) = 0
				DeleteSprite(_SceneInGameJudgementEffectSprites[i])
				_SceneInGameJudgementEffectSprites.Remove(i)
				dec i
			EndIf
		Next i
	EndIf
EndFunction

Function _SceneInGameDeleteResourcesAndInitializeVars()
	_SceneInGameError.Code = 0
	DeleteText(_SceneInGameErrorTextId)
	_SceneInGameErrorTextId = 0
	DeleteSpriteButton(_SceneInGameErrorOkSpriteButtonId)
	_SceneInGameErrorOkSpriteButtonId = 0
	DeleteSpriteButton(_SceneInGameResultNextSpriteButtonId)
	_SceneInGameResultNextSpriteButtonId = 0
	DeleteSpriteButton(_SceneInGameResultRetrySpriteButtonId)
	_SceneInGameResultRetrySpriteButtonId = 0
	If _SceneInGameMusicId > 0 Then DeleteMusic(_SceneInGameMusicId)
	_SceneInGameMusicId = 0
	_SceneInGameLifeTime = 0.0
	_SceneInGamePrevReportedTime = 0.0
	_SceneInGameMusicTime = 0.0
	_SceneInGameLastTime = -1.0
	_SceneInGameMemoTableMarkerIndex = 0
	_SceneInGameMemoTableTimeIndex = 0
	_SceneInGameMemoTableTimeIndexForClap = 0
	_SceneInGameCompletlyJudgedTableIndex = 0
	_SceneInGameMemoTableBeatTimingIndex = 0
	_SceneInGameScore = 0.0
	_SceneInGameBonusScore = 0.0
	_SceneInGamePerfectCount = 0
	_SceneInGameGreatCount = 0
	_SceneInGameGoodCount = 0
	_SceneInGameBadCount = 0
	_SceneInGameMissCount = 0
	_SceneInGameBonusCount = 0
	_SceneInGamePrevComboCount = 0
	_SceneInGameComboCount = 0
	_SceneInGameComboChangedTime = 0.0
	DeleteSprite(_SceneInGameBackgroundShutterTopSpriteId)
	_SceneInGameBackgroundShutterTopSpriteId = 0
	DeleteSprite(_SceneInGameBackgroundShutterBottomSpriteId)
	_SceneInGameBackgroundShutterBottomSpriteId = 0
	DeleteSprite(_SceneInGameBackgroundShutterBackSpriteId)
	_SceneInGameBackgroundShutterBackSpriteId = 0
	DeleteSprite(_SceneInGameBackgroundShutterBackFade1SpriteId)
	_SceneInGameBackgroundShutterBackFade1SpriteId = 0
	DeleteSprite(_SceneInGameBackgroundShutterBackFade2SpriteId)
	_SceneInGameBackgroundShutterBackFade2SpriteId = 0
	_SceneInGameBackgroundShutterBackFade2Alpha = 0.0
	_SceneInGameBackgroundShutterFactor = 0.0
	DeleteSpritesInArray(_SceneInGameComboDigitSpriteIds)
	DeleteSprite(_SceneInGameComboZeroSpriteId)
	_SceneInGameComboZeroSpriteId = 0
	DeleteSprite(_SceneInGameComboTextSpriteId)
	_SceneInGameComboTextSpriteId = 0
	DeleteSpritesInArray(_SceneInGameUpperScreenScoreDigitSpriteIds)
	DeleteSprite(_SceneInGameUpperScreenBackgroundSpriteId)
	_SceneInGameUpperScreenBackgroundSpriteId = 0
	DeleteSprite(_SceneInGameUpperScreenDifficultySpriteId)
	_SceneInGameUpperScreenDifficultySpriteId = 0
	DeleteSprite(_SceneInGameUpperScreenLevelSpriteId)
	_SceneInGameUpperScreenLevelSpriteId = 0
	DeleteText(_SceneInGameUpperScreenTitleTextId)
	_SceneInGameUpperScreenTitleTextId = 0
	DeleteText(_SceneInGameUpperScreenArtistTextId)
	_SceneInGameUpperScreenArtistTextId = 0
	DeleteText(_SceneInGameUpperScreenBpmTextId)
	_SceneInGameUpperScreenBpmTextId = 0
	DeleteText(_SceneInGameUpperScreenNotesTextId)
	_SceneInGameUpperScreenNotesTextId = 0
	DeleteText(_SceneInGameUpperScreenMusicLength1TextId)
	_SceneInGameUpperScreenMusicLength1TextId = 0
	DeleteText(_SceneInGameUpperScreenMusicLength2TextId)
	_SceneInGameUpperScreenMusicLength2TextId = 0
	DeleteSpritesInArray(_SceneInGameUpperScreenScoreDigitSpriteIds)
	DeleteImage(_SceneInGameUpperScreenCoverImageId)
	_SceneInGameUpperScreenCoverImageId = 0
	DeleteSprite(_SceneInGameUpperScreenCoverSpriteId)
	_SceneInGameUpperScreenCoverSpriteId = 0
	DeleteSpritesInArray(_SceneInGameUpperScreenMusicBarDotSpriteIds)
	DeleteSprite(_SceneInGameUpperScreenMusicBarBarSpriteId)
	_SceneInGameUpperScreenMusicBarBarSpriteId = 0
	DeleteSprite(_SceneInGameUpperScreenNewRecordSpriteId)
	_SceneInGameUpperScreenNewRecordSpriteId = 0
	_SceneInGameUpperScreenIsNewRecord = 0
	_SceneInGameCompletlyJudgedMusicBarIndex = 0
	_SceneInGameScore = 0
	_SceneInGameBonusScore = 0
	_SceneInGamePerfectCount = 0
	_SceneInGameGreatCount = 0
	_SceneInGameGoodCount = 0
	_SceneInGameBadCount = 0
	_SceneInGameMissCount = 0
	_SceneInGameBonusCount = 0
	_SceneInGamePrevComboCount = 0
	_SceneInGameComboCount = 0
	_SceneInGameComboChangedTime = 0.0
	_SceneInGameResultTime = 0.0
	DeleteSprite(_SceneInGameResultFullComboSpriteId)
	_SceneInGameResultFullComboSpriteId = 0
	DeleteSprite(_SceneInGameResultFullComboBackFadeSpriteId)
	_SceneInGameResultFullComboBackFadeSpriteId = 0
	DeleteSprite(_SceneInGameResultClearedBigSpriteId)
	_SceneInGameResultClearedBigSpriteId = 0
	DeleteSpritesInArray(_SceneInGameResultClearedSmallSpriteIds)
	DeleteSprite(_SceneInGameResultClearedBackFadeSpriteId)
	_SceneInGameResultClearedBackFadeSpriteId = 0
	DeleteSprite(_SceneInGameResultRatingTextSpriteId)
	_SceneInGameResultRatingTextSpriteId = 0
	DeleteSprite(_SceneInGameResultRatingCharSpriteId)
	_SceneInGameResultRatingCharSpriteId = 0
	DeleteSprite(_SceneInGameResultNextSpriteButtonId)
	_SceneInGameResultNextSpriteButtonId = 0
	DeleteSprite(_SceneInGameResultRetrySpriteButtonId)
	_SceneInGameResultRetrySpriteButtonId = 0
	If _SceneInGameMarkerImage > 0 Then DeleteImage(_SceneInGameMarkerImage)
	_SceneInGameMarkerImage = 0
	If _SceneInGameMarkerHighlightImage > 0 Then DeleteImage(_SceneInGameMarkerHighlightImage)
	_SceneInGameMarkerHighlightImage = 0
	For i = 0 To 4 Step 1
		If _SceneInGameJudgementEffectImages[i] > 0 Then DeleteImage(_SceneInGameJudgementEffectImages[i])
		_SceneInGameJudgementEffectImages[i] = 0
	Next i
	While _SceneInGameMarkers.Length >= 0
		DeleteSprite(_SceneInGameMarkers[_SceneInGameMarkers.Length].SpriteId)
		_SceneInGameMarkers.Remove()
	EndWhile
	While _SceneInGameArrows.Length >= 0
		DeleteSprite(_SceneInGameArrows[0].ArrowSpriteId)
		DeleteSprite(_SceneInGameArrows[0].ArrowGlowSpriteId)
		DeleteSprite(_SceneInGameArrows[0].ButtonGlowSpriteId)
		DeleteSprite(_SceneInGameArrows[0].LaserSpriteId)
		DeleteSprite(_SceneInGameArrows[0].ArrowBorderSpriteId)
		_SceneInGameArrows.Remove(0)
	EndWhile
	
	
	DeleteSprite(_SceneInGamePreparingReadySpriteId)
	_SceneInGamePreparingReadySpriteId = 0
	DeleteSprite(_SceneInGamePreparingGoSpriteId)
	_SceneInGamePreparingGoSpriteId = 0
	DeleteSpritesInArray(_SceneInGameJudgementEffectSprites)
	While _SceneInGameJudgementEffectPlayingTimes.Length >= 0
		_SceneInGameJudgementEffectPlayingTimes.Remove()
	EndWhile
	DeleteSpritesInArray(_SceneInGamePreparingStartHereSpriteIds)
EndFunction
