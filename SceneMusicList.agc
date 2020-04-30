#include "Constants.agc"
#include "ThemeLoader.agc"
#include "SpriteButton.agc"
#include "GridDrawing.agc"
#include "MusicLibrary.agc"
#include "Localizing.agc"
#include "ScreenFading.agc"

// Public properties
Global SceneMusicListSelectedMemoFile As String
Global SceneMusicListSelectedMemoSha256String As String

// Scene
Global _SceneMusicListLooping As Integer = 0
Global _SceneMusicListLifeTime As Float

// State
#constant _SceneMusicListStateNone (0)
#constant _SceneMusicListStateList (1)
#constant _SceneMusicListStatePlayMusic (2)
#constant _SceneMusicListStateBell (3)
#constant _SceneMusicListStateSettings (4)
Global _SceneMusicListState As Integer

// Back image
Global _SceneMusicListUpperBackSpriteId As Integer
Global _SceneMusicListUpperBackEmptySpriteId As Integer
Global _SceneMusicListUpperBackEmptyAlphaFactor As Float
Global _SceneMusicListLowerBackSpriteId As Integer
Global _SceneMusicListLowerBackEmptySpriteId As Integer
Global _SceneMusicListLowerBackEmptyAlphaFactor As Float

// Sprite buttons
Global _SceneMusicListLeftSpriteButtonId As Integer
Global _SceneMusicListRightSpriteButtonId As Integer
Global _SceneMusicListBellSpriteButtonId As Integer
Global _SceneMusicListNextSpriteButtonId As Integer
Global _SceneMusicListBlockButton As Integer

// Music List
Global _SceneMusicListMusicLibraryList As MusicLibraryItem[]
Global _SceneMusicListMusicLibrarySortedIndexes As Integer[]
Type _SceneMusicListDifficultyRatingItem
	None As Integer
	Basic As Integer
	Advanced As Integer
	Extreme As Integer
EndType
Global _SceneMusicListLibraryDifficultyRatings As _SceneMusicListDifficultyRatingItem[]  //0none 1notplayed 2e 3d 4c 5b 6a 7s 8ss 9sss 10exc
Type _SceneMusicListMusicButtonItem
	ColumnOnScreen As Float
	LibraryIndex As Integer
	TitleTextId As Integer
	CoverSpriteId As Integer
	CoverDefaultSpriteId As Integer
	LevelSpriteId As Integer
	DifficultyRatingIconSpriteIds As Integer[3] //0non 1bsc 2adv 3ext
	HoldSpriteId As Integer
EndType
Global _SceneMusicListMusicButtonList As _SceneMusicListMusicButtonItem[]
Global _SceneMusicListSpinningDiskSpriteId As Integer  //0non 1bsc 2adv 3ext
Global _SceneMusicListCurrentCol As Integer
Global _SceneMusicListSelectedLibraryIndex As Integer
Global _SceneMusicListPrevSelectedLibraryIndex As Integer
Global _SceneMusicListCurrentDifficulty As Integer = 1 //0non 1bsc 2adv 3ext
Global _SceneMusicListSelectedDifficulty As Integer  //0non 1bsc 2adv 3ext
Global _SceneMusicListPrevSelectedDifficulty As Integer  //0non 1bsc 2adv 3ext
Global _SceneMusicListPrelisteningMusicId As Integer
Global _SceneMusicListPrelisteningMusicVolumeFactor As Float
Global _SceneMusicListPrelisteningMusicMuteTime As Float

// Upper screen
Global _SceneMusicListUpperScreenCoverSpriteId As Integer
Global _SceneMusicListUpperScreenTitleTextId As Integer
Global _SceneMusicListUpperScreenArtistTextId As Integer
Global _SceneMusicListUpperScreenBpmTextId As Integer
Global _SceneMusicListUpperScreenNotesTextId As Integer
Global _SceneMusicListUpperScreenLastplayedTextId As Integer
Global _SceneMusicListUpperScreenHighScoreTimeTextId As Integer
Global _SceneMusicListUpperScreenMusicLengthTextId As Integer
Global _SceneMusicListUpperScreenDifficultySpriteId As Integer
Global _SceneMusicListUpperScreenLevelSpriteId As Integer
Global _SceneMusicListUpperScreenHighScoreDigitSpriteIds As Integer[]
Global _SceneMusicListUpperScreenRatingSpriteId As Integer
Global _SceneMusicListUpperScreenFullComboSpriteId As Integer
Global _SceneMusicListUpperScreenMusicBarDotSpriteIds As Integer[]
Global _SceneMusicListUpperScreenMusicBarStartX As Float
Global _SceneMusicListUpperScreenMusicBarEndX As Float
Global _SceneMusicListUpperScreenMusicBarY As Float

// For anim
Global _SceneMusicListMusicButtonsCreatedTime As Float
Global _SceneMusicListMusicButtonsSelectedTime As Float

// Cover cache
Type _SceneMusicListCoverCacheItem
	Name As String
	ImageId As Integer
	AddedTime As Float
EndType
Global _SceneMusicListCoverCache As _SceneMusicListCoverCacheItem[]

// Bell
Global _SceneMusicListMarkerLeftSpriteButtonId As Integer
Global _SceneMusicListMarkerRightSpriteButtonId As Integer
Global _SceneMusicListSortingLeftSpriteButtonId As Integer
Global _SceneMusicListSortingRightSpriteButtonId As Integer
Global _SceneMusicListBellBackSpriteButtonId As Integer
Global _SceneMusicListBellSettingsSpriteButtonId As Integer
Global _SceneMusicListBellToggleButtonsFactor As Float
Global _SceneMusicListSortButtonAnimProgress As Float
Global _SceneMusicListSortButtonSpriteId As Integer
Global _SceneMusicListSortButtonTextId As Integer
Global _SceneMusicListAutoPlayToggleSpriteId As Integer
Global _SceneMusicListAutoPlayToggleTextId As Integer
Global _SceneMusicListAutoPlayToggleAnimProgress As Float
Global _SceneMusicListClapSoundToggleSpriteId As Integer
Global _SceneMusicListClapSoundToggleTextId As Integer
Global _SceneMusicListClapSoundToggleAnimProgress As Float
Global _SceneMusicListSimpleEffectToggleSpriteId As Integer
Global _SceneMusicListSimpleEffectToggleTextId As Integer
Global _SceneMusicListSimpleEffectToggleAnimProgress As Float
Global _SceneMusicListHighlightHoldMarkerToggleSpriteId As Integer
Global _SceneMusicListHighlightHoldMarkerToggleTextId As Integer
Global _SceneMusicListHighlightHoldMarkerToggleAnimProgress As Float
Global _SceneMusicListMarkerFolders As String[]
Global _SceneMusicListMarkerCurIdx As Integer
Global _SceneMusicListMarkerSpriteId As Integer
Global _SceneMusicListMarkerBackSpriteId As Integer
Global _SceneMusicListMarkerEffectSpriteId As Integer
Global _SceneMusicListMarkerEffectPlayedTime As Float
Global _SceneMusicListMarkerPlayedTime As Float
Global _SceneMusicListMarkerImageIds As Integer[]

// NoteTimingOffsets
Global _SceneMusicListNTOSpriteId As Integer
Global _SceneMusicListNTOTextId As Integer
Global _SceneMusicListNTOBackColor As Integer

// Main looping
Function SceneMusicListLoop()
	result = SceneResultContinue
	inc _SceneMusicListLifeTime, GetFrameTime()
	
	If Not _SceneMusicListLooping
		_SceneMusicListLooping = 1
		_SceneMusicListState = _SceneMusicListStateList
		_SceneMusicListLifeTime = 0.0
		
		SetMusicFileVolume(GetThemeMusic("bgm_musiclist"), GetSettingsMusicVolume())
		PlayMusic(GetThemeMusic("bgm_musiclist"), 1)
		PlaySound(GetThemeSound("snd_voice_selectmusic"))
		
		_SceneMusicListDeleteResourcesAndInitializeVars()
		
//		SetSyncRate(30, 0)
		
		StartScreenFadeIn()
		/*
		_SceneMusicListSelectedLibraryIndex = -1
		_SceneMusicListPrevSelectedLibraryIndex = -1
		_SceneMusicListCurrentDifficulty = 0
		_SceneMusicListSelectedDifficulty = 0
		_SceneMusicListPrevSelectedDifficulty = 0
		_SceneMusicListPrelisteningMusicId = 0
		*/
		
		// NTO
		_SceneMusicListNTOTextId = CreateText("TEST 10ms")
		SetTextPosition(_SceneMusicListNTOTextId, GetUpperScreenX() + GetUpperScreenWidth() * 0.5, GetUpperScreenY() + GetUpperScreenHeight() * 0.1)
		SetTextAlignment(_SceneMusicListNTOTextId, 1)
		SetTextSize(_SceneMusicListNTOTextId, GetUpperScreenWidth() * 0.05 * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListNTOTextId, GetTextSize(_SceneMusicListNTOTextId) * GetLanguageFontLineSpacing())
		SetTextVisible(_SceneMusicListNTOTextId, 0)
		SetTextDepth(_SceneMusicListNTOTextId, DEPTH_FPS)
		If _SceneMusicListNTOBackColor = 0 Then _SceneMusicListNTOBackColor = CreateImageColor(0, 0, 0, 63)
		_SceneMusicListNTOSpriteId = CreateSprite(_SceneMusicListNTOBackColor)
		SetSpriteVisible(_SceneMusicListNTOSpriteId, 0)
		SetSpriteDepth(_SceneMusicListNTOSpriteId, DEPTH_FPS_BACK)
		
		// create basic buttons
		_SceneMusicListLeftSpriteButtonId = CreateSpriteButton(13, SpriteButtonTypeLeft)
		_SceneMusicListRightSpriteButtonId = CreateSpriteButton(14, SpriteButtonTypeRight)
		_SceneMusicListBellSpriteButtonId = CreateSpriteButton(15, SpriteButtonTypeBell)
		_SceneMusicListNextSpriteButtonId = CreateSpriteButton(16, SpriteButtonTypeNext)
		
		// create backgrounds
		_SceneMusicListUpperBackSpriteId = CreateSprite(GetThemeImage("musiclistscreen_back"))
		SetSpritePosition(_SceneMusicListUpperBackSpriteId, GetUpperScreenX(), GetUpperScreenY())
		SetSpriteSize(_SceneMusicListUpperBackSpriteId, GetUpperScreenWidth(), GetUpperScreenHeight())
		SetSpriteDepth(_SceneMusicListUpperBackSpriteId, DEPTH_MUSICLISTSCREEN_BACK)
		SetSpriteTransparency(_SceneMusicListUpperBackSpriteId, 0)
		_SceneMusicListUpperBackEmptySpriteId = CreateSprite(GetThemeImage("musiclistscreen_back_empty"))
		SetSpritePosition(_SceneMusicListUpperBackEmptySpriteId, GetUpperScreenX(), GetUpperScreenY())
		SetSpriteSize(_SceneMusicListUpperBackEmptySpriteId, GetUpperScreenWidth(), GetUpperScreenHeight())
		SetSpriteDepth(_SceneMusicListUpperBackEmptySpriteId, DEPTH_MUSICLISTSCREEN_BACK_EMPTY)
		_SceneMusicListUpperBackEmptyAlphaFactor = 1.0
		//SetSpriteTransparency(_SceneMusicListUpperBackEmptySpriteId, 0)
		_SceneMusicListLowerBackSpriteId = CreateSprite(GetThemeImage("musiclist_back"))
		SetSpritePosition(_SceneMusicListLowerBackSpriteId, GetLowerScreenX(), GetLowerScreenY())
		SetSpriteSize(_SceneMusicListLowerBackSpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
		SetSpriteDepth(_SceneMusicListLowerBackSpriteId, DEPTH_MUSICLIST_BACK)
		SetSpriteTransparency(_SceneMusicListLowerBackSpriteId, 0)
		_SceneMusicListLowerBackEmptySpriteId = CreateSprite(GetThemeImage("musiclist_back"))
		SetSpritePosition(_SceneMusicListLowerBackEmptySpriteId, GetLowerScreenX(), GetLowerScreenY())
		SetSpriteSize(_SceneMusicListLowerBackEmptySpriteId, GetLowerScreenWidth(), GetLowerScreenHeight())
		SetSpriteDepth(_SceneMusicListLowerBackEmptySpriteId, DEPTH_MUSICLIST_BACK_EMPTY)
		SetSpriteColorAlpha(_SceneMusicListLowerBackEmptySpriteId, 0)
		
		// flush cache
		_SceneMusicListFlushCoverCache()
		
		// create disk
		diskImage = GetThemeImage("musiclist_spinning_disk")
		_SceneMusicListSpinningDiskSpriteId = CreateSprite(diskImage)
		SetSpriteAnimation(_SceneMusicListSpinningDiskSpriteId, GetImageWidth(diskImage) / 2, GetImageHeight(diskImage) / 2, 4)
		SetSpriteSize(_SceneMusicListSpinningDiskSpriteId, GetJButtonSize() * GetThemeValue("mll_disk_width"),GetJButtonSize() * GetThemeValue("mll_disk_height"))
		SetSpriteDepth(_SceneMusicListSpinningDiskSpriteId, DEPTH_MUSICLIST_MUSICBUTTON_DISK)
		
		// create music buttons
		_SceneMusicListCreateMusicButtons()
		_SceneMusicListCurrentCol = 0
		_SceneMusicListUpdateMusicButtonsPosition(0)
		
		// create upper screen
		_SceneMusicListUpperScreenCoverSpriteId = CreateSprite(0)
		SetSpritePosition(_SceneMusicListUpperScreenCoverSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_cover_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_cover_y"))
		SetSpriteSize(_SceneMusicListUpperScreenCoverSpriteId, GetUpperScreenWidth() * GetThemeValue("mlu_cover_width"), GetUpperScreenHeight() * GetThemeValue("mlu_cover_height"))
		SetSpriteDepth(_SceneMusicListUpperScreenCoverSpriteId, DEPTH_MUSICLISTSCREEN_TEXTS)
		
		_SceneMusicListUpperScreenTitleTextId = CreateText("")
		SetTextPosition(_SceneMusicListUpperScreenTitleTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_title_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_title_y"))
		SetTextSize(_SceneMusicListUpperScreenTitleTextId, GetUpperScreenWidth() * GetThemeValue("mlu_title_size") * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListUpperScreenTitleTextId, GetTextSize(_SceneMusicListUpperScreenTitleTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(_SceneMusicListUpperScreenTitleTextId, GetUpperScreenWidth() * GetThemeValue("mlu_title_maxwidth"))
		color As ThemeColor
		color = GetThemeColor("mlu_title_color")
		SetTextColor(_SceneMusicListUpperScreenTitleTextId, color.Red, color.Green, color.Blue, 255)
		SetTextAlignment(_SceneMusicListUpperScreenTitleTextId, GetThemeValue("mlu_title_align"))
		SetTextDepth(_SceneMusicListUpperScreenTitleTextId, DEPTH_MUSICLISTSCREEN_TEXTS)
		If GetLanguageBoldFont() <> 0
			SetTextFont(_SceneMusicListUpperScreenTitleTextId, GetLanguageBoldFont())
		Else
			SetTextFont(_SceneMusicListUpperScreenTitleTextId, GetLanguageFont())
			SetTextBold(_SceneMusicListUpperScreenTitleTextId, 1)
		EndIf
		
		_SceneMusicListUpperScreenArtistTextId = CreateText("")
		SetTextPosition(_SceneMusicListUpperScreenArtistTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_artist_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_artist_y"))
		SetTextSize(_SceneMusicListUpperScreenArtistTextId, GetUpperScreenWidth() * GetThemeValue("mlu_artist_size") * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListUpperScreenArtistTextId, GetTextSize(_SceneMusicListUpperScreenArtistTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(_SceneMusicListUpperScreenArtistTextId, GetUpperScreenWidth() * GetThemeValue("mlu_artist_maxwidth"))
		color = GetThemeColor("mlu_artist_color")
		SetTextColor(_SceneMusicListUpperScreenArtistTextId, color.Red, color.Green, color.Blue, 255)
		SetTextAlignment(_SceneMusicListUpperScreenArtistTextId, GetThemeValue("mlu_artist_align"))
		SetTextDepth(_SceneMusicListUpperScreenArtistTextId, DEPTH_MUSICLISTSCREEN_TEXTS)
		SetTextFont(_SceneMusicListUpperScreenArtistTextId, GetLanguageFont())
		
		_SceneMusicListUpperScreenBpmTextId = CreateText("")
		SetTextPosition(_SceneMusicListUpperScreenBpmTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_bpm_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_bpm_y"))
		SetTextSize(_SceneMusicListUpperScreenBpmTextId, GetUpperScreenWidth() * GetThemeValue("mlu_bpm_size") * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListUpperScreenBpmTextId, GetTextSize(_SceneMusicListUpperScreenBpmTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(_SceneMusicListUpperScreenBpmTextId, GetUpperScreenWidth() * GetThemeValue("mlu_bpm_maxwidth"))
		color = GetThemeColor("mlu_bpm_color")
		SetTextColor(_SceneMusicListUpperScreenBpmTextId, color.Red, color.Green, color.Blue, 255)
		SetTextAlignment(_SceneMusicListUpperScreenBpmTextId, GetThemeValue("mlu_bpm_align"))
		SetTextDepth(_SceneMusicListUpperScreenBpmTextId, DEPTH_MUSICLISTSCREEN_TEXTS)
		SetTextFont(_SceneMusicListUpperScreenBpmTextId, GetLanguageFont())
		
		_SceneMusicListUpperScreenNotesTextId = CreateText("")
		SetTextPosition(_SceneMusicListUpperScreenNotesTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_notes_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_notes_y"))
		SetTextSize(_SceneMusicListUpperScreenNotesTextId, GetUpperScreenWidth() * GetThemeValue("mlu_notes_size") * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListUpperScreenNotesTextId, GetTextSize(_SceneMusicListUpperScreenNotesTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(_SceneMusicListUpperScreenNotesTextId, GetUpperScreenWidth() * GetThemeValue("mlu_notes_maxwidth"))
		color = GetThemeColor("mlu_notes_color")
		SetTextColor(_SceneMusicListUpperScreenNotesTextId, color.Red, color.Green, color.Blue, 255)
		SetTextAlignment(_SceneMusicListUpperScreenNotesTextId, GetThemeValue("mlu_notes_align"))
		SetTextDepth(_SceneMusicListUpperScreenNotesTextId, DEPTH_MUSICLISTSCREEN_TEXTS)
		SetTextFont(_SceneMusicListUpperScreenNotesTextId, GetLanguageFont())
		
		_SceneMusicListUpperScreenLastplayedTextId = CreateText("")
		SetTextPosition(_SceneMusicListUpperScreenLastplayedTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_lastplayed_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_lastplayed_y"))
		SetTextSize(_SceneMusicListUpperScreenLastplayedTextId, GetUpperScreenWidth() * GetThemeValue("mlu_lastplayed_size") * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListUpperScreenLastplayedTextId, GetTextSize(_SceneMusicListUpperScreenLastplayedTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(_SceneMusicListUpperScreenLastplayedTextId, GetUpperScreenWidth() * GetThemeValue("mlu_lastplayed_maxwidth"))
		color = GetThemeColor("mlu_lastplayed_color")
		SetTextColor(_SceneMusicListUpperScreenLastplayedTextId, color.Red, color.Green, color.Blue, 255)
		SetTextAlignment(_SceneMusicListUpperScreenLastplayedTextId, GetThemeValue("mlu_lastplayed_align"))
		SetTextDepth(_SceneMusicListUpperScreenLastplayedTextId, DEPTH_MUSICLISTSCREEN_TEXTS)
		SetTextFont(_SceneMusicListUpperScreenLastplayedTextId, GetLanguageFont())
		
		_SceneMusicListUpperScreenHighScoreTimeTextId = CreateText("")
		SetTextPosition(_SceneMusicListUpperScreenHighScoreTimeTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_highscoretime_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_highscoretime_y"))
		SetTextSize(_SceneMusicListUpperScreenHighScoreTimeTextId, GetUpperScreenWidth() * GetThemeValue("mlu_highscoretime_size") * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListUpperScreenHighScoreTimeTextId, GetTextSize(_SceneMusicListUpperScreenHighScoreTimeTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(_SceneMusicListUpperScreenHighScoreTimeTextId, GetUpperScreenWidth() * GetThemeValue("mlu_highscoretime_maxwidth"))
		color = GetThemeColor("mlu_highscoretime_color")
		SetTextColor(_SceneMusicListUpperScreenHighScoreTimeTextId, color.Red, color.Green, color.Blue, 255)
		SetTextAlignment(_SceneMusicListUpperScreenHighScoreTimeTextId, GetThemeValue("mlu_highscoretime_align"))
		SetTextDepth(_SceneMusicListUpperScreenHighScoreTimeTextId, DEPTH_MUSICLISTSCREEN_TEXTS)
		SetTextFont(_SceneMusicListUpperScreenHighScoreTimeTextId, GetLanguageFont())
		
		_SceneMusicListUpperScreenMusicLengthTextId = CreateText("")
		SetTextPosition(_SceneMusicListUpperScreenMusicLengthTextId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_musiclength_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_musiclength_y"))
		SetTextSize(_SceneMusicListUpperScreenMusicLengthTextId, GetUpperScreenWidth() * GetThemeValue("mlu_musiclength_size") * GetLanguageFontScale())
		SetTextLineSpacing(_SceneMusicListUpperScreenMusicLengthTextId, GetTextSize(_SceneMusicListUpperScreenMusicLengthTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(_SceneMusicListUpperScreenMusicLengthTextId, GetUpperScreenWidth() * GetThemeValue("mlu_musiclength_maxwidth"))
		color = GetThemeColor("mlu_musiclength_color")
		SetTextColor(_SceneMusicListUpperScreenMusicLengthTextId, color.Red, color.Green, color.Blue, 255)
		SetTextAlignment(_SceneMusicListUpperScreenMusicLengthTextId, GetThemeValue("mlu_musiclength_align"))
		SetTextDepth(_SceneMusicListUpperScreenMusicLengthTextId, DEPTH_MUSICLISTSCREEN_TEXTS)
		SetTextFont(_SceneMusicListUpperScreenMusicLengthTextId, GetLanguageFont())
		
		_SceneMusicListUpperScreenDifficultySpriteId = CreateSprite(GetThemeImage("musiclistscreen_dif"))
		SetSpriteAnimation(_SceneMusicListUpperScreenDifficultySpriteId, GetImageWidth(GetThemeImage("musiclistscreen_dif")), GetImageHeight(GetThemeImage("musiclistscreen_dif")) / 3, 3)
		SetSpritePosition(_SceneMusicListUpperScreenDifficultySpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_dif_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_dif_y"))
		SetSpriteSize(_SceneMusicListUpperScreenDifficultySpriteId, GetUpperScreenWidth() * GetThemeValue("mlu_dif_width"), GetUpperScreenHeight() * GetThemeValue("mlu_dif_height"))
		SetSpriteDepth(_SceneMusicListUpperScreenDifficultySpriteId, DEPTH_MUSICLISTSCREEN_TEXTS)
		
		_SceneMusicListUpperScreenLevelSpriteId = CreateSprite(GetThemeImage("musiclistscreen_lv"))
		SetSpriteAnimation(_SceneMusicListUpperScreenLevelSpriteId, GetImageWidth(GetThemeImage("musiclistscreen_lv")) / 5, GetImageHeight(GetThemeImage("musiclistscreen_lv")) / 2, 10)
		SetSpritePosition(_SceneMusicListUpperScreenLevelSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_lv_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_lv_y"))
		SetSpriteSize(_SceneMusicListUpperScreenLevelSpriteId, GetUpperScreenWidth() * GetThemeValue("mlu_lv_width"), GetUpperScreenHeight() * GetThemeValue("mlu_lv_height"))
		SetSpriteDepth(_SceneMusicListUpperScreenLevelSpriteId, DEPTH_MUSICLISTSCREEN_TEXTS)
		
		_SceneMusicListUpperScreenFullComboSpriteId = CreateSprite(GetThemeImage("musiclistscreen_fullcombo"))
		SetSpritePosition(_SceneMusicListUpperScreenFullComboSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_fullcombo_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_fullcombo_y"))
		SetSpriteSize(_SceneMusicListUpperScreenFullComboSpriteId, GetUpperScreenWidth() * GetThemeValue("mlu_fullcombo_width"), GetUpperScreenHeight() * GetThemeValue("mlu_fullcombo_height"))
		SetSpriteDepth(_SceneMusicListUpperScreenFullComboSpriteId, DEPTH_MUSICLISTSCREEN_TEXTS)
//_SceneMusicListUpperScreenHighScoreDigitSpriteIds

		scoreNumImage = GetThemeImage("musiclistscreen_score")
		_SceneMusicListUpperScreenHighScoreDigitSpriteIds.Insert(CreateSprite(scoreNumImage))
		SetSpriteSize(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[0], GetUpperScreenWidth() * GetThemeValue("mlu_highscore_width"), GetUpperScreenHeight() * GetThemeValue("mlu_highscore_height")) 
		SetSpriteAnimation(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[0], GetImageWidth(scoreNumImage) / 5, GetImageHeight(scoreNumImage) / 2, 10)
		SetSpriteDepth(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[0], DEPTH_MUSICLISTSCREEN_TEXTS)
		SetSpriteFrame(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[0], 1)
		SetSpritePosition(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[0], GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_highscore_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_highscore_y"))
		For i = 1 To 6
			spriteId = CloneSprite(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[_SceneMusicListUpperScreenHighScoreDigitSpriteIds.Length])
			SetSpriteX(spriteId, GetSpriteX(spriteId) - GetSpriteWidth(spriteId) * (1.0 + GetThemeValue("mlu_highscore_spacing")))
			SetSpriteVisible(spriteId, 0)
			_SceneMusicListUpperScreenHighScoreDigitSpriteIds.Insert(spriteId)
		Next i
		
		_SceneMusicListUpperScreenRatingSpriteId = CreateSprite(GetThemeImage("musiclistscreen_rating"))
		SetSpriteAnimation(_SceneMusicListUpperScreenRatingSpriteId, GetImageWidth(GetThemeImage("musiclistscreen_rating")) / 5, GetImageHeight(GetThemeImage("musiclistscreen_rating")) / 2, 10)
		SetSpritePosition(_SceneMusicListUpperScreenRatingSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_rating_x"), GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_rating_y"))
		SetSpriteSize(_SceneMusicListUpperScreenRatingSpriteId, GetUpperScreenWidth() * GetThemeValue("mlu_rating_width"), GetUpperScreenHeight() * GetThemeValue("mlu_rating_height"))
		SetSpriteDepth(_SceneMusicListUpperScreenRatingSpriteId, DEPTH_MUSICLISTSCREEN_TEXTS)
		SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 1)

		musicBarImage = GetThemeImage("music_bar")
		_SceneMusicListUpperScreenMusicBarStartX = GetUpperScreenX() + GetUpperScreenWidth() * GetThemeValue("mlu_mbar_x")
		_SceneMusicListUpperScreenMusicBarEndX = _SceneMusicListUpperScreenMusicBarStartX + GetUpperScreenWidth() * GetThemeValue("mlu_mbar_width") //musicBarDotWidth# * 120.0
		_SceneMusicListUpperScreenMusicBarY = GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_mbar_y")
		musicBarDotWidth# = GetUpperScreenWidth() * GetThemeValue("mlu_mbar_width") / 120.0
		For i = 0 To 119
			musicBarDot = CreateSprite(musicBarImage)
			SetSpriteAnimation(musicBarDot, GetImageWidth(musicBarImage) * 0.125, GetImageHeight(musicBarImage), 8)
			SetSpriteSize(musicBarDot, musicBarDotWidth#, musicBarDotWidth# * 8)
			SetSpriteX(musicBarDot, _SceneMusicListUpperScreenMusicBarStartX + GetSpriteWidth(musicBarDot) * i)
			SetSpriteDepth(musicBarDot, DEPTH_MUSICLISTSCREEN_MUSIC_BAR_DOT)
			SetSpriteVisible(musicBarDot, 0)
			
			_SceneMusicListUpperScreenMusicBarDotSpriteIds.Insert(musicBarDot)
		Next
	EndIf
	
	Select _SceneMusicListState
		Case _SceneMusicListStateList:
			// back empty
			If _SceneMusicListSelectedLibraryIndex >= 0
				dec _SceneMusicListUpperBackEmptyAlphaFactor, GetFrameTime() * 2
				If _SceneMusicListUpperBackEmptyAlphaFactor < 0.0 Then _SceneMusicListUpperBackEmptyAlphaFactor = 0.0
			Else
				inc _SceneMusicListUpperBackEmptyAlphaFactor, GetFrameTime() * 2
				If _SceneMusicListUpperBackEmptyAlphaFactor > 1.0 Then _SceneMusicListUpperBackEmptyAlphaFactor = 1.0
			EndIf
			SetSpriteColorAlpha(_SceneMusicListUpperBackEmptySpriteId, _SceneMusicListUpperBackEmptyAlphaFactor * 255)
			
			// Control music
			_SceneMusicListPrelisteningMusicMuteTime = MaxF(0.0, _SceneMusicListPrelisteningMusicMuteTime - GetFrameTime())
			If _SceneMusicListPrelisteningMusicMuteTime = 0.0 And _SceneMusicListPrelisteningMusicId > 0 Then SetMusicFileVolume(_SceneMusicListPrelisteningMusicId, GetSettingsMusicVolume())
			If _SceneMusicListPrelisteningMusicId > 0 And Not GetMusicPlaying()
				DeleteMusic(_SceneMusicListPrelisteningMusicId)
				SetMusicFileVolume(GetThemeMusic("bgm_musiclist"), GetSettingsMusicVolume())
				PlayMusic(GetThemeMusic("bgm_musiclist"))
			EndIf
			
			// input buttons and process music buttons
			
			If Not _SceneMusicListBlockButton
				If GetSpriteButtonPressed(_SceneMusicListLeftSpriteButtonId) And Not GetJButtonPressing(0)
					If _SceneMusicListCurrentCol < _SceneMusicListMusicLibraryList.Length / 3
						inc _SceneMusicListCurrentCol
					EndIf
				ElseIf GetSpriteButtonPressed(_SceneMusicListRightSpriteButtonId) And Not GetJButtonPressing(0)
					If _SceneMusicListCurrentCol > 0
						dec _SceneMusicListCurrentCol
					EndIf
				Else
					pressedBtnCol = -1
					pressedBtnRow = -1
					For i = 1 To 12
						If GetJButtonPressed(i)
							pressedBtnCol = Mod(i - 1, 4)
							pressedBtnRow = (i - 1) / 4
							Exit
						EndIf
					Next
					If pressedBtnCol >= 0
						newLibIdx = (_SceneMusicListCurrentCol + pressedBtnCol) * 3 + pressedBtnRow
						If 0 <= newLibIdx And newLibIdx <= _SceneMusicListMusicLibraryList.Length
							realLibIdx = _SceneMusicListMusicLibrarySortedIndexes[newLibIdx]
							If newLibIdx <> _SceneMusicListSelectedLibraryIndex
								_SceneMusicListPrevSelectedDifficulty = _SceneMusicListSelectedDifficulty
								_SceneMusicListPrevSelectedLibraryIndex = _SceneMusicListSelectedLibraryIndex
								// pushed new music button
								
								figureOtherDif = 0
								If _SceneMusicListCurrentDifficulty = -1
									figureOtherDif = 1
								ElseIf _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[newLibIdx]].Sha256Strings[_SceneMusicListCurrentDifficulty] = ""
									figureOtherDif = 1
								EndIf
									
								If Not figureOtherDif
									//if pushed music has current difficulty
									_SceneMusicListSelectedDifficulty = _SceneMusicListCurrentDifficulty
								Else
									//if pushed music has not current difficuty. then figure out available difficulty
									If _SceneMusicListCurrentDifficulty < 2
										For i = 0 To 3 Step 1
											If _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[newLibIdx]].Sha256Strings[i] <> ""
												_SceneMusicListSelectedDifficulty = i
												Exit
											EndIf
										Next
									Else
										For i = 3 To 0 Step -1
											If _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[newLibIdx]].Sha256Strings[i] <> ""
												_SceneMusicListSelectedDifficulty = i
												Exit
											EndIf
										Next
									EndIf
									Select _SceneMusicListSelectedDifficulty
										Case 3:
											PlaySound(GetThemeSound("snd_voice_extreme"))
										EndCase
										Case 2:
											PlaySound(GetThemeSound("snd_voice_advanced"))
										EndCase
										Case 1:
											PlaySound(GetThemeSound("snd_voice_basic"))
										EndCase
										Case 0:
											PlaySound(GetThemeSound("snd_voice_normal"))
										EndCase
									EndSelect
									If _SceneMusicListCurrentDifficulty = -1 Then _SceneMusicListCurrentDifficulty = _SceneMusicListSelectedDifficulty
								EndIf
								_SceneMusicListMusicButtonsSelectedTime = Timer()
								// Play music
								If _SceneMusicListPrelisteningMusicId > 0
									StopMusic()
									DeleteMusic(_SceneMusicListPrelisteningMusicId)
									_SceneMusicListPrelisteningMusicId = 0
								EndIf
								_SceneMusicListPrelisteningMusicId = LoadMusic(MUSIC_PATH + _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[newLibIdx]].MusicFile)
								PlayMusic(_SceneMusicListPrelisteningMusicId)
								SetMusicFileVolume(_SceneMusicListPrelisteningMusicId, 0)
								playhead# = _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[newLibIdx]].PreListeningPlayhead
								_SceneMusicListPrelisteningMusicMuteTime = playhead# - Floor(playhead#)
								SeekMusic(Floor(playhead#), 0)
								
								// Set Title Artist BPM Cover
								SetTextString(_SceneMusicListUpperScreenTitleTextId, _SceneMusicListMusicLibraryList[realLibIdx].Title)
								SetTextY(_SceneMusicListUpperScreenTitleTextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_title_y"))
								Select GetThemeValue("mlu_title_valign")
									Case 1.0:
										SetTextY(_SceneMusicListUpperScreenTitleTextId, GetTextY(_SceneMusicListUpperScreenTitleTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenTitleTextId) * 0.5)
									EndCase
									Case 2.0:
										SetTextY(_SceneMusicListUpperScreenTitleTextId, GetTextY(_SceneMusicListUpperScreenTitleTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenTitleTextId))
									EndCase
								EndSelect
								SetTextString(_SceneMusicListUpperScreenArtistTextId, _SceneMusicListMusicLibraryList[realLibIdx].Artist)
								SetTextY(_SceneMusicListUpperScreenArtistTextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_artist_y"))
								Select GetThemeValue("mlu_artist_valign")
									Case 1.0:
										SetTextY(_SceneMusicListUpperScreenArtistTextId, GetTextY(_SceneMusicListUpperScreenArtistTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenArtistTextId) * 0.5)
									EndCase
									Case 2.0:
										SetTextY(_SceneMusicListUpperScreenArtistTextId, GetTextY(_SceneMusicListUpperScreenArtistTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenArtistTextId))
									EndCase
								EndSelect
								SetTextString(_SceneMusicListUpperScreenBpmTextId, _SceneMusicListMusicLibraryList[realLibIdx].Tempo)
								SetTextY(_SceneMusicListUpperScreenBpmTextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_bpm_y"))
								Select GetThemeValue("mlu_bpm_valign")
									Case 1.0:
										SetTextY(_SceneMusicListUpperScreenBpmTextId, GetTextY(_SceneMusicListUpperScreenBpmTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenBpmTextId) * 0.5)
									EndCase
									Case 2.0:
										SetTextY(_SceneMusicListUpperScreenBpmTextId, GetTextY(_SceneMusicListUpperScreenBpmTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenBpmTextId))
									EndCase
								EndSelect
								
								coverImgId = _SceneMusicListGetCoverFromCache(_SceneMusicListMusicLibraryList[realLibIdx].CoverFile)
								If coverImgId > 0
									SetSpriteVisible(_SceneMusicListUpperScreenCoverSpriteId, 1)
									SetSpriteImage(_SceneMusicListUpperScreenCoverSpriteId, coverImgId)
								Else
									SetSpriteVisible(_SceneMusicListUpperScreenCoverSpriteId, 1)
								EndIf
							Else
								// pushed same music button
								//playDifSound = 0
								For i = 1 To 4
									idx = _SceneMusicListSelectedDifficulty + i
									If idx > 3 Then dec idx, 4
									If _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[newLibIdx]].Sha256Strings[idx] <> ""
										_SceneMusicListSelectedDifficulty = idx
										_SceneMusicListCurrentDifficulty = idx
										Exit
									EndIf
								Next
								Select _SceneMusicListCurrentDifficulty
									Case 3:
										PlaySound(GetThemeSound("snd_voice_extreme"))
									EndCase
									Case 2:
										PlaySound(GetThemeSound("snd_voice_advanced"))
									EndCase
									Case 1:
										PlaySound(GetThemeSound("snd_voice_basic"))
									EndCase
									Case 0:
										PlaySound(GetThemeSound("snd_voice_normal"))
									EndCase
								EndSelect
							EndIf
							_SceneMusicListSelectedLibraryIndex = newLibIdx
							
							shaStr$ = _SceneMusicListMusicLibraryList[realLibIdx].Sha256Strings[_SceneMusicListSelectedDifficulty]
							
							//draw musicbar
							musicBarDotWidth# = GetUpperScreenWidth() * GetThemeValue("mlu_mbar_width") / 120.0
							musicBarColors As Integer[]
							musicBarColors = GetMusicRecordsMusicBarColors(shaStr$)
							For i = 0 To 119
								musicBarDot = _SceneMusicListUpperScreenMusicBarDotSpriteIds[i]
								barLevel = _SceneMusicListMusicLibraryList[realLibIdx].MusicBarLevels[_SceneMusicListSelectedDifficulty, i]
								barColor = musicBarColors[i]
								If 0 < barLevel And barLevel <= 8
									SetSpriteFrame(musicBarDot, barColor)
									SetSpriteSize(musicBarDot, musicBarDotWidth#, musicBarDotWidth# * barLevel)
									//SetSpriteX(musicBarDot, _SceneMusicListUpperScreenMusicBarStartX + GetSpriteWidth(musicBarDot) * i)
									SetSpriteY(musicBarDot, _SceneMusicListUpperScreenMusicBarY + GetSpriteWidth(musicBarDot) * (8 - barLevel))
									SetSpriteUVScale(musicBarDot, 1.0, 8.0 / barLevel)
									SetSpriteUVOffset(musicBarDot, 0.0, (8 - barLevel) * 0.125)
									//SetSpriteDepth(musicBarDot, DEPTH_SCREEN_MUSIC_BAR_DOT)
									SetSpriteVisible(musicBarDot, 1)
								Else
									SetSpriteVisible(musicBarDot, 0)
								EndIf
							Next
							While musicBarColors.Length >= 0
								musicBarColors.Remove()
							EndWhile
							
							// Notes Count
							SetTextString(_SceneMusicListUpperScreenNotesTextId, IfString(_SceneMusicListMusicLibraryList[realLibIdx].HoldsCounts[_SceneMusicListSelectedDifficulty], Str(_SceneMusicListMusicLibraryList[realLibIdx].NotesCounts[_SceneMusicListSelectedDifficulty]+_SceneMusicListMusicLibraryList[realLibIdx].HoldsCounts[_SceneMusicListSelectedDifficulty])+"("+Str(_SceneMusicListMusicLibraryList[realLibIdx].HoldsCounts[_SceneMusicListSelectedDifficulty])+")", Str(_SceneMusicListMusicLibraryList[realLibIdx].NotesCounts[_SceneMusicListSelectedDifficulty])))
							SetTextY(_SceneMusicListUpperScreenNotesTextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_notes_y"))
							Select GetThemeValue("mlu_notes_valign")
								Case 1.0:
									SetTextY(_SceneMusicListUpperScreenNotesTextId, GetTextY(_SceneMusicListUpperScreenNotesTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenNotesTextId) * 0.5)
								EndCase
								Case 2.0:
									SetTextY(_SceneMusicListUpperScreenNotesTextId, GetTextY(_SceneMusicListUpperScreenNotesTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenNotesTextId))
								EndCase
							EndSelect
							
							// highscore time
							highscoreText$ = GetLocalizedString("MUSIC_NOT_PLAYED")
							highscoreTime = GetMusicRecordsHighScoredTime(shaStr$)
							If highscoreTime <> 0
								highscoreText$ = GetTimeElapsedString(highscoreTime, GetUnixTime())
							EndIf
							SetTextString(_SceneMusicListUpperScreenHighScoreTimeTextId, highscoreText$)
							SetTextY(_SceneMusicListUpperScreenHighScoreTimeTextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_highscoretime_y"))
							Select GetThemeValue("mlu_highscoretime_valign")
								Case 1.0:
									SetTextY(_SceneMusicListUpperScreenLastplayedTextId, GetTextY(_SceneMusicListUpperScreenLastplayedTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenLastplayedTextId) * 0.5)
								EndCase
								Case 2.0:
									SetTextY(_SceneMusicListUpperScreenLastplayedTextId, GetTextY(_SceneMusicListUpperScreenLastplayedTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenLastplayedTextId))
								EndCase
							EndSelect
							
							// last played time
							lastplayedText$ = GetLocalizedString("MUSIC_NOT_PLAYED")
							lastplayedTime = GetMusicRecordsLastPlayedTime(shaStr$)
							If lastplayedTime <> 0
								lastplayedText$ = GetTimeElapsedString(lastplayedTime, GetUnixTime())
								/*
								lastplayedTime = FixUnixTimeLocalToUtc(lastplayedTime)
								//lastplayedTime =  1500006574//TEST
								lastplayedDate = lastplayedTime - GetHoursFromUnix(lastplayedTime)*3600 - GetMinutesFromUnix(lastplayedTime)*60 - GetSecondsFromUnix(lastplayedTime)
								lastplayedDateWeek = lastplayedDate - GetDayOfWeekFromUnix(lastplayedDate) * 3600 * 24
								todayTime = FixUnixTimeLocalToUtc(GetUnixTime())
								todayDate = todayTime - GetHoursFromUnix(todayTime)*3600 - GetMinutesFromUnix(todayTime)*60 - GetSecondsFromUnix(todayTime)
								todayDateWeek = todayDate - GetDayOfWeekFromUnix(todayDate) * 3600 * 24
								timediff = todayTime - lastplayedTime
								datediff = (todayDate - lastplayedDate) / (3600 * 24)
								weekdiff = (todayDateWeek - lastplayedDateWeek) / (3600 * 24 * 7)
								If GetMonthFromUnix(lastplayedTime) <> GetMonthFromUnix(todayTime) And weekdiff >=  4  // 1 month and 4 weeks
									lastplayedText$ = GetLocalizedString("TIME_YMD")
									lastplayedText$ = ReplaceString(lastplayedText$, "%y", Str(GetYearFromUnix(lastplayedTime)), -1)
									lastplayedText$ = ReplaceString(lastplayedText$, "%m", Str(GetMonthFromUnix(lastplayedTime)), -1)
									lastplayedText$ = ReplaceString(lastplayedText$, "%d", Str(GetDaysFromUnix(lastplayedTime)), -1)
								ElseIf weekdiff >= 2  // 2 weeks
									lastplayedText$ = GetLocalizedString("TIME_W_WEEKS_AGO")
									lastplayedText$ = ReplaceString(lastplayedText$, "%w", Str(weekdiff), -1)
								ElseIf weekdiff = 1 And datediff >= 7 // 1 week and 7 days
									lastplayedText$ = GetLocalizedString("TIME_LAST_WEEK")
								ElseIf datediff >= 2  // 2 days
									lastplayedText$ = GetLocalizedString("TIME_D_DAYS_AGO")
									lastplayedText$ = ReplaceString(lastplayedText$, "%d", Str(datediff), -1)
								ElseIf datediff = 1 //And timediff >= 3600 * 12  // 1 day and 12 hours
									lastplayedText$ = GetLocalizedString("TIME_YESTERDAY")
								ElseIf timediff >= 3600 - 30
									lastplayedText$ = GetLocalizedString("TIME_H_HOURS_AGO")
									lastplayedText$ = ReplaceString(lastplayedText$, "%h", Str(Round(timediff / 1200.0)/3), -1)
								ElseIf timediff >= 30
									lastplayedText$ = GetLocalizedString("TIME_M_MINUTES_AGO")
									lastplayedText$ = ReplaceString(lastplayedText$, "%m", Str(Round(timediff / 60.0)), -1)
								Else
									lastplayedText$ = GetLocalizedString("TIME_MOMENT_AGO")
								EndIf*/
							EndIf
							SetTextString(_SceneMusicListUpperScreenLastplayedTextId, lastplayedText$)
							SetTextY(_SceneMusicListUpperScreenLastplayedTextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_lastplayed_y"))
							Select GetThemeValue("mlu_lastplayed_valign")
								Case 1.0:
									SetTextY(_SceneMusicListUpperScreenLastplayedTextId, GetTextY(_SceneMusicListUpperScreenLastplayedTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenLastplayedTextId) * 0.5)
								EndCase
								Case 2.0:
									SetTextY(_SceneMusicListUpperScreenLastplayedTextId, GetTextY(_SceneMusicListUpperScreenLastplayedTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenLastplayedTextId))
								EndCase
							EndSelect
							
							// difficulty
							If 1 <= _SceneMusicListSelectedDifficulty And _SceneMusicListSelectedDifficulty <= 3
								SetSpriteVisible(_SceneMusicListUpperScreenDifficultySpriteId, 1)
								SetSpriteFrame(_SceneMusicListUpperScreenDifficultySpriteId, _SceneMusicListSelectedDifficulty)
							Else
								SetSpriteVisible(_SceneMusicListUpperScreenDifficultySpriteId, 0)
							EndIf
							
							// level
							level = _SceneMusicListMusicLibraryList[realLibIdx].Levels[_SceneMusicListSelectedDifficulty]
							If 1 <= level And level <= 10
								SetSpriteVisible(_SceneMusicListUpperScreenLevelSpriteId, 1)
								SetSpriteFrame(_SceneMusicListUpperScreenLevelSpriteId, level)
							Else
								SetSpriteVisible(_SceneMusicListUpperScreenLevelSpriteId, 0)
							EndIf
							
							// Length
							musicLength = Round(_SceneMusicListMusicLibraryList[realLibIdx].Lengths[_SceneMusicListSelectedDifficulty])
							musicLengthColon$ = ":"
							If Mod(musicLength, 60) < 10 Then musicLengthColon$ = ":0"
							SetTextString(_SceneMusicListUpperScreenMusicLengthTextId, Str(musicLength / 60) + musicLengthColon$ + Str(Mod(musicLength, 60)))
							SetTextY(_SceneMusicListUpperScreenMusicLengthTextId, GetUpperScreenY() + GetUpperScreenHeight() * GetThemeValue("mlu_musiclength_y"))
							Select GetThemeValue("mlu_musiclength_valign")
								Case 1.0:
									SetTextY(_SceneMusicListUpperScreenMusicLengthTextId, GetTextY(_SceneMusicListUpperScreenMusicLengthTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenMusicLengthTextId) * 0.5)
								EndCase
								Case 2.0:
									SetTextY(_SceneMusicListUpperScreenMusicLengthTextId, GetTextY(_SceneMusicListUpperScreenMusicLengthTextId) - GetTextTotalHeight(_SceneMusicListUpperScreenMusicLengthTextId))
								EndCase
							EndSelect
							
							// fullcombo
							fullcombo = GetMusicRecordsFullCombo(shaStr$)
							If fullcombo
								SetSpriteVisible(_SceneMusicListUpperScreenFullComboSpriteId, 1)
							Else
								SetSpriteVisible(_SceneMusicListUpperScreenFullComboSpriteId, 0)
							EndIf
							
							// highscore
							highscore = GetMusicRecordsHighScore(shaStr$)
							//highscore = 967243//TEST
							If highscore > 0
								scoreCopy = highscore
								For i = 0 To _SceneMusicListUpperScreenHighScoreDigitSpriteIds.Length
									SetSpriteVisible(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[i], 0)
								Next
								scoreIdx = 0
								While scoreCopy > 0
									SetSpriteFrame(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[scoreIdx], Mod(scoreCopy, 10) + 1)
									scoreCopy = scoreCopy / 10
									SetSpriteVisible(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[scoreIdx], 1)
									inc scoreIdx
								EndWhile
								If highscore >= SCORE_EXC
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 10)
								ElseIf highscore >= SCORE_SSS
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 9)
								ElseIf highscore >= SCORE_SS
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 8)
								ElseIf highscore >= SCORE_S
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 7)
								ElseIf highscore >= SCORE_A
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 6)
								ElseIf highscore >= SCORE_B
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 5)
								ElseIf highscore >= SCORE_C
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 4)
								ElseIf highscore >= SCORE_D
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 3)
								Else
									SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 2)
								EndIf
							Else
								SetSpriteVisible(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[0], 1)
								SetSpriteFrame(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[0], 1)
								SetSpriteFrame(_SceneMusicListUpperScreenRatingSpriteId, 1)
								For i = 1 To _SceneMusicListUpperScreenHighScoreDigitSpriteIds.Length
									SetSpriteVisible(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[i], 0)
								Next
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			
			_SceneMusicListUpdateMusicButtonsPosition(_SceneMusicListCurrentCol)
			
			If GetJButtonPressing(0)
				shaStr$ = ""
				If _SceneMusicListSelectedLibraryIndex >= 0 Then shaStr$ = _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[_SceneMusicListSelectedLibraryIndex]].Sha256Strings[_SceneMusicListSelectedDifficulty]
				SetSpriteVisible(_SceneMusicListNTOSpriteId, 1)
				SetTextVisible(_SceneMusicListNTOTextId, 1)
				SetTextString(_SceneMusicListNTOTextId, "Offset " + Str(GetNoteTimingOffset(shaStr$)) + "ms")
				
				SetSpritePosition(_SceneMusicListNTOSpriteId, GetTextX(_SceneMusicListNTOTextId) - GetTextTotalWidth(_SceneMusicListNTOTextId) * 0.5, GetTextY(_SceneMusicListNTOTextId))
				SetSpriteSize(_SceneMusicListNTOSpriteId, GetTextTotalWidth(_SceneMusicListNTOTextId), GetTextTotalHeight(_SceneMusicListNTOTextId))
				If GetSpriteButtonPressed(_SceneMusicListLeftSpriteButtonId)
					SetNoteTimingOffset(shaStr$, MaxI(GetNoteTimingOffset(shaStr$) - 1, -100))
				ElseIf GetSpriteButtonPressed(_SceneMusicListRightSpriteButtonId)
					SetNoteTimingOffset(shaStr$, MinI(GetNoteTimingOffset(shaStr$) + 1, 100))
				ElseIf GetSpriteButtonPressed(_SceneMusicListBellSpriteButtonId)
					SetNoteTimingOffset(shaStr$, MaxI(GetNoteTimingOffset(shaStr$) - 10, -100))
				ElseIf GetSpriteButtonPressed(_SceneMusicListNextSpriteButtonId)
					SetNoteTimingOffset(shaStr$, MinI(GetNoteTimingOffset(shaStr$) + 10, 100))
				EndIf
			Else
				SetSpriteVisible(_SceneMusicListNTOSpriteId, 0)
				SetTextVisible(_SceneMusicListNTOTextId, 0)
				If GetSpriteButtonPressed(_SceneMusicListBellSpriteButtonId)
					WriteNoteTimingOffsetsToFile()
					DismissSpriteButton(_SceneMusicListLeftSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListRightSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListBellSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListNextSpriteButtonId, 1)
					_SceneMusicListPrelisteningMusicVolumeFactor = 1.0
					_SceneMusicListLowerBackEmptyAlphaFactor = 0.0
					_SceneMusicListUpperBackEmptyAlphaFactor = 0.0
					_SceneMusicListState = _SceneMusicListStateBell
					_SceneMusicListBlockButton = 1
				ElseIf GetSpriteButtonPressed(_SceneMusicListNextSpriteButtonId) And _SceneMusicListSelectedLibraryIndex >= 0
					WriteNoteTimingOffsetsToFile()
					StartScreenFadeOut()
					DismissSpriteButton(_SceneMusicListLeftSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListRightSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListBellSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListNextSpriteButtonId, 1)
					_SceneMusicListPrelisteningMusicVolumeFactor = 1.0
					_SceneMusicListLowerBackEmptyAlphaFactor = 0.0
					SceneMusicListSelectedMemoFile = _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[_SceneMusicListSelectedLibraryIndex]].MemoFiles[_SceneMusicListSelectedDifficulty]
					SceneMusicListSelectedMemoSha256String = _SceneMusicListMusicLibraryList[_SceneMusicListMusicLibrarySortedIndexes[_SceneMusicListSelectedLibraryIndex]].Sha256Strings[_SceneMusicListSelectedDifficulty]
					_SceneMusicListState = _SceneMusicListStatePlayMusic
				EndIf
			EndIf
			
		EndCase
		Case _SceneMusicListStatePlayMusic:
			If _SceneMusicListPrelisteningMusicId > 0
				dec _SceneMusicListPrelisteningMusicVolumeFactor, GetFrameTime()
				SetMusicFileVolume(_SceneMusicListPrelisteningMusicId, GetSettingsMusicVolume() * _SceneMusicListPrelisteningMusicVolumeFactor)
			EndIf
			If GetSpriteButtonDismissed(_SceneMusicListLeftSpriteButtonId) And GetSpriteButtonDismissed(_SceneMusicListRightSpriteButtonId) And GetSpriteButtonDismissed(_SceneMusicListBellSpriteButtonId) And GetSpriteButtonDismissed(_SceneMusicListNextSpriteButtonId) And GetScreenFadeOutCompleted() And _SceneMusicListPrelisteningMusicVolumeFactor <= 0.0
				_SceneMusicListDeleteResourcesAndInitializeVars()
				result = SceneResultEnd
			EndIf
		EndCase
		Case _SceneMusicListStateBell:
			If _SceneMusicListPrelisteningMusicVolumeFactor > 0.0
				dec _SceneMusicListPrelisteningMusicVolumeFactor, GetFrameTime()
				If _SceneMusicListPrelisteningMusicId > 0 Then SetMusicFileVolume(_SceneMusicListPrelisteningMusicId, GetSettingsMusicVolume() * _SceneMusicListPrelisteningMusicVolumeFactor)
			EndIf
			If _SceneMusicListLowerBackEmptyAlphaFactor < 1.0
				inc _SceneMusicListLowerBackEmptyAlphaFactor, GetFrameTime()
				SetSpriteColorAlpha(_SceneMusicListLowerBackEmptySpriteId, MaxF(0, (_SceneMusicListLowerBackEmptyAlphaFactor - 0.5) * 2 * 255))
			EndIf
			If _SceneMusicListUpperBackEmptyAlphaFactor < 1.0
				inc _SceneMusicListUpperBackEmptyAlphaFactor, GetFrameTime()
				If _SceneMusicListUpperBackEmptyAlphaFactor > 1.0 Then _SceneMusicListUpperBackEmptyAlphaFactor = 1.0
				If GetSpriteColorAlpha(_SceneMusicListUpperBackEmptySpriteId) < 255
					SetSpriteColorAlpha(_SceneMusicListUpperBackEmptySpriteId, MaxF(0, (_SceneMusicListUpperBackEmptyAlphaFactor - 0.5) * 2 * 255))
				EndIf
			EndIf
			If GetSpriteButtonDismissed(_SceneMusicListLeftSpriteButtonId) And GetSpriteButtonDismissed(_SceneMusicListRightSpriteButtonId) And GetSpriteButtonDismissed(_SceneMusicListBellSpriteButtonId) And GetSpriteButtonDismissed(_SceneMusicListNextSpriteButtonId) And _SceneMusicListPrelisteningMusicVolumeFactor <= 0.0 And _SceneMusicListLowerBackEmptyAlphaFactor >= 1.0 And _SceneMusicListUpperBackEmptyAlphaFactor >= 1.0
				// Bell Start
				_SceneMusicListMarkerBackSpriteId = CreateSprite(GetThemeImage("test_marker_back"))
				SetSpriteSize(_SceneMusicListMarkerBackSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpritePosition(_SceneMusicListMarkerBackSpriteId, GetJButtonX(2), GetJButtonY(2))
				SetSpriteDepth(_SceneMusicListMarkerBackSpriteId, DEPTH_MUSICLIST_MARKERBACK)
				SetSpriteVisible(_SceneMusicListSpinningDiskSpriteId, 0)
				DeleteSpriteButton(_SceneMusicListLeftSpriteButtonId)
				_SceneMusicListLeftSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListRightSpriteButtonId)
				_SceneMusicListRightSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListBellSpriteButtonId)
				_SceneMusicListBellSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListNextSpriteButtonId)
				_SceneMusicListNextSpriteButtonId = 0
				_SceneMusicListMarkerLeftSpriteButtonId = CreateSpriteButton(1, SpriteButtonTypeLeft)
				_SceneMusicListMarkerRightSpriteButtonId = CreateSpriteButton(3, SpriteButtonTypeRight)
				_SceneMusicListSortingLeftSpriteButtonId = CreateSpriteButton(5, SpriteButtonTypeLeft)
				_SceneMusicListSortingRightSpriteButtonId = CreateSpriteButton(7, SpriteButtonTypeRight)
				_SceneMusicListBellBackSpriteButtonId = CreateSpriteButton(16, SpriteButtonTypeBack)
				_SceneMusicListBellSettingsSpriteButtonId = CreateSpriteButton(15, SpriteButtonTypeSettings)
				If _SceneMusicListPrelisteningMusicId > 0
					StopMusic()
					DeleteMusic(_SceneMusicListPrelisteningMusicId)
					_SceneMusicListPrelisteningMusicId = 0
					SetMusicFileVolume(GetThemeMusic("bgm_musiclist"), GetSettingsMusicVolume())
					PlayMusic(GetThemeMusic("bgm_musiclist"), 1)
				EndIf
				_SceneMusicListDeleteMusicButtons()
				_SceneMusicListFlushCoverCache()
				_SceneMusicListBlockButton = 0
				
				_SceneMusicListBellToggleButtonsFactor = 0.0
				
				// Sort Button
				_SceneMusicListSortButtonAnimProgress = 1.0
				If Mod(GetSettingsSortingMode(), 2) = 0
					_SceneMusicListSortButtonSpriteId = CreateSprite(GetThemeImage("btn_sort_asc"))
				Else
					_SceneMusicListSortButtonSpriteId = CreateSprite(GetThemeImage("btn_sort_desc"))
				EndIf
				SetSpriteSize(_SceneMusicListSortButtonSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpritePosition(_SceneMusicListSortButtonSpriteId, GetJButtonX(6), GetJButtonY(6))
				SetSpriteDepth(_SceneMusicListSortButtonSpriteId, DEPTH_MUSICLIST_TOGGLEBUTTON)
				SetSpriteColorAlpha(_SceneMusicListSortButtonSpriteId, 0)
				_SceneMusicListSortButtonTextId = CreateText(GetLocalizedString(GetSortingString(GetSettingsSortingMode()/2)))
				SetTextSize(_SceneMusicListSortButtonTextId, GetJButtonSize() * GetThemeValue("mll_sortingbuttontext_size") * GetLanguageFontScale())
				SetTextLineSpacing(_SceneMusicListSortButtonTextId, GetTextSize(_SceneMusicListSortButtonTextId) * GetLanguageFontLineSpacing())
				SetTextPosition(_SceneMusicListSortButtonTextId, GetJButtonX(6) + GetJButtonSize() * GetThemeValue("mll_sortingbuttontext_x"), GetJButtonY(6) + GetJButtonSize() * GetThemeValue("mll_sortingbuttontext_y"))
				SetTextDepth(_SceneMusicListSortButtonTextId, DEPTH_MUSICLIST_TOGGLEBUTTON_TEXT)
				SetTextAlignment(_SceneMusicListSortButtonTextId, GetThemeValue("mll_sortingbuttontext_align"))
				If GetLanguageBoldFont() <> 0
					SetTextFont(_SceneMusicListSortButtonTextId, GetLanguageBoldFont())
				Else
					SetTextFont(_SceneMusicListSortButtonTextId, GetLanguageFont())
					SetTextBold(_SceneMusicListSortButtonTextId, 1)
				EndIf
				color11 As ThemeColor
				color11 = GetThemeColor("mll_sortingbuttontext_color")
				SetTextColor(_SceneMusicListSortButtonTextId, color11.Red, color11.Green, color11.Blue, 255)
				SetTextMaxWidth(_SceneMusicListSortButtonTextId, GetJButtonSize() * GetThemeValue("mll_sortingbuttontext_maxwidth"))
				Select GetThemeValue("mll_sortingbuttontext_valign")
					Case 1.0:
						SetTextY(_SceneMusicListSortButtonTextId, GetTextY(_SceneMusicListSortButtonTextId) - GetTextTotalHeight(_SceneMusicListSortButtonTextId) * 0.5)
					EndCase
					Case 2.0:
						SetTextY(_SceneMusicListSortButtonTextId, GetTextY(_SceneMusicListSortButtonTextId) - GetTextTotalHeight(_SceneMusicListSortButtonTextId))
					EndCase
				EndSelect
				
				// AutoPlay Button
				_SceneMusicListAutoPlayToggleAnimProgress = 1.0
				If GetSettingsAutoPlay()
					_SceneMusicListAutoPlayToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_on"))
				Else
					_SceneMusicListAutoPlayToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_off"))
				EndIf
				SetSpriteSize(_SceneMusicListAutoPlayToggleSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpritePosition(_SceneMusicListAutoPlayToggleSpriteId, GetJButtonX(9), GetJButtonY(9))
				SetSpriteDepth(_SceneMusicListAutoPlayToggleSpriteId, DEPTH_MUSICLIST_TOGGLEBUTTON)
				SetSpriteColorAlpha(_SceneMusicListAutoPlayToggleSpriteId, 0)
				_SceneMusicListAutoPlayToggleTextId = CreateText(GetLocalizedString("SETTINGS_AUTOPLAY"))
				SetTextSize(_SceneMusicListAutoPlayToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_size") * GetLanguageFontScale())
				SetTextLineSpacing(_SceneMusicListAutoPlayToggleTextId, GetTextSize(_SceneMusicListAutoPlayToggleTextId) * GetLanguageFontLineSpacing())
				SetTextPosition(_SceneMusicListAutoPlayToggleTextId, GetJButtonX(9) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_x"), GetJButtonY(9) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_y"))
				SetTextDepth(_SceneMusicListAutoPlayToggleTextId, DEPTH_MUSICLIST_TOGGLEBUTTON_TEXT)
				SetTextAlignment(_SceneMusicListAutoPlayToggleTextId, GetThemeValue("mll_togglebuttontext_align"))
				If GetLanguageBoldFont() <> 0
					SetTextFont(_SceneMusicListAutoPlayToggleTextId, GetLanguageBoldFont())
				Else
					SetTextFont(_SceneMusicListAutoPlayToggleTextId, GetLanguageFont())
					SetTextBold(_SceneMusicListAutoPlayToggleTextId, 1)
				EndIf
				color11 = GetThemeColor("mll_togglebuttontext_color")
				SetTextColor(_SceneMusicListAutoPlayToggleTextId, color11.Red, color11.Green, color11.Blue, 255)
				SetTextMaxWidth(_SceneMusicListAutoPlayToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_maxwidth"))
				Select GetThemeValue("mll_togglebuttontext_valign")
					Case 1.0:
						SetTextY(_SceneMusicListAutoPlayToggleTextId, GetTextY(_SceneMusicListAutoPlayToggleTextId) - GetTextTotalHeight(_SceneMusicListAutoPlayToggleTextId) * 0.5)
					EndCase
					Case 2.0:
						SetTextY(_SceneMusicListAutoPlayToggleTextId, GetTextY(_SceneMusicListAutoPlayToggleTextId) - GetTextTotalHeight(_SceneMusicListAutoPlayToggleTextId))
					EndCase
				EndSelect
				
				// ClapSound Button
				_SceneMusicListClapSoundToggleAnimProgress = 1.0
				If GetSettingsPlayClap()
					_SceneMusicListClapSoundToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_on"))
				Else
					_SceneMusicListClapSoundToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_off"))
				EndIf
				SetSpriteSize(_SceneMusicListClapSoundToggleSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpritePosition(_SceneMusicListClapSoundToggleSpriteId, GetJButtonX(10), GetJButtonY(10))
				SetSpriteDepth(_SceneMusicListClapSoundToggleSpriteId, DEPTH_MUSICLIST_TOGGLEBUTTON)
				SetSpriteColorAlpha(_SceneMusicListClapSoundToggleSpriteId, 0)
				_SceneMusicListClapSoundToggleTextId = CreateText(GetLocalizedString("SETTINGS_CLAPSOUND"))
				SetTextSize(_SceneMusicListClapSoundToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_size") * GetLanguageFontScale())
				SetTextLineSpacing(_SceneMusicListClapSoundToggleTextId, GetTextSize(_SceneMusicListClapSoundToggleTextId) * GetLanguageFontLineSpacing())
				SetTextPosition(_SceneMusicListClapSoundToggleTextId, GetJButtonX(10) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_x"), GetJButtonY(10) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_y"))
				SetTextDepth(_SceneMusicListClapSoundToggleTextId, DEPTH_MUSICLIST_TOGGLEBUTTON_TEXT)
				SetTextAlignment(_SceneMusicListClapSoundToggleTextId, GetThemeValue("mll_togglebuttontext_align"))
				If GetLanguageBoldFont() <> 0
					SetTextFont(_SceneMusicListClapSoundToggleTextId, GetLanguageBoldFont())
				Else
					SetTextFont(_SceneMusicListClapSoundToggleTextId, GetLanguageFont())
					SetTextBold(_SceneMusicListClapSoundToggleTextId, 1)
				EndIf
				color11 = GetThemeColor("mll_togglebuttontext_color")
				SetTextColor(_SceneMusicListClapSoundToggleTextId, color11.Red, color11.Green, color11.Blue, 255)
				SetTextMaxWidth(_SceneMusicListClapSoundToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_maxwidth"))
				Select GetThemeValue("mll_togglebuttontext_valign")
					Case 1.0:
						SetTextY(_SceneMusicListClapSoundToggleTextId, GetTextY(_SceneMusicListClapSoundToggleTextId) - GetTextTotalHeight(_SceneMusicListClapSoundToggleTextId) * 0.5)
					EndCase
					Case 2.0:
						SetTextY(_SceneMusicListClapSoundToggleTextId, GetTextY(_SceneMusicListClapSoundToggleTextId) - GetTextTotalHeight(_SceneMusicListClapSoundToggleTextId))
					EndCase
				EndSelect
				
				// SimpleEffect Button
				_SceneMusicListSimpleEffectToggleAnimProgress = 1.0
				If GetSettingsSimpleEffect()
					_SceneMusicListSimpleEffectToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_on"))
				Else
					_SceneMusicListSimpleEffectToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_off"))
				EndIf
				SetSpriteSize(_SceneMusicListSimpleEffectToggleSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpritePosition(_SceneMusicListSimpleEffectToggleSpriteId, GetJButtonX(11), GetJButtonY(11))
				SetSpriteDepth(_SceneMusicListSimpleEffectToggleSpriteId, DEPTH_MUSICLIST_TOGGLEBUTTON)
				SetSpriteColorAlpha(_SceneMusicListSimpleEffectToggleSpriteId, 0)
				_SceneMusicListSimpleEffectToggleTextId = CreateText(GetLocalizedString("SETTINGS_SIMPLEEFFECT"))
				SetTextSize(_SceneMusicListSimpleEffectToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_size") * GetLanguageFontScale())
				SetTextLineSpacing(_SceneMusicListSimpleEffectToggleTextId, GetTextSize(_SceneMusicListSimpleEffectToggleTextId) * GetLanguageFontLineSpacing())
				SetTextPosition(_SceneMusicListSimpleEffectToggleTextId, GetJButtonX(11) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_x"), GetJButtonY(11) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_y"))
				SetTextDepth(_SceneMusicListSimpleEffectToggleTextId, DEPTH_MUSICLIST_TOGGLEBUTTON_TEXT)
				SetTextAlignment(_SceneMusicListSimpleEffectToggleTextId, GetThemeValue("mll_togglebuttontext_align"))
				If GetLanguageBoldFont() <> 0
					SetTextFont(_SceneMusicListSimpleEffectToggleTextId, GetLanguageBoldFont())
				Else
					SetTextFont(_SceneMusicListSimpleEffectToggleTextId, GetLanguageFont())
					SetTextBold(_SceneMusicListSimpleEffectToggleTextId, 1)
				EndIf
				color11 = GetThemeColor("mll_togglebuttontext_color")
				SetTextColor(_SceneMusicListSimpleEffectToggleTextId, color11.Red, color11.Green, color11.Blue, 255)
				SetTextMaxWidth(_SceneMusicListSimpleEffectToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_maxwidth"))
				Select GetThemeValue("mll_togglebuttontext_valign")
					Case 1.0:
						SetTextY(_SceneMusicListSimpleEffectToggleTextId, GetTextY(_SceneMusicListSimpleEffectToggleTextId) - GetTextTotalHeight(_SceneMusicListSimpleEffectToggleTextId) * 0.5)
					EndCase
					Case 2.0:
						SetTextY(_SceneMusicListSimpleEffectToggleTextId, GetTextY(_SceneMusicListSimpleEffectToggleTextId) - GetTextTotalHeight(_SceneMusicListSimpleEffectToggleTextId))
					EndCase
				EndSelect
				
				// HighlightHoldMarker Button
				_SceneMusicListHighlightHoldMarkerToggleAnimProgress = 1.0
				If GetSettingsHighlightHoldMarker()
					_SceneMusicListHighlightHoldMarkerToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_on"))
				Else
					_SceneMusicListHighlightHoldMarkerToggleSpriteId = CreateSprite(GetThemeImage("btn_toggle_off"))
				EndIf
				SetSpriteSize(_SceneMusicListHighlightHoldMarkerToggleSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpritePosition(_SceneMusicListHighlightHoldMarkerToggleSpriteId, GetJButtonX(12), GetJButtonY(12))
				SetSpriteDepth(_SceneMusicListHighlightHoldMarkerToggleSpriteId, DEPTH_MUSICLIST_TOGGLEBUTTON)
				SetSpriteColorAlpha(_SceneMusicListHighlightHoldMarkerToggleSpriteId, 0)
				_SceneMusicListHighlightHoldMarkerToggleTextId = CreateText(GetLocalizedString("SETTINGS_HIGHLIGHTHOLDMARKER"))
				SetTextSize(_SceneMusicListHighlightHoldMarkerToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_size") * GetLanguageFontScale())
				SetTextLineSpacing(_SceneMusicListHighlightHoldMarkerToggleTextId, GetTextSize(_SceneMusicListHighlightHoldMarkerToggleTextId) * GetLanguageFontLineSpacing())
				SetTextPosition(_SceneMusicListHighlightHoldMarkerToggleTextId, GetJButtonX(12) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_x"), GetJButtonY(12) + GetJButtonSize() * GetThemeValue("mll_togglebuttontext_y"))
				SetTextDepth(_SceneMusicListHighlightHoldMarkerToggleTextId, DEPTH_MUSICLIST_TOGGLEBUTTON_TEXT)
				SetTextAlignment(_SceneMusicListHighlightHoldMarkerToggleTextId, GetThemeValue("mll_togglebuttontext_align"))
				If GetLanguageBoldFont() <> 0
					SetTextFont(_SceneMusicListHighlightHoldMarkerToggleTextId, GetLanguageBoldFont())
				Else
					SetTextFont(_SceneMusicListHighlightHoldMarkerToggleTextId, GetLanguageFont())
					SetTextBold(_SceneMusicListHighlightHoldMarkerToggleTextId, 1)
				EndIf
				color11 = GetThemeColor("mll_togglebuttontext_color")
				SetTextColor(_SceneMusicListHighlightHoldMarkerToggleTextId, color11.Red, color11.Green, color11.Blue, 255)
				SetTextMaxWidth(_SceneMusicListHighlightHoldMarkerToggleTextId, GetJButtonSize() * GetThemeValue("mll_togglebuttontext_maxwidth"))
				Select GetThemeValue("mll_togglebuttontext_valign")
					Case 1.0:
						SetTextY(_SceneMusicListHighlightHoldMarkerToggleTextId, GetTextY(_SceneMusicListHighlightHoldMarkerToggleTextId) - GetTextTotalHeight(_SceneMusicListHighlightHoldMarkerToggleTextId) * 0.5)
					EndCase
					Case 2.0:
						SetTextY(_SceneMusicListHighlightHoldMarkerToggleTextId, GetTextY(_SceneMusicListHighlightHoldMarkerToggleTextId) - GetTextTotalHeight(_SceneMusicListHighlightHoldMarkerToggleTextId))
					EndCase
				EndSelect
				
				// Get marker list and draw Marker
				While _SceneMusicListMarkerFolders.Length >= 0
					_SceneMusicListMarkerFolders.Remove()
				EndWhile
				_SceneMusicListMarkerCurIdx = 0
				If SetFolder(MARKERS_PATH) > 0
					folder$ = GetFirstFolder(0)  //ReadFolder
					While folder$ <> ""
						If GetFileExists(MARKERS_PATH + folder$ + "/marker.png") Then _SceneMusicListMarkerFolders.Insert(folder$)
						If folder$ = GetSettingsMarker() Then _SceneMusicListMarkerCurIdx = _SceneMusicListMarkerFolders.Length
						folder$ = GetNextFolder()
					EndWhile
				EndIf
				
				While _SceneMusicListMarkerImageIds.Length >= 0
					DeleteImage(_SceneMusicListMarkerImageIds[_SceneMusicListMarkerImageIds.Length])
					_SceneMusicListMarkerImageIds.Remove()
				EndWhile
				folder$ = _SceneMusicListMarkerFolders[_SceneMusicListMarkerCurIdx]
				_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/marker.png"))
				CheckError()
				_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/perfect.png"))
				CheckError()
				_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/great.png"))
				CheckError()
				_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/good.png"))
				CheckError()
				_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/bad.png"))
				CheckError()
				_SceneMusicListMarkerSpriteId = CreateSprite(_SceneMusicListMarkerImageIds[0])
				SetSpriteAnimation(_SceneMusicListMarkerSpriteId, GetImageWidth(_SceneMusicListMarkerImageIds[0]) / 5, GetImageHeight(_SceneMusicListMarkerImageIds[0]) / 5, 25)
				SetSpritePosition(_SceneMusicListMarkerSpriteId, GetJButtonX(2), GetJButtonY(2))
				SetSpriteSize(_SceneMusicListMarkerSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpriteDepth(_SceneMusicListMarkerSpriteId, DEPTH_MUSICLIST_MARKER)
				SetSpriteVisible(_SceneMusicListMarkerSpriteId, 0)
				_SceneMusicListMarkerPlayedTime = 999.0
				_SceneMusicListMarkerEffectSpriteId = CreateSprite(_SceneMusicListMarkerImageIds[1])
				SetSpritePosition(_SceneMusicListMarkerEffectSpriteId, GetJButtonX(2), GetJButtonY(2))
				SetSpriteSize(_SceneMusicListMarkerEffectSpriteId, GetJButtonSize(), GetJButtonSize())
				SetSpriteDepth(_SceneMusicListMarkerEffectSpriteId, DEPTH_MUSICLIST_MARKEREFFECT)
				SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 0)
				
				//GetSpritePla
			EndIf
			If  GetSpriteButtonDismissing(_SceneMusicListMarkerLeftSpriteButtonId)
				If _SceneMusicListBellToggleButtonsFactor > 0.0
					dec _SceneMusicListBellToggleButtonsFactor, GetFrameTime() / 0.25
					If _SceneMusicListBellToggleButtonsFactor <0.0 Then _SceneMusicListBellToggleButtonsFactor = 0.0
				EndIf
			Else
				If _SceneMusicListBellToggleButtonsFactor < 1.0
					inc _SceneMusicListBellToggleButtonsFactor, GetFrameTime() / 0.25
					If _SceneMusicListBellToggleButtonsFactor > 1.0 Then _SceneMusicListBellToggleButtonsFactor = 1.0
				EndIf
			EndIf
			
			If _SceneMusicListSortButtonSpriteId > 0
				SetSpriteColorAlpha(_SceneMusicListSortButtonSpriteId, _SceneMusicListBellToggleButtonsFactor * 255)
				SetTextColorAlpha(_SceneMusicListSortButtonTextId, _SceneMusicListBellToggleButtonsFactor * 255)
				If _SceneMusicListSortButtonAnimProgress < 1.0
					inc _SceneMusicListSortButtonAnimProgress, GetFrameTime() * 6.0
					If _SceneMusicListSortButtonAnimProgress <= 0.5
						prog# = _SceneMusicListSortButtonAnimProgress *0.25
						SetSpriteSize(_SceneMusicListSortButtonSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					Else
						prog# = 0.125 - (_SceneMusicListSortButtonAnimProgress - 0.5) *0.25
						SetSpriteSize(_SceneMusicListSortButtonSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					EndIf
					posOffset# = (GetJButtonSize() - GetSpriteWidth(_SceneMusicListSortButtonSpriteId)) * 0.5
					SetSpritePosition(_SceneMusicListSortButtonSpriteId, GetJButtonX(6) + posOffset#, GetJButtonY(6) + posOffset#)
				Else
					SetSpriteSize(_SceneMusicListSortButtonSpriteId, GetJButtonSize(), GetJButtonSize())
					SetSpritePosition(_SceneMusicListSortButtonSpriteId, GetJButtonX(6), GetJButtonY(6))
				EndIf
			EndIf
			
			If _SceneMusicListAutoPlayToggleSpriteId > 0
				SetSpriteColorAlpha(_SceneMusicListAutoPlayToggleSpriteId, _SceneMusicListBellToggleButtonsFactor * 255)
				
				SetTextColorAlpha(_SceneMusicListAutoPlayToggleTextId, _SceneMusicListBellToggleButtonsFactor * 255)
				If _SceneMusicListAutoPlayToggleAnimProgress < 1.0
					inc _SceneMusicListAutoPlayToggleAnimProgress, GetFrameTime() * 6.0
					If _SceneMusicListAutoPlayToggleAnimProgress <= 0.5
						prog# = _SceneMusicListAutoPlayToggleAnimProgress *0.25
						SetSpriteSize(_SceneMusicListAutoPlayToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					Else
						prog# = 0.125 - (_SceneMusicListAutoPlayToggleAnimProgress - 0.5) *0.25
						SetSpriteSize(_SceneMusicListAutoPlayToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					EndIf
					posOffset# = (GetJButtonSize() - GetSpriteWidth(_SceneMusicListAutoPlayToggleSpriteId)) * 0.5
					SetSpritePosition(_SceneMusicListAutoPlayToggleSpriteId, GetJButtonX(9) + posOffset#, GetJButtonY(9) + posOffset#)
				Else
					SetSpriteSize(_SceneMusicListAutoPlayToggleSpriteId, GetJButtonSize(), GetJButtonSize())
					SetSpritePosition(_SceneMusicListAutoPlayToggleSpriteId, GetJButtonX(9), GetJButtonY(9))
				EndIf
			EndIf
			If _SceneMusicListClapSoundToggleSpriteId > 0
				SetSpriteColorAlpha(_SceneMusicListClapSoundToggleSpriteId, _SceneMusicListBellToggleButtonsFactor * 255)
				SetTextColorAlpha(_SceneMusicListClapSoundToggleTextId, _SceneMusicListBellToggleButtonsFactor * 255)
				If _SceneMusicListClapSoundToggleAnimProgress < 1.0
					inc _SceneMusicListClapSoundToggleAnimProgress, GetFrameTime() * 6.0
					If _SceneMusicListClapSoundToggleAnimProgress <= 0.5
						prog# = _SceneMusicListClapSoundToggleAnimProgress *0.25
						SetSpriteSize(_SceneMusicListClapSoundToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					Else
						prog# = 0.125 - (_SceneMusicListClapSoundToggleAnimProgress - 0.5) *0.25
						SetSpriteSize(_SceneMusicListClapSoundToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					EndIf
					posOffset# = (GetJButtonSize() - GetSpriteWidth(_SceneMusicListClapSoundToggleSpriteId)) * 0.5
					SetSpritePosition(_SceneMusicListClapSoundToggleSpriteId, GetJButtonX(10) + posOffset#, GetJButtonY(10) + posOffset#)
				Else
					SetSpriteSize(_SceneMusicListClapSoundToggleSpriteId, GetJButtonSize(), GetJButtonSize())
					SetSpritePosition(_SceneMusicListClapSoundToggleSpriteId, GetJButtonX(10), GetJButtonY(10))
				EndIf
			EndIf
			If _SceneMusicListSimpleEffectToggleSpriteId > 0
				SetSpriteColorAlpha(_SceneMusicListSimpleEffectToggleSpriteId, _SceneMusicListBellToggleButtonsFactor * 255)
				SetTextColorAlpha(_SceneMusicListSimpleEffectToggleTextId, _SceneMusicListBellToggleButtonsFactor * 255)
				If _SceneMusicListSimpleEffectToggleAnimProgress < 1.0
					inc _SceneMusicListSimpleEffectToggleAnimProgress, GetFrameTime() * 6.0
					If _SceneMusicListSimpleEffectToggleAnimProgress <= 0.5
						prog# = _SceneMusicListSimpleEffectToggleAnimProgress *0.25
						SetSpriteSize(_SceneMusicListSimpleEffectToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					Else
						prog# = 0.125 - (_SceneMusicListSimpleEffectToggleAnimProgress - 0.5) *0.25
						SetSpriteSize(_SceneMusicListSimpleEffectToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					EndIf
					posOffset# = (GetJButtonSize() - GetSpriteWidth(_SceneMusicListSimpleEffectToggleSpriteId)) * 0.5
					SetSpritePosition(_SceneMusicListSimpleEffectToggleSpriteId, GetJButtonX(11) + posOffset#, GetJButtonY(11) + posOffset#)
				Else
					SetSpriteSize(_SceneMusicListSimpleEffectToggleSpriteId, GetJButtonSize(), GetJButtonSize())
					SetSpritePosition(_SceneMusicListSimpleEffectToggleSpriteId, GetJButtonX(11), GetJButtonY(11))
				EndIf
			EndIf
			If _SceneMusicListHighlightHoldMarkerToggleSpriteId > 0
				SetSpriteColorAlpha(_SceneMusicListHighlightHoldMarkerToggleSpriteId, _SceneMusicListBellToggleButtonsFactor * 255)
				SetTextColorAlpha(_SceneMusicListHighlightHoldMarkerToggleTextId, _SceneMusicListBellToggleButtonsFactor * 255)
				If _SceneMusicListHighlightHoldMarkerToggleAnimProgress < 1.0
					inc _SceneMusicListHighlightHoldMarkerToggleAnimProgress, GetFrameTime() * 6.0
					If _SceneMusicListHighlightHoldMarkerToggleAnimProgress <= 0.5
						prog# = _SceneMusicListHighlightHoldMarkerToggleAnimProgress *0.25
						SetSpriteSize(_SceneMusicListHighlightHoldMarkerToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					Else
						prog# = 0.125 - (_SceneMusicListHighlightHoldMarkerToggleAnimProgress - 0.5) *0.25
						SetSpriteSize(_SceneMusicListHighlightHoldMarkerToggleSpriteId, (1.0-prog#) * GetJButtonSize(), (1.0-prog#) * GetJButtonSize())
					EndIf
					posOffset# = (GetJButtonSize() - GetSpriteWidth(_SceneMusicListHighlightHoldMarkerToggleSpriteId)) * 0.5
					SetSpritePosition(_SceneMusicListHighlightHoldMarkerToggleSpriteId, GetJButtonX(12) + posOffset#, GetJButtonY(12) + posOffset#)
				Else
					SetSpriteSize(_SceneMusicListHighlightHoldMarkerToggleSpriteId, GetJButtonSize(), GetJButtonSize())
					SetSpritePosition(_SceneMusicListHighlightHoldMarkerToggleSpriteId, GetJButtonX(12), GetJButtonY(12))
				EndIf
			EndIf
			If Not _SceneMusicListBlockButton
				If GetSpriteButtonPressed(_SceneMusicListBellBackSpriteButtonId)
					DeleteSprite(_SceneMusicListMarkerBackSpriteId)
					_SceneMusicListMarkerBackSpriteId = 0
					_SceneMusicListBlockButton = 1
					
					DismissSpriteButton(_SceneMusicListMarkerLeftSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListMarkerRightSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListSortingLeftSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListSortingRightSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListBellBackSpriteButtonId, 1)
					DismissSpriteButton(_SceneMusicListBellSettingsSpriteButtonId, 1)
				ElseIf GetSpriteButtonPressed(_SceneMusicListMarkerLeftSpriteButtonId) Or GetSpriteButtonPressed(_SceneMusicListMarkerRightSpriteButtonId)
					StopSprite(_SceneMusicListMarkerSpriteId)
					SetSpriteVisible(_SceneMusicListMarkerSpriteId, 0)
					StopSprite(_SceneMusicListMarkerEffectSpriteId)
					SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 0)
					_SceneMusicListMarkerPlayedTime = 999.0
					If GetSpriteButtonPressed(_SceneMusicListMarkerLeftSpriteButtonId)
						dec _SceneMusicListMarkerCurIdx
						If _SceneMusicListMarkerCurIdx < 0 Then inc _SceneMusicListMarkerCurIdx, _SceneMusicListMarkerFolders.Length + 1
						SetSettingsMarker(_SceneMusicListMarkerFolders[_SceneMusicListMarkerCurIdx])
					Else
						inc _SceneMusicListMarkerCurIdx
						If _SceneMusicListMarkerCurIdx > _SceneMusicListMarkerFolders.Length Then dec _SceneMusicListMarkerCurIdx, _SceneMusicListMarkerFolders.Length + 1
						SetSettingsMarker(_SceneMusicListMarkerFolders[_SceneMusicListMarkerCurIdx])
					EndIf
					While _SceneMusicListMarkerImageIds.Length >= 0
						DeleteImage(_SceneMusicListMarkerImageIds[_SceneMusicListMarkerImageIds.Length])
						_SceneMusicListMarkerImageIds.Remove()
					EndWhile
					folder$ = _SceneMusicListMarkerFolders[_SceneMusicListMarkerCurIdx]
					_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/marker.png"))
					CheckError()
					_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/perfect.png"))
					CheckError()
					_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/great.png"))
					CheckError()
					_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/good.png"))
					CheckError()
					_SceneMusicListMarkerImageIds.Insert(LoadImage(MARKERS_PATH + folder$ + "/bad.png"))
					CheckError()
					SetSpriteImage(_SceneMusicListMarkerSpriteId, _SceneMusicListMarkerImageIds[0])
					SetSpriteAnimation(_SceneMusicListMarkerSpriteId, GetImageWidth(_SceneMusicListMarkerImageIds[0]) / 5, GetImageHeight(_SceneMusicListMarkerImageIds[0]) / 5, 25)
				ElseIf GetSpriteButtonPressed(_SceneMusicListSortingRightSpriteButtonId)
					_SceneMusicListSortButtonAnimProgress = 0.0
					If GetSettingsSortingMode() + 2 > (GetSortingStringLastIndex()+1)*2-1
						SetSettingsSortingMode(GetSettingsSortingMode() + 2 - (GetSortingStringLastIndex()+1)*2)
					Else
						SetSettingsSortingMode(GetSettingsSortingMode() + 2)
					EndIf
					//SetSpriteImage(_SceneMusicListSortButtonSpriteId, IfInteger(Mod(GetSettingsSortingMode(), 2) = 0, GetThemeImage("btn_sort_asc"), GetThemeImage("btn_sort_desc")))
					SetTextString(_SceneMusicListSortButtonTextId, GetLocalizedString(GetSortingString(GetSettingsSortingMode()/2)))
					SetTextY(_SceneMusicListSortButtonTextId, GetJButtonY(6) + GetJButtonSize() * GetThemeValue("mll_sortingbuttontext_y"))
					Select GetThemeValue("mll_sortingbuttontext_valign")
						Case 1.0:
							SetTextY(_SceneMusicListSortButtonTextId, GetTextY(_SceneMusicListSortButtonTextId) - GetTextTotalHeight(_SceneMusicListSortButtonTextId) * 0.5)
						EndCase
						Case 2.0:
							SetTextY(_SceneMusicListSortButtonTextId, GetTextY(_SceneMusicListSortButtonTextId) - GetTextTotalHeight(_SceneMusicListSortButtonTextId))
						EndCase
					EndSelect
				ElseIf GetSpriteButtonPressed(_SceneMusicListSortingLeftSpriteButtonId)
					_SceneMusicListSortButtonAnimProgress = 0.0
					If GetSettingsSortingMode() - 2 < 0
						SetSettingsSortingMode(GetSettingsSortingMode() -2 + (GetSortingStringLastIndex()+1)*2)
					Else
						SetSettingsSortingMode(GetSettingsSortingMode() - 2)
					EndIf
					//SetSpriteImage(_SceneMusicListSortButtonSpriteId, IfInteger(Mod(GetSettingsSortingMode(), 2) = 0, GetThemeImage("btn_sort_asc"), GetThemeImage("btn_sort_desc")))
					SetTextString(_SceneMusicListSortButtonTextId, GetLocalizedString(GetSortingString(GetSettingsSortingMode()/2)))
					SetTextY(_SceneMusicListSortButtonTextId, GetJButtonY(6) + GetJButtonSize() * GetThemeValue("mll_sortingbuttontext_y"))
					Select GetThemeValue("mll_sortingbuttontext_valign")
						Case 1.0:
							SetTextY(_SceneMusicListSortButtonTextId, GetTextY(_SceneMusicListSortButtonTextId) - GetTextTotalHeight(_SceneMusicListSortButtonTextId) * 0.5)
						EndCase
						Case 2.0:
							SetTextY(_SceneMusicListSortButtonTextId, GetTextY(_SceneMusicListSortButtonTextId) - GetTextTotalHeight(_SceneMusicListSortButtonTextId))
						EndCase
					EndSelect
				ElseIf GetJButtonPressed(6)
					_SceneMusicListSortButtonAnimProgress = 0.0
					If Mod(GetSettingsSortingMode(), 2) = 0
						SetSettingsSortingMode(GetSettingsSortingMode() + 1)
						PlaySound(GetThemeSound("snd_toggle_off"))
					Else
						SetSettingsSortingMode(GetSettingsSortingMode() - 1)
						PlaySound(GetThemeSound("snd_toggle_on"))
					EndIf
					SetSpriteImage(_SceneMusicListSortButtonSpriteId, IfInteger(Mod(GetSettingsSortingMode(), 2) = 0, GetThemeImage("btn_sort_asc"), GetThemeImage("btn_sort_desc")))
				ElseIf GetJButtonPressed(9)
					_SceneMusicListAutoPlayToggleAnimProgress = 0.0
					If GetSettingsAutoPlay()
						SetSpriteImage(_SceneMusicListAutoPlayToggleSpriteId, GetThemeImage("btn_toggle_off"))
						SetSettingsAutoPlay(0)
						PlaySound(GetThemeSound("snd_toggle_off"))
					Else
						SetSpriteImage(_SceneMusicListAutoPlayToggleSpriteId, GetThemeImage("btn_toggle_on"))
						SetSettingsAutoPlay(1)
						PlaySound(GetThemeSound("snd_toggle_on"))
					EndIf
				ElseIf GetJButtonPressed(10)
					_SceneMusicListClapSoundToggleAnimProgress = 0.0
					If GetSettingsPlayClap()
						SetSpriteImage(_SceneMusicListClapSoundToggleSpriteId, GetThemeImage("btn_toggle_off"))
						SetSettingsPlayClap(0)
						PlaySound(GetThemeSound("snd_toggle_off"))
					Else
						SetSpriteImage(_SceneMusicListClapSoundToggleSpriteId, GetThemeImage("btn_toggle_on"))
						SetSettingsPlayClap(1)
						PlaySound(GetThemeSound("snd_toggle_on"))
					EndIf
				ElseIf GetJButtonPressed(11)
					_SceneMusicListSimpleEffectToggleAnimProgress = 0.0
					If GetSettingsSimpleEffect()
						SetSpriteImage(_SceneMusicListSimpleEffectToggleSpriteId, GetThemeImage("btn_toggle_off"))
						SetSettingsSimpleEffect(0)
						PlaySound(GetThemeSound("snd_toggle_off"))
					Else
						SetSpriteImage(_SceneMusicListSimpleEffectToggleSpriteId, GetThemeImage("btn_toggle_on"))
						SetSettingsSimpleEffect(1)
						PlaySound(GetThemeSound("snd_toggle_on"))
					EndIf
				ElseIf GetJButtonPressed(12)
					_SceneMusicListHighlightHoldMarkerToggleAnimProgress = 0.0
					If GetSettingsHighlightHoldMarker()
						SetSpriteImage(_SceneMusicListHighlightHoldMarkerToggleSpriteId, GetThemeImage("btn_toggle_off"))
						SetSettingsHighlightHoldMarker(0)
						PlaySound(GetThemeSound("snd_toggle_off"))
					Else
						SetSpriteImage(_SceneMusicListHighlightHoldMarkerToggleSpriteId, GetThemeImage("btn_toggle_on"))
						SetSettingsHighlightHoldMarker(1)
						PlaySound(GetThemeSound("snd_toggle_on"))
					EndIf
				ElseIf GetSpriteButtonPressed(_SceneMusicListBellSettingsSpriteButtonId)
					_SceneMusicListState = _SceneMusicListStateSettings
				EndIf
				If GetSettingsSimpleEffect()
					inc _SceneMusicListMarkerEffectPlayedTime, GetFrameTime()
					SetSpriteColorAlpha(_SceneMusicListMarkerEffectSpriteId, 255 - 255 * (_SceneMusicListMarkerEffectPlayedTime / SIMPLE_EFFECT_PLAYING_TIME))
					If _SceneMusicListMarkerEffectPlayedTime > 0.4 Then SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 0)
				Else
					SetSpriteColorAlpha(_SceneMusicListMarkerEffectSpriteId, 255)
					If Not GetSpritePlaying(_SceneMusicListMarkerEffectSpriteId) Then SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 0)
				EndIf
				
				If Not GetSpritePlaying(_SceneMusicListMarkerSpriteId) And _SceneMusicListMarkerPlayedTime > 1.0
					SetSpriteVisible(_SceneMusicListMarkerSpriteId, 1)
					PlaySprite(_SceneMusicListMarkerSpriteId, MARKER_FPS, 0)
					_SceneMusicListMarkerPlayedTime = 0.0
				Else
					inc _SceneMusicListMarkerPlayedTime, GetFrameTime()
					If GetJButtonPressed(2) And GetSpriteVisible(_SceneMusicListMarkerSpriteId)
						markerTimeDiff# = _SceneMusicListMarkerPlayedTime - (1.0/MARKER_FPS * 15.5 + GetSettingsInputTiming())
						isEarly = 0
						If markerTimeDiff# < 0.0
							markerTimeDiff# = -markerTimeDiff#
							isEarly = 1
						EndIf
						If markerTimeDiff# < GetSettingsPerfectRange()
							SetSpriteVisible(_SceneMusicListMarkerSpriteId, 0)
							SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 1)
							If GetSettingsSimpleEffect()
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, GetPerfectColorImage())
								_SceneMusicListMarkerEffectPlayedTime = 0.0
								SetSpriteColorAlpha(_SceneMusicListMarkerEffectSpriteId, 255)
							Else
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, _SceneMusicListMarkerImageIds[1])
								SetSpriteAnimation(_SceneMusicListMarkerEffectSpriteId, GetImageWidth(_SceneMusicListMarkerImageIds[1]) / 4, GetImageHeight(_SceneMusicListMarkerImageIds[1]) / 4, 16)
								PlaySprite(_SceneMusicListMarkerEffectSpriteId, 30, 0)
							EndIf
							PlaySound(GetThemeSound("snd_voice_perfect"))
							If GetSettingsPlayClap() Then PlaySound(GetThemeSound("snd_clap"))
						ElseIf markerTimeDiff# < GetSettingsGreatRange()
							SetSpriteVisible(_SceneMusicListMarkerSpriteId, 0)
							SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 1)
							If GetSettingsSimpleEffect()
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, GetGreatColorImage())
								_SceneMusicListMarkerEffectPlayedTime = 0.0
								SetSpriteColorAlpha(_SceneMusicListMarkerEffectSpriteId, 255)
							Else
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, _SceneMusicListMarkerImageIds[2])
								SetSpriteAnimation(_SceneMusicListMarkerEffectSpriteId, GetImageWidth(_SceneMusicListMarkerImageIds[2]) / 4, GetImageHeight(_SceneMusicListMarkerImageIds[2]) / 4, 16)
								PlaySprite(_SceneMusicListMarkerEffectSpriteId, 30, 0)
							EndIf
							PlaySound(GetThemeSound("snd_voice_good"))
							If GetSettingsPlayClap() Then PlaySound(GetThemeSound("snd_clap"))
						ElseIf markerTimeDiff# < GetSettingsGoodRange()
							SetSpriteVisible(_SceneMusicListMarkerSpriteId, 0)
							SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 1)
							If GetSettingsSimpleEffect()
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, GetGoodColorImage())
								_SceneMusicListMarkerEffectPlayedTime = 0.0
								SetSpriteColorAlpha(_SceneMusicListMarkerEffectSpriteId, 255)
							Else
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, _SceneMusicListMarkerImageIds[3])
								SetSpriteAnimation(_SceneMusicListMarkerEffectSpriteId, GetImageWidth(_SceneMusicListMarkerImageIds[3]) / 4, GetImageHeight(_SceneMusicListMarkerImageIds[3]) / 4, 16)
								PlaySprite(_SceneMusicListMarkerEffectSpriteId, 30, 0)
							EndIf
							PlaySound(GetThemeSound("snd_voice_good"))
							If GetSettingsPlayClap() Then PlaySound(GetThemeSound("snd_clap"))
						ElseIf markerTimeDiff# < GetSettingsBadRange()
							SetSpriteVisible(_SceneMusicListMarkerSpriteId, 0)
							SetSpriteVisible(_SceneMusicListMarkerEffectSpriteId, 1)
							If GetSettingsSimpleEffect()
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, GetBadColorImage())
								_SceneMusicListMarkerEffectPlayedTime = 0.0
								SetSpriteColorAlpha(_SceneMusicListMarkerEffectSpriteId, 255)
							Else
								SetSpriteImage(_SceneMusicListMarkerEffectSpriteId, _SceneMusicListMarkerImageIds[4])
								SetSpriteAnimation(_SceneMusicListMarkerEffectSpriteId, GetImageWidth(_SceneMusicListMarkerImageIds[4]) / 4, GetImageHeight(_SceneMusicListMarkerImageIds[4]) / 4, 16)
								PlaySprite(_SceneMusicListMarkerEffectSpriteId, 30, 0)
							EndIf
							If isEarly
								PlaySound(GetThemeSound("snd_voice_early"))
							Else
								PlaySound(GetThemeSound("snd_voice_late"))
							EndIf
							If GetSettingsPlayClap() Then PlaySound(GetThemeSound("snd_clap"))
						EndIf
					EndIf
				EndIf
			EndIf
			If _SceneMusicListBlockButton And GetSpriteButtonDismissed(_SceneMusicListMarkerLeftSpriteButtonId)
				//ModeChange
				WriteSettingsToFile()
				SetSpriteColorAlpha(_SceneMusicListUpperBackEmptySpriteId, 255)
				
				_SceneMusicListSelectedLibraryIndex = -1
				//_SceneMusicListPrevSelectedLibraryIndex
				
				
				
				DeleteSpriteButton(_SceneMusicListMarkerLeftSpriteButtonId)
				_SceneMusicListMarkerLeftSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListMarkerRightSpriteButtonId)
				_SceneMusicListMarkerRightSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListSortingLeftSpriteButtonId)
				_SceneMusicListSortingLeftSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListSortingRightSpriteButtonId)
				_SceneMusicListSortingRightSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListBellBackSpriteButtonId)
				_SceneMusicListBellBackSpriteButtonId = 0
				DeleteSpriteButton(_SceneMusicListBellSettingsSpriteButtonId)
				_SceneMusicListBellSettingsSpriteButtonId = 0
				
				DeleteSprite(_SceneMusicListSortButtonSpriteId)
				_SceneMusicListSortButtonSpriteId = 0
				DeleteText(_SceneMusicListSortButtonTextId)
				_SceneMusicListSortButtonTextId = 0
				DeleteSprite(_SceneMusicListAutoPlayToggleSpriteId)
				_SceneMusicListAutoPlayToggleSpriteId = 0
				DeleteText(_SceneMusicListAutoPlayToggleTextId)
				_SceneMusicListAutoPlayToggleTextId = 0
				DeleteSprite(_SceneMusicListClapSoundToggleSpriteId)
				_SceneMusicListClapSoundToggleSpriteId = 0
				DeleteText(_SceneMusicListClapSoundToggleTextId)
				_SceneMusicListClapSoundToggleTextId = 0
				DeleteSprite(_SceneMusicListSimpleEffectToggleSpriteId)
				_SceneMusicListSimpleEffectToggleSpriteId = 0
				DeleteText(_SceneMusicListSimpleEffectToggleTextId)
				_SceneMusicListSimpleEffectToggleTextId = 0
				DeleteSprite(_SceneMusicListHighlightHoldMarkerToggleSpriteId)
				_SceneMusicListHighlightHoldMarkerToggleSpriteId = 0
				DeleteText(_SceneMusicListHighlightHoldMarkerToggleTextId)
				_SceneMusicListHighlightHoldMarkerToggleTextId = 0
				
				While _SceneMusicListMarkerImageIds.Length >= 0
					DeleteImage(_SceneMusicListMarkerImageIds[_SceneMusicListMarkerImageIds.Length])
					_SceneMusicListMarkerImageIds.Remove()
				EndWhile
				DeleteSprite(_SceneMusicListMarkerSpriteId)
				_SceneMusicListMarkerSpriteId = 0
				DeleteSprite(_SceneMusicListMarkerEffectSpriteId)
				_SceneMusicListMarkerEffectSpriteId = 0
				
				SetSpriteColorAlpha(_SceneMusicListLowerBackEmptySpriteId, 0)
				
				_SceneMusicListState = _SceneMusicListStateList
				_SceneMusicListLifeTime = 0.0
				
				//SetMusicFileVolume(GetThemeMusic("bgm_musiclist"), GetSettingsMusicVolume())
				//PlayMusic(GetThemeMusic("bgm_musiclist"), 1)
				PlaySound(GetThemeSound("snd_voice_selectmusic"))
				
				// create basic buttons
				_SceneMusicListLeftSpriteButtonId = CreateSpriteButton(13, SpriteButtonTypeLeft)
				_SceneMusicListRightSpriteButtonId = CreateSpriteButton(14, SpriteButtonTypeRight)
				_SceneMusicListBellSpriteButtonId = CreateSpriteButton(15, SpriteButtonTypeBell)
				_SceneMusicListNextSpriteButtonId = CreateSpriteButton(16, SpriteButtonTypeNext)
				
				_SceneMusicListCreateMusicButtons()
				_SceneMusicListCurrentCol = 0
				_SceneMusicListUpdateMusicButtonsPosition(0)
			EndIf
		EndCase
		Case _SceneMusicListStateSettings:
			Global _SceneMusicListSettingsInitialized As Integer
			Global _SceneMusicListSettingsBlackImage As Integer
			Global _SceneMusicListSettingsBackSpriteId As Integer
			Global _SceneMusicListSettingsButtonTextIds As Integer[]
			Global _SceneMusicListSettingsKeyTextIds As Integer[]
			Global _SceneMusicListSettingsValueTextIds As Integer[]
			Global _SceneMusicListSettingsCursor As Integer
			Global _SceneMusicListSettingsUpPressingTime As Float
			Global _SceneMusicListSettingsUpRepeatTime As Float
			Global _SceneMusicListSettingsDownPressingTime As Float
			Global _SceneMusicListSettingsDownRepeatTime As Float
			Global _SceneMusicListSettingsLeftPressingTime As Float
			Global _SceneMusicListSettingsLeftRepeatTime As Float
			Global _SceneMusicListSettingsRightPressingTime As Float
			Global _SceneMusicListSettingsRightRepeatTime As Float
			Global _SceneMusicListSettingsLastIsUp As Integer
			Global _SceneMusicListSettingsLastIsLeft As Integer
			Global _SceneMusicListSettingsFirstUseHalfSizeState As Integer
			Global _SceneMusicListSettingsFirstThemeNameState As String
			Global _SceneMusicListSettingsFirstLangFileState As String
			Global _SceneMusicListSettingsGridChanged As Integer
			Global _SceneMusicListSettingsExecuteUpdateLibrary As Integer
			Global _SceneMusicListSettingsExecuteCompactRecord As Integer
			
			Global _SceneMusicListSettingsThemeList As String[]
			Global _SceneMusicListSettingsThemeCurIdx As Integer
			
			Global _SceneMusicListSettingsLangList As LanguageInfo[]
			Global _SceneMusicListSettingsLangCurIdx As Integer
			
			langInfo As LanguageInfo
			langInfo = GetLanguageInfo()
			If Not _SceneMusicListSettingsInitialized
				_SceneMusicListSettingsInitialized = 1
				//_SceneMusicListSettingsCursor = 0
				SpriteButtonDisabled = 1
				
				_SceneMusicListSettingsFirstUseHalfSizeState = GetSettingsUseHalfSizeImage()
				_SceneMusicListSettingsFirstLangFileState = langInfo.File
				_SceneMusicListSettingsFirstThemeNameState = GetSettingsTheme()
				_SceneMusicListSettingsGridChanged = 0
				
				_SceneMusicListSettingsThemeCurIdx = -1
				While _SceneMusicListSettingsThemeList.Length >= 0
					_SceneMusicListSettingsThemeList.Remove()
				EndWhile
				If SetFolder(THEMES_PATH) > 0
					folder$ = GetFirstFolder(0)  //ReadFolder
					While folder$ <> ""
						If GetFileExists(THEMES_PATH + folder$ + "/layout.txt") Then _SceneMusicListSettingsThemeList.Insert(folder$)
						If folder$ = GetSettingsTheme() Then _SceneMusicListSettingsThemeCurIdx = _SceneMusicListSettingsThemeList.Length
						folder$ = GetNextFolder()
					EndWhile
				EndIf
				
				_SceneMusicListSettingsLangCurIdx = -1
				While _SceneMusicListSettingsLangList.Length >= 0
					_SceneMusicListSettingsLangList.Remove()
				EndWhile
				_SceneMusicListSettingsLangList = GetLanguageList()
				For i = 0 To _SceneMusicListSettingsLangList.Length
					If _SceneMusicListSettingsLangList[i].File = langInfo.File Then _SceneMusicListSettingsLangCurIdx = i
				Next
								
				_SceneMusicListSettingsUpPressingTime = 0
				_SceneMusicListSettingsUpRepeatTime = 0
				_SceneMusicListSettingsDownPressingTime = 0
				_SceneMusicListSettingsDownRepeatTime = 0
				_SceneMusicListSettingsLeftPressingTime = 0
				_SceneMusicListSettingsLeftRepeatTime = 0
				_SceneMusicListSettingsRightPressingTime = 0
				_SceneMusicListSettingsRightRepeatTime = 0
				_SceneMusicListSettingsExecuteUpdateLibrary = 0
				_SceneMusicListSettingsExecuteCompactRecord = 0
				_SceneMusicListSettingsBlackImage = CreateImageColor(100, 100, 100, 255)
				_SceneMusicListSettingsBackSpriteId = CreateSprite(_SceneMusicListSettingsBlackImage)
				SetSpritePosition(_SceneMusicListSettingsBackSpriteId, 0, 0)
				SetSpriteSize(_SceneMusicListSettingsBackSpriteId, RESOLUTION_WIDTH, RESOLUTION_HEIGHT)
				SetSpriteDepth(_SceneMusicListSettingsBackSpriteId, DEPTH_SET_BACK)
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText(">"))
				SetTextAngle(_SceneMusicListSettingsButtonTextIds[0], 270)
				SetTextBold(_SceneMusicListSettingsButtonTextIds[0], 1)
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText(">"))
				SetTextAngle(_SceneMusicListSettingsButtonTextIds[1], 90)
				SetTextBold(_SceneMusicListSettingsButtonTextIds[1], 1)
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText(">"))
				SetTextAngle(_SceneMusicListSettingsButtonTextIds[2], 180)
				SetTextBold(_SceneMusicListSettingsButtonTextIds[2], 1)
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText(">"))
				SetTextAngle(_SceneMusicListSettingsButtonTextIds[3], 0)
				SetTextBold(_SceneMusicListSettingsButtonTextIds[3], 1)
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText("Exit"))
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText("Shutdown"+Chr(10)+"System"))
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText("Shutdown"+Chr(10)+"App"))
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText("Restart"+Chr(10)+"App"))
				_SceneMusicListSettingsButtonTextIds.Insert(CreateText("v1.0(170913)"+Chr(10)+"IP "+GetDeviceIP() + Chr(10)+"rsatang5@naver.com"+Chr(10)+"rsatang5.blog.me"))
				
				
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Theme"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Load Half Size Theme Resource"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Language (Requires restarting app)"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Music Volume"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Sound Volume"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Clap Sound Volume"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Clap Sound Timing (AutoPlay Only)"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Note Timing"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Input Timing"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Show FPS (Top Left)"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Show Average Input Timing (Top Right)"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Input Timing Average Counts"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Upper Screen Top Margin"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Upper Screen Left Margin"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Upper Screen Right Margin"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Lower Screen Bottom Margin"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Lower Screen Left Margin"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Lower Screen Right Margin"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Lower Screen Cell Spacing"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Lower Screen Cell Spacing Visible"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Update Music Library (musiclib.dat)"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Flush Play Records (records.dat)"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Perfect Range"))  //idx22
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Great Range"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Good Range"))
				_SceneMusicListSettingsKeyTextIds.Insert(CreateText("Bad Range"))
				
				For i = 0 To _SceneMusicListSettingsKeyTextIds.Length
					_SceneMusicListSettingsValueTextIds.Insert(CreateText(""))
				Next
			EndIf
			
			If GetJButtonPressing(10)
				inc _SceneMusicListSettingsUpPressingTime, GetFrameTime()
				inc _SceneMusicListSettingsUpRepeatTime, GetFrameTime()
			Else
				_SceneMusicListSettingsUpPressingTime = 0.0
				_SceneMusicListSettingsUpRepeatTime = 0.0
			EndIf
			If GetJButtonPressing(14)
				inc _SceneMusicListSettingsDownPressingTime, GetFrameTime()
				inc _SceneMusicListSettingsDownRepeatTime, GetFrameTime()
			Else
				_SceneMusicListSettingsDownPressingTime = 0.0
				_SceneMusicListSettingsDownRepeatTime = 0.0
			EndIf
			If GetJButtonPressing(13)
				inc _SceneMusicListSettingsLeftPressingTime, GetFrameTime()
				inc _SceneMusicListSettingsLeftRepeatTime, GetFrameTime()
			Else
				_SceneMusicListSettingsLeftPressingTime = 0.0
				_SceneMusicListSettingsLeftRepeatTime = 0.0
			EndIf
			If GetJButtonPressing(15)
				inc _SceneMusicListSettingsRightPressingTime, GetFrameTime()
				inc _SceneMusicListSettingsRightRepeatTime, GetFrameTime()
			Else
				_SceneMusicListSettingsRightPressingTime = 0.0
				_SceneMusicListSettingsRightRepeatTime = 0.0
			EndIf
			
			If GetJButtonPressed(10)  // up
				_SceneMusicListSettingsLastIsUp = 1
			ElseIf GetJButtonPressed(14)  // down
				_SceneMusicListSettingsLastIsUp = 0
			ElseIf GetJButtonPressed(13)  // left
				_SceneMusicListSettingsLastIsLeft = 1
			ElseIf GetJButtonPressed(15)  // right
				_SceneMusicListSettingsLastIsLeft = 0
			EndIf
			
			If Not GetJButtonPressing(10) And Not GetJButtonPressing(14) And (GetJButtonPressed(13) Or GetJButtonPressed(15) Or _SceneMusicListSettingsLeftPressingTime > 0.333 And _SceneMusicListSettingsLeftRepeatTime > 0.01 And _SceneMusicListSettingsLastIsLeft Or _SceneMusicListSettingsRightPressingTime > 0.333 And _SceneMusicListSettingsRightRepeatTime > 0.01 And Not _SceneMusicListSettingsLastIsLeft)  // left right
				isRight = Not _SceneMusicListSettingsLastIsLeft
				_SceneMusicListSettingsLeftRepeatTime = 0.0
				_SceneMusicListSettingsRightRepeatTime = 0.0
				
				Select _SceneMusicListSettingsCursor
					Case 0:  // theme
						If _SceneMusicListSettingsThemeList.Length >= 0
							If isRight
								inc _SceneMusicListSettingsThemeCurIdx
								If _SceneMusicListSettingsThemeCurIdx > _SceneMusicListSettingsThemeList.Length Then _SceneMusicListSettingsThemeCurIdx = 0
							Else
								dec _SceneMusicListSettingsThemeCurIdx
								If _SceneMusicListSettingsThemeCurIdx < 0 Then _SceneMusicListSettingsThemeCurIdx = _SceneMusicListSettingsThemeList.Length
							EndIf
							SetSettingsTheme(_SceneMusicListSettingsThemeList[_SceneMusicListSettingsThemeCurIdx])
						EndIf
					EndCase
					Case 1:  // half
						SetSettingsUseHalfSizeImage(IfInteger(GetSettingsUseHalfSizeImage(), 0, 1))
					EndCase
					Case 2:  // language
						If _SceneMusicListSettingsLangList.Length >= 0
							If IsRight
								inc _SceneMusicListSettingsLangCurIdx
								If _SceneMusicListSettingsLangCurIdx > _SceneMusicListSettingsLangList.Length Then _SceneMusicListSettingsLangCurIdx = 0
							Else
								dec _SceneMusicListSettingsLangCurIdx
								If _SceneMusicListSettingsLangCurIdx < 0 Then _SceneMusicListSettingsLangCurIdx = _SceneMusicListSettingsLangList.Length
							EndIf
							SetSettingsLanguage(_SceneMusicListSettingsLangList[_SceneMusicListSettingsLangCurIdx].File)
						EndIf
					EndCase
					Case 3:  // m vol
						SetSettingsMusicVolume(IfInteger(IsRight, GetSettingsMusicVolume() + 1, GetSettingsMusicVolume() - 1))
						If GetMusicPlaying() Then SetMusicFileVolume(GetMusicPlaying(), GetSettingsMusicVolume())
					EndCase
					Case 4:  // s vol
						SetSettingsSoundVolume(IfInteger(IsRight, GetSettingsSoundVolume() + 1, GetSettingsSoundVolume() - 1))
						SetSoundSystemVolume(GetSettingsSoundVolume())
					EndCase
					Case 5:  // c vol
						SetSettingsClapVolume(IfInteger(IsRight, GetSettingsClapVolume() + 1, GetSettingsClapVolume() - 1))
					EndCase
					Case 6:  // c timing
						SetSettingsClapTiming(IfFloat(IsRight, Round(GetSettingsClapTiming() * 1000) * 0.001 + 0.001, Round(GetSettingsClapTiming() * 1000) * 0.001 - 0.001))
					EndCase
					Case 7:  // n timing
						SetSettingsNotesDelayOffset(IfFloat(IsRight, Round(GetSettingsNotesDelayOffset() * 1000) * 0.001 + 0.001, Round(GetSettingsNotesDelayOffset() * 1000) * 0.001 - 0.001))
					EndCase
					Case 8:  // i timing
						SetSettingsInputTiming(IfFloat(IsRight, Round(GetSettingsInputTiming() * 1000) * 0.001 + 0.001, Round(GetSettingsInputTiming() * 1000) * 0.001 - 0.001))
					EndCase
					Case 9:  // fps
						SetSettingsShowFps(IfInteger(GetSettingsShowFps(), 0, 1))
					EndCase
					Case 10:  // show avg timing
						SetSettingsShowAverageInputTiming(IfInteger(GetSettingsShowAverageInputTiming(), 0, 1))
					EndCase
					Case 11:  // avg timing count
						SetSettingsAverageInputTimingCounts(IfInteger(IsRight, GetSettingsAverageInputTimingCounts() + 1, GetSettingsAverageInputTimingCounts() - 1))
					EndCase
					Case 12:  // ust
						SetSettingsUSTop(IfFloat(IsRight, Round(GetSettingsUSTop() * 2) * 0.5 + 0.5, Round(GetSettingsUSTop() * 2) * 0.5 - 0.5))
						_SceneMusicListSettingsGridChanged = 1
						RedrawGrid(100)
					EndCase
					Case 13:  // usl
						SetSettingsUSLeft(IfFloat(IsRight, Round(GetSettingsUSLeft() * 2) * 0.5 + 0.5, Round(GetSettingsUSLeft() * 2) * 0.5 - 0.5))
						_SceneMusicListSettingsGridChanged = 1
						RedrawGrid(100)
					EndCase
					Case 14:  // usr
						SetSettingsUSRight(IfFloat(IsRight, Round(GetSettingsUSRight() * 2) * 0.5 + 0.5, Round(GetSettingsUSRight() * 2) * 0.5 - 0.5))
						_SceneMusicListSettingsGridChanged = 1
						RedrawGrid(100)
					EndCase
					Case 15:  // lsb
						SetSettingsLSBottom(IfFloat(IsRight, Round(GetSettingsLSBottom() * 2) * 0.5 + 0.5, Round(GetSettingsLSBottom() * 2) * 0.5 - 0.5))
						_SceneMusicListSettingsGridChanged = 1
						RedrawGrid(100)
					EndCase
					Case 16:  // lsl
						SetSettingsLSLeft(IfFloat(IsRight, Round(GetSettingsLSLeft() * 2) * 0.5 + 0.5, Round(GetSettingsLSLeft() * 2) * 0.5 - 0.5))
						_SceneMusicListSettingsGridChanged = 1
						RedrawGrid(100)
					EndCase
					Case 17:  // lsr
						SetSettingsLSRight(IfFloat(IsRight, Round(GetSettingsLSRight() * 2) * 0.5 + 0.5, Round(GetSettingsLSRight() * 2) * 0.5 - 0.5))
						_SceneMusicListSettingsGridChanged = 1
						RedrawGrid(100)
					EndCase
					Case 18:  // lss
						SetSettingsLSSpacing(IfFloat(IsRight, Round(GetSettingsLSSpacing() * 2) * 0.5 + 0.5, Round(GetSettingsLSSpacing() * 2) * 0.5 - 0.5))
						_SceneMusicListSettingsGridChanged = 1
						RedrawGrid(100)
					EndCase
					Case 19:  // lssv
						SetSettingsLSSpacingVisible(IfInteger(GetSettingsLSSpacingVisible(), 0, 1))
						If _SceneMusicListSettingsGridChanged
							RedrawGrid(100)
						Else
							RedrawGrid(0)
						EndIf
					EndCase
					Case 20: // update lib
						If IsRight
							inc _SceneMusicListSettingsExecuteUpdateLibrary
							If _SceneMusicListSettingsExecuteUpdateLibrary > 4 Then _SceneMusicListSettingsExecuteUpdateLibrary = 0
						Else
							dec _SceneMusicListSettingsExecuteUpdateLibrary
							If _SceneMusicListSettingsExecuteUpdateLibrary < 0 Then _SceneMusicListSettingsExecuteUpdateLibrary = 4
						EndIf
					EndCase
					Case 21: // compact records
						_SceneMusicListSettingsExecuteCompactRecord = IfInteger(_SceneMusicListSettingsExecuteCompactRecord, 0, 1)
					EndCase
					
					Case 22:  // perfect
						SetSettingsPerfectRange(IfFloat(IsRight, Round(GetSettingsPerfectRange() * 1000) * 0.001 + 0.001, Round(GetSettingsPerfectRange() * 1000) * 0.001 - 0.001))
					EndCase
					Case 23:  // great
						SetSettingsGreatRange(IfFloat(IsRight, Round(GetSettingsGreatRange() * 1000) * 0.001 + 0.001, Round(GetSettingsGreatRange() * 1000) * 0.001 - 0.001))
					EndCase
					Case 24:  // good
						SetSettingsGoodRange(IfFloat(IsRight, Round(GetSettingsGoodRange() * 1000) * 0.001 + 0.001, Round(GetSettingsGoodRange() * 1000) * 0.001 - 0.001))
					EndCase
					Case 25:  // bad
						SetSettingsBadRange(IfFloat(IsRight, Round(GetSettingsBadRange() * 1000) * 0.001 + 0.001, Round(GetSettingsBadRange() * 1000) * 0.001 - 0.001))
					EndCase
					
				EndSelect
			EndIf
			
			If GetJButtonPressed(10) Or _SceneMusicListSettingsUpPressingTime > 0.333 And _SceneMusicListSettingsUpRepeatTime > 0.05 And _SceneMusicListSettingsLastIsUp  //up
				dec _SceneMusicListSettingsCursor, IfInteger(_SceneMusicListSettingsCursor > 0, 1, -_SceneMusicListSettingsKeyTextIds.Length)
				_SceneMusicListSettingsUpRepeatTime = 0.0
			ElseIf GetJButtonPressed(14) Or _SceneMusicListSettingsDownPressingTime > 0.333 And _SceneMusicListSettingsDownRepeatTime > 0.05 And Not _SceneMusicListSettingsLastIsUp //down
				inc _SceneMusicListSettingsCursor, IfInteger(_SceneMusicListSettingsCursor < _SceneMusicListSettingsKeyTextIds.Length, 1, -_SceneMusicListSettingsKeyTextIds.Length)
				_SceneMusicListSettingsDownRepeatTime = 0.0
			ElseIf GetJButtonPressed(4)
				WriteSettingsToFile()
				RunApp(GetReadPath() + "shutdown", "")
				End
			ElseIf GetJButtonPressed(3)
				WriteSettingsToFile()
				End
			ElseIf GetJButtonPressed(2)
				WriteSettingsToFile()
				RunApp(GetReadPath() + GetAppName(), "")
				End
			EndIf
			
			For i = 0 To _SceneMusicListSettingsButtonTextIds.Length
				textId = _SceneMusicListSettingsButtonTextIds[i]
				SetTextSize(textId, GetJButtonSize() * 0.5)
				If i >= 4 Then SetTextSize(textId, GetJButtonSize() * 0.18)
				If i >= 8 Then SetTextSize(textId, GetJButtonSize() * 0.12)
				textAngle# = GetTextCharAngle(textId, 0)
				SetTextPosition(textId, GetJButtonSize() * 0.5 - (Cos(textAngle#) * GetTextTotalWidth(textId) * 0.5) + Sin(textAngle#) * GetTextTotalHeight(textId) * 0.5, GetJButtonSize() * 0.5  - (Sin(textAngle#) * GetTextTotalWidth(textId) * 0.5) - Cos(textAngle#) * GetTextTotalHeight(textId) * 0.5)
			Next
			keyMaxX# = 0.0
			keyMaxX2# = 0.0
			For i = 0 To _SceneMusicListSettingsKeyTextIds.Length
				textId = _SceneMusicListSettingsKeyTextIds[i]
				//SetTextFont(textId, langInfo.Font)
				SetTextSize(textId, GetUpperScreenWidth() * 0.03)
				If i < 22
					SetTextPosition(textId, GetUpperScreenX() + GetUpperScreenWidth() * 0.03, GetUpperScreenY() + (i+1) * GetUpperScreenHeight() / (21/*_SceneMusicListSettingsKeyTextIds.Length*/ + 3))
					keyMaxX# = MaxF(keyMaxX#, GetTextX(textId) + GetTextTotalWidth(textId))
				Else
					SetTextPosition(textId, GetUpperScreenX() + GetUpperScreenWidth() * 0.7, GetUpperScreenY() + (i+1-4) * GetUpperScreenHeight() / (21/*_SceneMusicListSettingsKeyTextIds.Length*/ + 3))
					keyMaxX2# = MaxF(keyMaxX2#, GetTextX(textId) + GetTextTotalWidth(textId))
				EndIf
				
				If i = _SceneMusicListSettingsCursor
					SetTextColor(textId, 255, 0, 127, 255)
					//SetTextBold(textId, 1)
				Else
					SetTextColor(textId, 255, 255, 255, 255)
					//SetTextBold(textId, 0)
				EndIf
			Next
			For i = 0 To _SceneMusicListSettingsValueTextIds.Length
				textId = _SceneMusicListSettingsValueTextIds[i]
				//If i = 2 Then SetTextFont(textId, langInfo.Font)
				SetTextSize(textId, GetUpperScreenWidth() * 0.03)
				If i < 22
					SetTextPosition(textId, keyMaxX# + GetUpperScreenWidth() * 0.01, GetTextY(_SceneMusicListSettingsKeyTextIds[i]))
				Else
					SetTextPosition(textId, keyMaxX2# + GetUpperScreenWidth() * 0.01, GetTextY(_SceneMusicListSettingsKeyTextIds[i]))
				EndIf
				If i = _SceneMusicListSettingsCursor
					SetTextColor(textId, 255, 0, 127, 255)
					SetTextBold(textId, 1)
				Else
					SetTextColor(textId, 255, 255, 255, 255)
					SetTextBold(textId, 0)
				EndIf
			Next
			
			SetTextString(_SceneMusicListSettingsValueTextIds[0], "[" + GetSettingsTheme() + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[1], "[" + IfString(GetSettingsUseHalfSizeImage(), "Enabled", "Disabled") + "]")
			//SetTextString(_SceneMusicListSettingsValueTextIds[2], "[" + langInfo.Name + " - " + langInfo.Author + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[2], "[" + _SceneMusicListSettingsLangList[_SceneMusicListSettingsLangCurIdx].Name + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[3], "[" + Str(GetSettingsMusicVolume()) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[4], "[" + Str(GetSettingsSoundVolume()) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[5], "[" + Str(GetSettingsClapVolume()) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[6], "[" + Str(GetSettingsClapTiming() * 1000, 0) + "ms]")
			SetTextString(_SceneMusicListSettingsValueTextIds[7], "[" + Str(GetSettingsNotesDelayOffset() * 1000, 0) + "ms]")
			SetTextString(_SceneMusicListSettingsValueTextIds[8], "[" + Str(GetSettingsInputTiming() * 1000, 0) + "ms]")
			SetTextString(_SceneMusicListSettingsValueTextIds[9], "[" + IfString(GetSettingsShowFps(), "Enabled", "Disabled") + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[10], "[" + IfString(GetSettingsShowAverageInputTiming(), "Enabled", "Disabled") + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[11], "[" + Str(GetSettingsAverageInputTimingCounts()) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[12], "[" + Str(GetSettingsUSTop(), 1) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[13], "[" + Str(GetSettingsUSLeft(), 1) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[14], "[" + Str(GetSettingsUSRight(), 1) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[15], "[" + Str(GetSettingsLSBottom(), 1) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[16], "[" + Str(GetSettingsLSLeft(), 1) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[17], "[" + Str(GetSettingsLSRight(), 1) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[18], "[" + Str(GetSettingsLSSpacing(), 1) + "]")
			SetTextString(_SceneMusicListSettingsValueTextIds[19], "[" + IfString(GetSettingsLSSpacingVisible(), "Enabled", "Disabled") + "]")
			Select _SceneMusicListSettingsExecuteUpdateLibrary
				Case 0:
					SetTextString(_SceneMusicListSettingsValueTextIds[20], "[Don't Execute]")
				EndCase
				Case 1:
					SetTextString(_SceneMusicListSettingsValueTextIds[20], "[Execute All]")
				EndCase
				Case 2:
					SetTextString(_SceneMusicListSettingsValueTextIds[20], "[Execute New]")
				EndCase
				Case 3:
					SetTextString(_SceneMusicListSettingsValueTextIds[20], "[Execute Last 10]")
				EndCase
				Case 4:
					SetTextString(_SceneMusicListSettingsValueTextIds[20], "[Execute Flush]")
				EndCase
			EndSelect
			SetTextString(_SceneMusicListSettingsValueTextIds[21], "[" + IfString(_SceneMusicListSettingsExecuteCompactRecord, "Execute", "Don't Execute") + "]")
			
			SetTextString(_SceneMusicListSettingsValueTextIds[22], "[" + Str(GetSettingsPerfectRange() * 1000, 0) + "ms]")
			SetTextString(_SceneMusicListSettingsValueTextIds[23], "[" + Str(GetSettingsGreatRange() * 1000, 0) + "ms]")
			SetTextString(_SceneMusicListSettingsValueTextIds[24], "[" + Str(GetSettingsGoodRange() * 1000, 0) + "ms]")
			SetTextString(_SceneMusicListSettingsValueTextIds[25], "[" + Str(GetSettingsBadRange() * 1000, 0) + "ms]")
			
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[0], GetTextX(_SceneMusicListSettingsButtonTextIds[0]) + GetJButtonX(10), GetTextY(_SceneMusicListSettingsButtonTextIds[0]) + GetJButtonY(10))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[1], GetTextX(_SceneMusicListSettingsButtonTextIds[1]) + GetJButtonX(14), GetTextY(_SceneMusicListSettingsButtonTextIds[1]) + GetJButtonY(14))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[2], GetTextX(_SceneMusicListSettingsButtonTextIds[2]) + GetJButtonX(13), GetTextY(_SceneMusicListSettingsButtonTextIds[2]) + GetJButtonY(13))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[3], GetTextX(_SceneMusicListSettingsButtonTextIds[3]) + GetJButtonX(15), GetTextY(_SceneMusicListSettingsButtonTextIds[3]) + GetJButtonY(15))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[4], GetTextX(_SceneMusicListSettingsButtonTextIds[4]) + GetJButtonX(16), GetTextY(_SceneMusicListSettingsButtonTextIds[4]) + GetJButtonY(16))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[5], GetTextX(_SceneMusicListSettingsButtonTextIds[5]) + GetJButtonX(4), GetTextY(_SceneMusicListSettingsButtonTextIds[5]) + GetJButtonY(4))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[6], GetTextX(_SceneMusicListSettingsButtonTextIds[6]) + GetJButtonX(3), GetTextY(_SceneMusicListSettingsButtonTextIds[6]) + GetJButtonY(3))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[7], GetTextX(_SceneMusicListSettingsButtonTextIds[7]) + GetJButtonX(2), GetTextY(_SceneMusicListSettingsButtonTextIds[7]) + GetJButtonY(2))
			SetTextPosition(_SceneMusicListSettingsButtonTextIds[8], GetTextX(_SceneMusicListSettingsButtonTextIds[8]) + GetJButtonX(1), GetTextY(_SceneMusicListSettingsButtonTextIds[8]) + GetJButtonY(1))
			
			
			If GetJButtonPressed(16)
				SpriteButtonDisabled = 0
				If _SceneMusicListSettingsFirstUseHalfSizeState <> GetSettingsUseHalfSizeImage()
					DeleteAllThemeImage()
					SetJButtonGlowImage()
					SceneMusicListSelectedMemoFile = ""
					result = SceneResultEnd
				EndIf
				If _SceneMusicListSettingsFirstThemeNameState <> GetSettingsTheme()
					//DeleteAllThemeImage()
					//DeleteAllThemeMusic()
					//DeleteAllThemeSound()
					//_SceneMusicListDeleteResourcesAndInitializeVars()
					LoadTheme(GetSettingsTheme())
					SetJButtonGlowImage()
					SceneMusicListSelectedMemoFile = ""
					result = SceneResultEnd
				EndIf
				
				If _SceneMusicListSettingsGridChanged
					RedrawGrid(0)
					SceneMusicListSelectedMemoFile = ""
					result = SceneResultEnd
					While _JButtonStateSpriteIds.Length >= 0
						DeleteSprite(_JButtonStateSpriteIds[0])
						_JButtonStateSpriteIds.Remove(0)
					EndWhile
				EndIf
				WriteSettingsToFile()
				_SceneMusicListSettingsInitialized = 0
				DeleteImage(_SceneMusicListSettingsBlackImage)
				_SceneMusicListSettingsBlackImage = 0
				DeleteSprite(_SceneMusicListSettingsBackSpriteId)
				_SceneMusicListSettingsBackSpriteId = 0
				While _SceneMusicListSettingsButtonTextIds.Length >= 0
					DeleteText(_SceneMusicListSettingsButtonTextIds[_SceneMusicListSettingsButtonTextIds.Length])
					_SceneMusicListSettingsButtonTextIds.Remove()
				EndWhile
				While _SceneMusicListSettingsButtonTextIds.Length >= 0
					DeleteText(_SceneMusicListSettingsButtonTextIds[_SceneMusicListSettingsButtonTextIds.Length])
					_SceneMusicListSettingsButtonTextIds.Remove()
				EndWhile
				While _SceneMusicListSettingsKeyTextIds.Length >= 0
					DeleteText(_SceneMusicListSettingsKeyTextIds[_SceneMusicListSettingsKeyTextIds.Length])
					_SceneMusicListSettingsKeyTextIds.Remove()
				EndWhile
				While _SceneMusicListSettingsValueTextIds.Length >= 0
					DeleteText(_SceneMusicListSettingsValueTextIds[_SceneMusicListSettingsValueTextIds.Length])
					_SceneMusicListSettingsValueTextIds.Remove()
				EndWhile
				_SceneMusicListState = _SceneMusicListStateBell
				If result = SceneResultEnd Then _SceneMusicListDeleteResourcesAndInitializeVars()
				
				If _SceneMusicListSettingsExecuteUpdateLibrary
					UpdateMusicLibrary(_SceneMusicListSettingsExecuteUpdateLibrary)
					WriteMusicLibraryToFile()
				EndIf
				
				If _SceneMusicListSettingsExecuteCompactRecord
					CompactMusicRecords()
					WriteMusicRecordsToFile()
				EndIf
				
				While _SceneMusicListSettingsThemeList.Length >= 0
					_SceneMusicListSettingsThemeList.Remove()
				EndWhile
				
				If _SceneMusicListSettingsFirstLangFileState <> GetSettingsLanguage()
					//SetLanguage(GetSettingsLanguage())
					//SetLanguage(_SceneMusicListSettingsLangList[_SceneMusicListSettingsLangCurIdx].File)
					//SceneMusicListSelectedMemoFile = ""
					//result = SceneResultEnd
				EndIf
				While _SceneMusicListSettingsLangList.Length >= 0
					_SceneMusicListSettingsLangList.Remove()
				EndWhile
			EndIf
		EndCase
	EndSelect
	
	If result = SceneResultEnd Then _SceneMusicListLooping = 0
EndFunction result

Function _SceneMusicListGetCoverFromCache(szCover As String)
	If szCover = "" Then ExitFunction 0
	cacheIdx = _SceneMusicListCoverCache.Find(szCover)
	resultImageId = 0
	If cacheIdx >= 0
		resultImageId = _SceneMusicListCoverCache[cacheIdx].ImageId
	ElseIf GetFileExists(MUSIC_PATH + szCover)
		cacheItem As _SceneMusicListCoverCacheItem
		cacheItem.Name = szCover
		cacheItem.ImageId = LoadImage(MUSIC_PATH + szCover)
		cacheItem.AddedTime = Timer()
		resultImageId = cacheItem.ImageId
		_SceneMusicListCoverCache.InsertSorted(cacheItem)
	EndIf
	
	If _SceneMusicListCoverCache.Length >= COVER_CACHE_LENGTH
		oldestIdx = 0
		For i = 1 To _SceneMusicListCoverCache.Length
			If _SceneMusicListCoverCache[i].AddedTime < _SceneMusicListCoverCache[oldestIdx].AddedTime
				oldestIdx = i
			EndIf
		Next
		DeleteImage(_SceneMusicListCoverCache[oldestIdx].ImageId)
		_SceneMusicListCoverCache.Remove(oldestIdx)
	EndIf
EndFunction resultImageId

Function _SceneMusicListFlushCoverCache()
	While _SceneMusicListCoverCache.Length >= 0
		DeleteImage(_SceneMusicListCoverCache[_SceneMusicListCoverCache.Length].ImageId)
		_SceneMusicListCoverCache.Remove()
	EndWhile
EndFunction

Function _SceneMusicListDeleteMusicButtons()
	While _SceneMusicListMusicButtonList.Length >= 0
		idx = _SceneMusicListMusicButtonList.Length
		DeleteSprite(_SceneMusicListMusicButtonList[idx].CoverDefaultSpriteId)
		DeleteSprite(_SceneMusicListMusicButtonList[idx].LevelSpriteId)
		DeleteSprite(_SceneMusicListMusicButtonList[idx].HoldSpriteId)
		DeleteSprite(_SceneMusicListMusicButtonList[idx].CoverSpriteId)
		DeleteText(_SceneMusicListMusicButtonList[idx].TitleTextId)
		While _SceneMusicListMusicButtonList[idx].DifficultyRatingIconSpriteIds.Length >= 0
			DeleteSprite(_SceneMusicListMusicButtonList[idx].DifficultyRatingIconSpriteIds[0])
			_SceneMusicListMusicButtonList[idx].DifficultyRatingIconSpriteIds.Remove(0)
		EndWhile
		_SceneMusicListMusicButtonList.Remove()
	EndWhile
EndFunction

Function _SceneMusicListCreateMusicButtons()
	_SceneMusicListDeleteMusicButtons()
	_SceneMusicListMusicLibraryList = GetMusicLibraryList()
	_SceneMusicListMusicLibrarySortedIndexes = GetMusicLibrarySortedIndexes(GetSettingsSortingMode() / 2, Mod(GetSettingsSortingMode(), 2))
	While _SceneMusicListLibraryDifficultyRatings.Length >= 0
		_SceneMusicListLibraryDifficultyRatings.Remove()
	EndWhile
	For i = 0 To _SceneMusicListMusicLibraryList.Length
		dritem As _SceneMusicListDifficultyRatingItem
		ratings As Integer[3]
		For j = 0 To 3
			sha$ = _SceneMusicListMusicLibraryList[i].Sha256Strings[j]
			If sha$ = ""
				ratings[j] = 0
			Else
				highscore = GetMusicRecordsHighScore(_SceneMusicListMusicLibraryList[i].Sha256Strings[j])
				If highscore > SCORE_EXC
					ratings[j] = 10
				ElseIf highscore > SCORE_SSS
					ratings[j] = 9
				ElseIf highscore > SCORE_SS
					ratings[j] = 8
				ElseIf highscore > SCORE_S
					ratings[j] = 7
				ElseIf highscore > SCORE_A
					ratings[j] = 6
				ElseIf highscore > SCORE_B
					ratings[j] = 5
				ElseIf highscore > SCORE_C
					ratings[j] = 4
				ElseIf highscore > SCORE_D
					ratings[j] = 3
				ElseIf highscore >= 1
					ratings[j] = 2
				Else
					ratings[j] = 1
				EndIf
			EndIf
		Next
		dritem.None = ratings[0]
		dritem.Basic = ratings[1]
		dritem.Advanced = ratings[2]
		dritem.Extreme = ratings[3]
		
		_SceneMusicListLibraryDifficultyRatings.Insert(dritem)
	Next
	
	_SceneMusicListBlockButton = 1
	For i = 0 To 17
		item As _SceneMusicListMusicButtonItem
		item.ColumnOnScreen = -1.0 + (i / 3)
		item.LibraryIndex = -3 + i
		
		// Title
		item.TitleTextId = CreateText("")
		color As ThemeColor
		color = GetThemeColor("mll_title_color")
		SetTextColor(item.TitleTextId, color.Red, color.Green, color.Blue, 255)
		If GetLanguageBoldFont() <> 0
			SetTextFont(item.TitleTextId, GetLanguageBoldFont())
		Else
			SetTextFont(item.TitleTextId, GetLanguageFont())
			SetTextBold(item.TitleTextId, 1)
		EndIf
		SetTextSize(item.TitleTextId, GetJButtonSize() * GetThemeValue("mll_title_size") * GetLanguageFontScale())
		SetTextLineSpacing(item.TitleTextId, GetTextSize(item.TitleTextId) * GetLanguageFontLineSpacing())
		SetTextMaxWidth(item.TitleTextId, GetJButtonSize() * GetThemeValue("mll_title_maxwidth"))
		SetTextAlignment(item.TitleTextId, GetThemeValue("mll_title_align"))
		SetTextDepth(item.TitleTextId, DEPTH_MUSICLIST_MUSICBUTTON_TITLE)
		SetTextY(item.TitleTextId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_title_y"))
		
		// Cover Default
		item.CoverDefaultSpriteId = CreateSprite(GetThemeImage("musiclist_cover_default"))
		SetSpriteSize(item.CoverDefaultSpriteId, GetJButtonSize() * GetThemeValue("mll_coverdefault_width"), GetJButtonSize() * GetThemeValue("mll_coverdefault_height"))
		SetSpriteY(item.CoverDefaultSpriteId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_coverdefault_y"))
		SetSpriteDepth(item.CoverDefaultSpriteId, DEPTH_MUSICLIST_MUSICBUTTON_COVER_DEFAULT)
		
		// Cover
		item.CoverSpriteId = CreateSprite(0)
		SetSpriteTransparency(item.CoverSpriteId, 0)
		SetSpriteSize(item.CoverSpriteId, GetJButtonSize() * GetThemeValue("mll_cover_width"), GetJButtonSize() * GetThemeValue("mll_cover_height"))
		SetSpriteY(item.CoverSpriteId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_cover_y"))
		SetSpriteDepth(item.CoverSpriteId, DEPTH_MUSICLIST_MUSICBUTTON_COVER)
		
		// Level
		item.LevelSpriteId = CreateSprite(GetThemeImage("musiclist_lv"))
		SetSpriteAnimation(item.LevelSpriteId, GetImageWidth(GetThemeImage("musiclist_lv")) / 10, GetImageHeight(GetThemeImage("musiclist_lv")) / 3, 30)
		SetSpriteSize(item.LevelSpriteId, GetJButtonSize() * GetThemeValue("mll_lv_width"), GetJButtonSize() * GetThemeValue("mll_lv_height"))
		SetSpriteY(item.LevelSpriteId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_lv_y"))
		SetSpriteDepth(item.LevelSpriteId, DEPTH_MUSICLIST_MUSICBUTTON_RATING)
		
		// Hold
		item.HoldSpriteId = CreateSprite(GetThemeImage("musiclist_hold"))
		SetSpriteSize(item.HoldSpriteId, GetJButtonSize() * GetThemeValue("mll_hold_width"), GetJButtonSize() * GetThemeValue("mll_hold_height"))
		SetSpriteY(item.HoldSpriteId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_hold_y"))
		SetSpriteDepth(item.HoldSpriteId, DEPTH_MUSICLIST_MUSICBUTTON_RATING)
		
		// Ratings
		For j = 0 To 3
			item.DifficultyRatingIconSpriteIds[j] = CreateSprite(GetThemeImage("musiclist_rating"))
			SetSpriteAnimation(item.DifficultyRatingIconSpriteIds[j], GetImageWidth(GetThemeImage("musiclist_rating")) / 10, GetImageHeight(GetThemeImage("musiclist_rating")) / 3, 50)
			SetSpriteSize(item.DifficultyRatingIconSpriteIds[j], GetJButtonSize() * GetThemeValue("mll_rating_width"), GetJButtonSize() * GetThemeValue("mll_rating_height"))
			SetSpriteDepth(item.DifficultyRatingIconSpriteIds[j], DEPTH_MUSICLIST_MUSICBUTTON_RATING)
		Next
		
		// insert to array
		_SceneMusicListMusicButtonList.Insert(item)
	Next
	_SceneMusicListMusicButtonsCreatedTime = Timer()
EndFunction

Function _SceneMusicListUpdateMusicButtonsPosition(col As Integer)
	colOffset# = 0.0
	titleX# = GetJButtonSize() * GetThemeValue("mll_title_x")
	levelX# = GetJButtonSize() * GetThemeValue("mll_lv_x")
	holdX# = GetJButtonSize() * GetThemeValue("mll_hold_x")
	coverX# = GetJButtonSize() * GetThemeValue("mll_cover_x")
	coverDefX# = GetJButtonSize() * GetThemeValue("mll_coverdefault_x")
	coverWidth# = GetJButtonSize() * GetThemeValue("mll_cover_width")
	coverHeight# = GetJButtonSize() * GetThemeValue("mll_cover_height")
	coverDefWidth# = GetJButtonSize() * GetThemeValue("mll_coverdefault_width")
	coverDefHeight# = GetJButtonSize() * GetThemeValue("mll_coverdefault_height")
	diskX# = GetJButtonSize() * GetThemeValue("mll_disk_x")
	themeTitleY# = GetThemeValue("mll_title_y")
	themeTitleValign# = GetThemeValue("mll_title_valign")
	
	// LibraryIndex not exists in array
	If _SceneMusicListMusicButtonList[0].LibraryIndex > col * 3
		// Move to right (inc col)
		colOffset# = MinF(GetFrameTime() * 7.0, _SceneMusicListMusicButtonList[0].LibraryIndex - col * 3 - _SceneMusicListMusicButtonList[0].ColumnOnScreen)
	ElseIf _SceneMusicListMusicButtonList[15].LibraryIndex < col * 3
		// Move to left (dec col)
		colOffset# = -MinF(GetFrameTime() * 7.0, col * 3 - _SceneMusicListMusicButtonList[15].LibraryIndex + _SceneMusicListMusicButtonList[0].ColumnOnScreen)
	// LibraryIndex exists in array
	Else
		For i = 0 To 15 Step 3
			If _SceneMusicListMusicButtonList[i].LibraryIndex = col * 3
				If _SceneMusicListMusicButtonList[i].ColumnOnScreen < 0.0
					// Move to right (inc col)
					colOffset# = MinF(GetFrameTime() * 7.0, - _SceneMusicListMusicButtonList[i].ColumnOnScreen)
				ElseIf _SceneMusicListMusicButtonList[i].ColumnOnScreen > 0.0
					// Move to left (dec col)
					colOffset# = -MinF(GetFrameTime() * 7.0, _SceneMusicListMusicButtonList[i].ColumnOnScreen)
				EndIf
			EndIf
		Next i
	EndIf
	
	// Change ColOnScreen
	For i = 0 To 17
		inc _SceneMusicListMusicButtonList[i].ColumnOnScreen, colOffset#
	Next
	
	// Align
	While _SceneMusicListMusicButtonList[0].ColumnOnScreen < -1.0
		For i = 0 To 2
			inc _SceneMusicListMusicButtonList[0].ColumnOnScreen, 6.0
			inc _SceneMusicListMusicButtonList[0].LibraryIndex, 6 * 3
			_SceneMusicListMusicButtonList.Insert(_SceneMusicListMusicButtonList[0])
			_SceneMusicListMusicButtonList.Remove(0)
		Next
	EndWhile
	While _SceneMusicListMusicButtonList[15].ColumnOnScreen > 4.0
		For i = 0 To 2
			dec _SceneMusicListMusicButtonList[15 + i].ColumnOnScreen, 6.0
			dec _SceneMusicListMusicButtonList[15 + i].LibraryIndex, 6 * 3
			_SceneMusicListMusicButtonList.Insert(_SceneMusicListMusicButtonList[15 + i], i)
			_SceneMusicListMusicButtonList.Remove(16 + i)
		Next
	EndWhile
	
	// assign text and image
	For i = 0 To 17
		If 0 <= _SceneMusicListMusicButtonList[i].LibraryIndex And _SceneMusicListMusicButtonList[i].LibraryIndex <= _SceneMusicListMusicLibraryList.Length
			libIdx = _SceneMusicListMusicLibrarySortedIndexes[_SceneMusicListMusicButtonList[i].LibraryIndex]
			SetTextString(_SceneMusicListMusicButtonList[i].TitleTextId, _SceneMusicListMusicLibraryList[libIdx].Title)
			SetTextY(_SceneMusicListMusicButtonList[i].TitleTextId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * themeTitleY#)
			Select themeTitleValign#
				Case 1.0:
					SetTextY(_SceneMusicListMusicButtonList[i].TitleTextId, GetTextY(_SceneMusicListMusicButtonList[i].TitleTextId) - GetTextTotalHeight(_SceneMusicListMusicButtonList[i].TitleTextId) * 0.5)
				EndCase
				Case 2.0:
					SetTextY(_SceneMusicListMusicButtonList[i].TitleTextId, GetTextY(_SceneMusicListMusicButtonList[i].TitleTextId) - GetTextTotalHeight(_SceneMusicListMusicButtonList[i].TitleTextId))
				EndCase
			EndSelect
			SetSpriteVisible(_SceneMusicListMusicButtonList[i].CoverDefaultSpriteId, 1)
			SetSpriteVisible(_SceneMusicListMusicButtonList[i].CoverSpriteId, 1)
			If _SceneMusicListCurrentDifficulty >= 0
				If _SceneMusicListMusicLibraryList[libIdx].Sha256Strings[_SceneMusicListCurrentDifficulty] <> ""
					SetSpriteVisible(_SceneMusicListMusicButtonList[i].LevelSpriteId, 1)
					SetSpriteVisible(_SceneMusicListMusicButtonList[i].HoldSpriteId, _SceneMusicListMusicLibraryList[libIdx].HoldsCounts[_SceneMusicListCurrentDifficulty] > 0)
					SetSpriteFrame(_SceneMusicListMusicButtonList[i].LevelSpriteId, (_SceneMusicListCurrentDifficulty-1)*10 + _SceneMusicListMusicLibraryList[libIdx].Levels[_SceneMusicListCurrentDifficulty])
				Else
					SetSpriteVisible(_SceneMusicListMusicButtonList[i].LevelSpriteId, 0)
					SetSpriteVisible(_SceneMusicListMusicButtonList[i].HoldSpriteId, 0)
				EndIf
			Else
				SetSpriteVisible(_SceneMusicListMusicButtonList[i].LevelSpriteId, 0)
				SetSpriteVisible(_SceneMusicListMusicButtonList[i].HoldSpriteId, 0)
			EndIf
			
			If _SceneMusicListMusicLibraryList[libIdx].CoverFile <> ""
				SetSpriteImage(_SceneMusicListMusicButtonList[i].CoverSpriteId, _SceneMusicListGetCoverFromCache(_SceneMusicListMusicLibraryList[libIdx].CoverFile))
			Else
				SetSpriteVisible(_SceneMusicListMusicButtonList[i].CoverSpriteId, 0)
			EndIf
			
			frames As Integer[3]
			frames[0] = _SceneMusicListLibraryDifficultyRatings[libIdx].None
			frames[1] = _SceneMusicListLibraryDifficultyRatings[libIdx].Basic + 10
			If _SceneMusicListLibraryDifficultyRatings[libIdx].Basic = 0 Then frames[1] = 0
			frames[2] = _SceneMusicListLibraryDifficultyRatings[libIdx].Advanced + 20
			If _SceneMusicListLibraryDifficultyRatings[libIdx].Advanced = 0 Then frames[2] = 0
			frames[3] = _SceneMusicListLibraryDifficultyRatings[libIdx].Extreme + 30
			If _SceneMusicListLibraryDifficultyRatings[libIdx].Extreme = 0 Then frames[3] = 0
			For j = 3 To 0
				If frames[j] = 0
					// push array by using k
					For k = j-1 To 0
						frames[k+1] = frames[k]
					Next
					frames[0] = 0
				EndIf
			Next
			For j = 0 To 3
				If frames[j] = 0
					SetSpriteVisible(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[j], 0)
				Else
					SetSpriteVisible(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[j], 1)
					SetSpriteFrame(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[j], frames[j] - 10)
				EndIf
			Next
		Else
			SetTextString(_SceneMusicListMusicButtonList[i].TitleTextId, "")
			SetSpriteVisible(_SceneMusicListMusicButtonList[i].CoverDefaultSpriteId, 0)
			SetSpriteVisible(_SceneMusicListMusicButtonList[i].CoverSpriteId, 0)
			SetSpriteVisible(_SceneMusicListMusicButtonList[i].LevelSpriteId, 0)
			SetSpriteVisible(_SceneMusicListMusicButtonList[i].HoldSpriteId, 0)
			For j = 0 To 3
				SetSpriteVisible(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[j], 0)
			Next
		EndIf
	Next
	
	// Move and size sprites and texts
	SetSpriteVisible(_SceneMusicListSpinningDiskSpriteId, (_SceneMusicListSelectedLibraryIndex >= 0))
	themeRatingX# = GetThemeValue("mll_rating_x")
	themeRatingY# = GetThemeValue("mll_rating_y")
	themeRatingS# = GetThemeValue("mll_rating_spacing")
	themeRatingD# = GetThemeValue("mll_rating_direction")
	If Timer() - _SceneMusicListMusicButtonsCreatedTime <= MUSICLIST_BUTTONS_CREATING_ANIM_TIME * 1.5
		// Creating Animation Time
		For i = 0 To 17
			commonX# = GetJButtonX(1) + _SceneMusicListMusicButtonList[i].ColumnOnScreen * (GetJButtonX(2) - GetJButtonX(1))
			If i < 3 Or 14 < i
				commonX# = GetJButtonX(1) - (GetJButtonX(2) - GetJButtonX(1))
			EndIf
			
			prog# = ((Timer() - _SceneMusicListMusicButtonsCreatedTime) - MUSICLIST_BUTTONS_CREATING_ANIM_TIME / 12 * i) / (MUSICLIST_BUTTONS_CREATING_ANIM_TIME / 12)
			prog# = prog# * 0.5
			If prog# > 1.0 Then prog# = 1.0
			If prog# < 0.0 Then prog# = 0.0
			prog# = Sin(prog# * 90.0)
			
			SetTextColorAlpha(_SceneMusicListMusicButtonList[i].TitleTextId, 255 * prog#)
			SetTextX(_SceneMusicListMusicButtonList[i].TitleTextId, commonX# + titleX#)
			SetSpriteSize(_SceneMusicListMusicButtonList[i].CoverDefaultSpriteId, MaxF(0.0, coverDefWidth# * prog#), coverDefHeight#)
			SetSpriteX(_SceneMusicListMusicButtonList[i].CoverDefaultSpriteId, commonX# + coverDefX# + (1.0 - prog#) * coverDefWidth# / 2)
			SetSpriteSize(_SceneMusicListMusicButtonList[i].CoverSpriteId, MaxF(0.0, coverWidth# * prog#), coverHeight#)
			SetSpriteX(_SceneMusicListMusicButtonList[i].CoverSpriteId, commonX# + coverX# + (1.0 - prog#) * coverWidth# / 2)
			SetSpriteX(_SceneMusicListMusicButtonList[i].LevelSpriteId, commonX# + levelX#)
			SetSpriteX(_SceneMusicListMusicButtonList[i].HoldSpriteId, commonX# + holdX#)
			
			commonY# = GetJButtonY(Mod(i, 3) * 4 + 1)
			For j = 0 To 3
				SetSpritePosition(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[j], commonX# + GetJButtonSize() * themeRatingX# + Cos(themeRatingD#) * GetJButtonSize() * themeRatingS# * j, commonY# + GetJButtonSize() * themeRatingY# + Sin(themeRatingD#) * GetJButtonSize() * themeRatingS# * j)
				SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[j], 255 * prog#)
				SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].LevelSpriteId, 255 * prog#)
				SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].HoldSpriteId, 255 * prog#)
			Next
		Next
	Else
		// Not Creating Animation Time
		_SceneMusicListBlockButton = 0
		
		diskScale# = 0.0
		
		For i = 0 To 17
			SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[0], 255)
			SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[1], 255)
			SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[2], 255)
			SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[3], 255)
			SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].LevelSpriteId, 255)
			SetSpriteColorAlpha(_SceneMusicListMusicButtonList[i].HoldSpriteId, 255)
			
			commonX# = GetJButtonX(1) + _SceneMusicListMusicButtonList[i].ColumnOnScreen * (GetJButtonX(2) - GetJButtonX(1))
			SetTextX(_SceneMusicListMusicButtonList[i].TitleTextId, commonX# + titleX#)
			SetSpriteX(_SceneMusicListMusicButtonList[i].LevelSpriteId, commonX# + levelX#)
			SetSpriteX(_SceneMusicListMusicButtonList[i].HoldSpriteId, commonX# + holdX#)
			coverScale# = 1.0
			If 0 <= _SceneMusicListMusicButtonList[i].LibraryIndex And _SceneMusicListMusicButtonList[i].LibraryIndex <= _SceneMusicListMusicLibraryList.Length
				libIdx = _SceneMusicListMusicLibrarySortedIndexes[_SceneMusicListMusicButtonList[i].LibraryIndex]
				SetTextColorAlpha(_SceneMusicListMusicButtonList[i].TitleTextId, 255)
				If _SceneMusicListMusicButtonList[i].LibraryIndex = _SceneMusicListSelectedLibraryIndex
					If Timer() - _SceneMusicListMusicButtonsSelectedTime <= MUSICLIST_BUTTONS_DISK_ANIM_TIME
						cprog# = (Timer() - _SceneMusicListMusicButtonsSelectedTime) / (MUSICLIST_BUTTONS_DISK_ANIM_TIME * 0.5)
						coverScale# = 1.0 - Sin(MaxF(MinF(cprog#, 1.0), 0.0) * 90.0)
						dprog# = ((Timer() - _SceneMusicListMusicButtonsSelectedTime) - MUSICLIST_BUTTONS_DISK_ANIM_TIME * 0.5) / (MUSICLIST_BUTTONS_DISK_ANIM_TIME * 0.5)
						dprog# = Sin(MaxF(MinF(dprog#, 1.0), 0.0) * 90.0)  // 0.0 to 1.0
						If dprog# > 0.0
							//SetSpriteVisible(_SceneMusicListSpinningDiskSpriteId, 1)
							SetSpriteFrame(_SceneMusicListSpinningDiskSpriteId, _SceneMusicListSelectedDifficulty + 1)
							diskScale# = dprog#
							inc diskX#, commonX#
							SetSpriteY(_SceneMusicListSpinningDiskSpriteId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_disk_y"))
						EndIf
					Else
						//SetSpriteVisible(_SceneMusicListSpinningDiskSpriteId, 1)
						SetSpriteFrame(_SceneMusicListSpinningDiskSpriteId, _SceneMusicListSelectedDifficulty + 1)
						SetSpriteY(_SceneMusicListSpinningDiskSpriteId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_disk_y"))  //bug fix
						diskScale# = 1.0
						inc diskX#, commonX#
						coverScale# = 0.0
					EndIf
				ElseIf _SceneMusicListMusicButtonList[i].LibraryIndex = _SceneMusicListPrevSelectedLibraryIndex
					If Timer() - _SceneMusicListMusicButtonsSelectedTime <= MUSICLIST_BUTTONS_DISK_ANIM_TIME
						dprog# = (Timer() - _SceneMusicListMusicButtonsSelectedTime) / (MUSICLIST_BUTTONS_DISK_ANIM_TIME * 0.5)
						dprog# = Sin(MaxF(MinF(dprog#, 1.0), 0.0) * 90.0 + 90.0)  // 1.0 to 0.0
						If 0.0 < dprog# And dprog# < 1.0
							//SetSpriteVisible(_SceneMusicListSpinningDiskSpriteId, 1)
							SetSpriteFrame(_SceneMusicListSpinningDiskSpriteId, _SceneMusicListPrevSelectedDifficulty + 1)
							diskScale# = dprog#
							inc diskX#, commonX#
							SetSpriteY(_SceneMusicListSpinningDiskSpriteId, GetJButtonY(Mod(i, 3) * 4 + 1) + GetJButtonSize() * GetThemeValue("mll_disk_y"))
						EndIf
						
						cprog# = ((Timer() - _SceneMusicListMusicButtonsSelectedTime) - MUSICLIST_BUTTONS_DISK_ANIM_TIME * 0.5) / (MUSICLIST_BUTTONS_DISK_ANIM_TIME * 0.5)
						coverScale# = Sin(MaxF(MinF(cprog#, 1.0), 0.0) * 90.0)
					EndIf
				EndIf
				
				// ratings
				commonY# = GetJButtonY(Mod(i, 3) * 4 + 1)
				For j = 0 To 3
					SetSpritePosition(_SceneMusicListMusicButtonList[i].DifficultyRatingIconSpriteIds[j], commonX# + GetJButtonSize() * themeRatingX# + Cos(themeRatingD#) * GetJButtonSize() * themeRatingS# * j, commonY# + GetJButtonSize() * themeRatingY# + Sin(themeRatingD#) * GetJButtonSize() * themeRatingS# * j)
				Next
			EndIf
			
			// cover
			SetSpriteSize(_SceneMusicListMusicButtonList[i].CoverDefaultSpriteId, MaxF(0.0, coverDefWidth# * coverScale#), coverDefHeight#)
			SetSpriteX(_SceneMusicListMusicButtonList[i].CoverDefaultSpriteId, commonX# + coverDefX# + (1.0 - coverScale#) * coverDefWidth# * 0.5)
			SetSpriteSize(_SceneMusicListMusicButtonList[i].CoverSpriteId, MaxF(0.0, coverWidth# * coverScale#), coverHeight#)
			SetSpriteX(_SceneMusicListMusicButtonList[i].CoverSpriteId, commonX# + coverX# + (1.0 - coverScale#) * coverWidth# * 0.5)
		Next
		//disk
		SetSpriteSize(_SceneMusicListSpinningDiskSpriteId, MaxF(0.0, GetJButtonSize() * GetThemeValue("mll_disk_width") * diskScale#), GetJButtonSize() * GetThemeValue("mll_disk_height"))
		SetSpriteX(_SceneMusicListSpinningDiskSpriteId, /*commonX# + */diskX# + (1.0 - diskScale#) * GetJButtonSize() * GetThemeValue("mll_disk_width") / 2.0)
	EndIf
EndFunction

Function _SceneMusicListDeleteResourcesAndInitializeVars()
	// Back image
	DeleteSprite(_SceneMusicListUpperBackSpriteId)
	_SceneMusicListUpperBackSpriteId = 0
	DeleteSprite(_SceneMusicListUpperBackEmptySpriteId)
	_SceneMusicListUpperBackEmptySpriteId = 0
	DeleteSprite(_SceneMusicListLowerBackSpriteId)
	_SceneMusicListLowerBackSpriteId = 0
	DeleteSprite(_SceneMusicListLowerBackEmptySpriteId)
	_SceneMusicListLowerBackEmptySpriteId = 0

	// Sprite buttons
	DeleteSpriteButton(_SceneMusicListLeftSpriteButtonId)
	_SceneMusicListLeftSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListRightSpriteButtonId)
	_SceneMusicListRightSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListBellSpriteButtonId)
	_SceneMusicListBellSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListNextSpriteButtonId)
	_SceneMusicListNextSpriteButtonId = 0

	// Music List
	While _SceneMusicListLibraryDifficultyRatings.Length >= 0
		_SceneMusicListLibraryDifficultyRatings.Remove()
	EndWhile
	While _SceneMusicListMusicLibraryList.Length >= 0
		_SceneMusicListMusicLibraryList.Remove()
	EndWhile
	While _SceneMusicListMusicLibrarySortedIndexes.Length >= 0
		_SceneMusicListMusicLibrarySortedIndexes.Remove()
	EndWhile
	_SceneMusicListDeleteMusicButtons()
	DeleteSprite(_SceneMusicListSpinningDiskSpriteId)
	_SceneMusicListSpinningDiskSpriteId = 0
	_SceneMusicListCurrentCol = 0
	_SceneMusicListSelectedLibraryIndex = -1
	_SceneMusicListPrevSelectedLibraryIndex = -2
	//_SceneMusicListCurrentDifficulty = 0
	_SceneMusicListSelectedDifficulty = 0
	_SceneMusicListPrevSelectedDifficulty = 0
	If _SceneMusicListPrelisteningMusicId > 0 Then DeleteMusic(_SceneMusicListPrelisteningMusicId)
	_SceneMusicListPrelisteningMusicId = 0
	_SceneMusicListPrelisteningMusicMuteTime = 0.0

	// Upper screen
	DeleteSprite(_SceneMusicListUpperScreenCoverSpriteId)
	_SceneMusicListUpperScreenCoverSpriteId = 0
	DeleteText(_SceneMusicListUpperScreenTitleTextId)
	_SceneMusicListUpperScreenTitleTextId = 0
	DeleteText(_SceneMusicListUpperScreenArtistTextId)
	_SceneMusicListUpperScreenArtistTextId = 0
	DeleteText(_SceneMusicListUpperScreenBpmTextId)
	_SceneMusicListUpperScreenBpmTextId = 0
	DeleteText(_SceneMusicListUpperScreenNotesTextId)
	_SceneMusicListUpperScreenNotesTextId = 0
	DeleteText(_SceneMusicListUpperScreenLastplayedTextId)
	_SceneMusicListUpperScreenLastplayedTextId = 0
	DeleteText(_SceneMusicListUpperScreenHighScoreTimeTextId)
	_SceneMusicListUpperScreenHighScoreTimeTextId = 0
	DeleteText(_SceneMusicListUpperScreenMusicLengthTextId)
	_SceneMusicListUpperScreenMusicLengthTextId = 0
	DeleteSprite(_SceneMusicListUpperScreenDifficultySpriteId)
	_SceneMusicListUpperScreenDifficultySpriteId = 0
	DeleteSprite(_SceneMusicListUpperScreenLevelSpriteId)
	_SceneMusicListUpperScreenLevelSpriteId = 0
	While _SceneMusicListUpperScreenHighScoreDigitSpriteIds.Length >= 0
		DeleteSprite(_SceneMusicListUpperScreenHighScoreDigitSpriteIds[_SceneMusicListUpperScreenHighScoreDigitSpriteIds.Length])
		_SceneMusicListUpperScreenHighScoreDigitSpriteIds.Remove()
	EndWhile
	DeleteSprite(_SceneMusicListUpperScreenRatingSpriteId)
	_SceneMusicListUpperScreenRatingSpriteId = 0
	DeleteSprite(_SceneMusicListUpperScreenFullComboSpriteId)
	_SceneMusicListUpperScreenFullComboSpriteId = 0
	While _SceneMusicListUpperScreenMusicBarDotSpriteIds.Length >= 0
		DeleteSprite(_SceneMusicListUpperScreenMusicBarDotSpriteIds[_SceneMusicListUpperScreenMusicBarDotSpriteIds.Length])
		_SceneMusicListUpperScreenMusicBarDotSpriteIds.Remove()
	EndWhile
	_SceneMusicListUpperScreenMusicBarStartX = 0.0
	_SceneMusicListUpperScreenMusicBarEndX = 0.0
	_SceneMusicListUpperScreenMusicBarY = 0.0
	
	// bell
	While _SceneMusicListMarkerImageIds.Length >= 0
		DeleteImage(_SceneMusicListMarkerImageIds[_SceneMusicListMarkerImageIds.Length])
		_SceneMusicListMarkerImageIds.Remove()
	EndWhile
	DeleteSprite(_SceneMusicListMarkerBackSpriteId)
	_SceneMusicListMarkerBackSpriteId = 0
	DeleteSprite(_SceneMusicListMarkerSpriteId)
	_SceneMusicListMarkerSpriteId = 0
	DeleteSprite(_SceneMusicListSortButtonSpriteId)
	_SceneMusicListSortButtonSpriteId = 0
	DeleteText(_SceneMusicListSortButtonTextId)
	_SceneMusicListSortButtonTextId = 0
	DeleteSprite(_SceneMusicListAutoPlayToggleSpriteId)
	_SceneMusicListAutoPlayToggleSpriteId = 0
	DeleteText(_SceneMusicListAutoPlayToggleTextId)
	_SceneMusicListAutoPlayToggleTextId = 0
	DeleteSprite(_SceneMusicListClapSoundToggleSpriteId)
	_SceneMusicListClapSoundToggleSpriteId = 0
	DeleteText(_SceneMusicListClapSoundToggleTextId)
	_SceneMusicListClapSoundToggleTextId = 0
	DeleteSprite(_SceneMusicListSimpleEffectToggleSpriteId)
	_SceneMusicListSimpleEffectToggleSpriteId = 0
	DeleteText(_SceneMusicListSimpleEffectToggleTextId)
	_SceneMusicListSimpleEffectToggleTextId = 0
	DeleteSprite(_SceneMusicListHighlightHoldMarkerToggleSpriteId)
	_SceneMusicListHighlightHoldMarkerToggleSpriteId = 0
	DeleteText(_SceneMusicListHighlightHoldMarkerToggleTextId)
	_SceneMusicListHighlightHoldMarkerToggleTextId = 0
	DeleteSprite(_SceneMusicListMarkerEffectSpriteId)
	_SceneMusicListMarkerEffectSpriteId = 0
	DeleteSpriteButton(_SceneMusicListMarkerLeftSpriteButtonId)
	_SceneMusicListMarkerLeftSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListMarkerRightSpriteButtonId)
	_SceneMusicListMarkerRightSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListSortingLeftSpriteButtonId)
	_SceneMusicListMarkerLeftSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListSortingRightSpriteButtonId)
	_SceneMusicListMarkerRightSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListBellBackSpriteButtonId)
	_SceneMusicListBellBackSpriteButtonId = 0
	DeleteSpriteButton(_SceneMusicListBellSettingsSpriteButtonId)
	_SceneMusicListBellSettingsSpriteButtonId = 0
	
	// Cover cache
	_SceneMusicListFlushCoverCache()

	// For anim
	_SceneMusicListMusicButtonsCreatedTime = 0.0
	_SceneMusicListMusicButtonsSelectedTime = 0.0
	
	//NTO
	DeleteSprite(_SceneMusicListNTOSpriteId)
	_SceneMusicListNTOSpriteId = 0
	DeleteText(_SceneMusicListNTOTextId)
	_SceneMusicListNTOTextId = 0
EndFunction
