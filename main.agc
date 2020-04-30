// Project: Rasbeat 
// Author: Jeongtae Kim
// Created: 2017-07-02

#include "Constants.agc"
#include "JMemoParser.agc"
#include "Localizing.agc"
#include "GridDrawing.agc"
#include "SceneInGame.agc"
#include "SceneMusicList.agc"
#include "ButtonState.agc"
#include "SpriteButton.agc"
#include "ThemeLoader.agc"
#include "ErrorReporting.agc"
#include "Settings.agc"
#include "MusicRecords.agc"
#include "MusicLibrary.agc"
#include "ScreenFading.agc"
#include "NoteTimingOffsets.agc"
#include "TextSettings.agc"


/* App Configuration */

SetErrorMode(1)  // Reporting Errors
SetWindowTitle("Rasbeat")
SetWindowSize(450, 800, 1)
//SetScreenResolution(1080, 1920)
//UpdateDeviceSize(450,800)
//MaximizeWindow()
SetScissor(0, 0, 0, 0)
//SetWindowAllowResize(1) // allow the user to resize the window
SetVirtualResolution(RESOLUTION_WIDTH, RESOLUTION_HEIGHT) // doesn't have to match the window
//SetDisplayAspect ( 1080.0/1920.0 )
EnableClearColor(0)
//SetClearColor(0, 0, 0)
//SetOrientationAllowed(1, 1, 0, 0) // allow both portrait and landscape on mobile devices (port1 port2 land1 land2)
SetSyncRate(0, 0) // 30fps instead of 60 to save battery
SetVSync(0)
SetAntialiasMode(0)
SetScissor(0, 0, 0, 0) // use the maximum available screen space, no black borders
UseNewDefaultFonts(1) // since version 2.0.22 we can use nicer default fonts
SetPrintFont(0)
SetPrintColor(255, 0, 255)
SetGenerateMipmaps(0)
//SetBorderColor(255,0,0)
SetMusicSystemVolume(10)

Sync()
Sleep(500)
Sync()

/* Load Settings */

LoadTextSettings()
ReadSettingsFromFile()
RedrawGrid(0)
SetLanguage(GetSettingsLanguage())
//SetPrintFont(GetLanguageBoldFont())
If Not GetFileExists(THEMES_PATH + GetSettingsTheme() + "/layout.txt")
	If SetFolder(THEMES_PATH) > 0
		folder$ = GetFirstFolder(0)  //ReadFolder
		While folder$ <> ""
			If GetFileExists(THEMES_PATH + folder$ + "/layout.txt") Then SetSettingsTheme(folder$)
			folder$ = GetNextFolder()
		EndWhile
	EndIf
EndIf
LoadTheme(GetSettingsTheme())

//UpdateMusicLibrary()
//WriteMusicLibraryToFile()

ReadMusicLibraryFromFile()
ReadMusicRecordsFromFile()
ReadNoteTimingOffsetsFromFile()
//WriteMusicRecordsToFile()
SetMusicSystemVolume(100)
SetSoundSystemVolume(GetSettingsSoundVolume())

/* Game State */

#constant GameStateNone 0
#constant GameStateSplash 1
#constant GameStateTitle 2
#constant GameStateMusicList 3
#constant GameStateSystemSettings 4
#constant GameStateInGame 5
Global GameState As Integer = GameStateSplash
GameState = GameStateMusicList
//GameState = GameStateInGame

/* FPS */
_mainFpsText = CreateText("- FPS")
SetTextAlignment(_mainFpsText, 0)
SetTextDepth(_mainFpsText, DEPTH_FPS)
//SetTextColor(_mainFpsText, 255, 0, 255, 255)

_mainFpsBack = CreateSprite(CreateImageColor(0, 0, 0, 63))
SetSpriteDepth(_mainFpsBack, DEPTH_FPS_BACK)

_mainAverageInputTimingText = CreateText("-ms")
SetTextAlignment(_mainAverageInputTimingText, 2)
SetTextDepth(_mainAverageInputTimingText, DEPTH_FPS)

_mainAverageInputTimingBack = CreateSprite(GetSpriteImageID(_mainFpsBack))
SetSpriteDepth(_mainAverageInputTimingBack, DEPTH_FPS_BACK)

Global MainAverageInputTimingValues As Float[]
Global MainAverageInputTimingValuesSum As Float

Global _mainIdleTime As Float


/* Main Loop */

Do
	// Exit app when pressed esc key
	If GetRawKeyPressed(KEY_ESCAPE) Then End
	
	//Print(GetManagedSpriteCount())
	
	// idle time
	inc _mainIdleTime, GetFrameTime()
	
	// Updates
	UpdateJButtonStates()  // Update button input states
	UpdateSpriteButtons()  // Update sprite buttons
	UpdateErrorReporting()  // Update error reporting texts
	UpdateScreenFading()
	
	If GameState = GameStateInGame And _SceneInGameState = _SceneInGameStatePlaying Then _mainIdleTime = 0.0
	If _mainIdleTime > 30.0
		SetSyncRate(15, 0)
	Else
		SetSyncRate(0, 0)
	EndIf
	
	// Print FPS
    If GetSettingsShowFps()
		SetSpriteVisible(_mainFpsBack, 1)
		SetTextVisible(_mainFpsText, 1)
		roundFps = Round(ScreenFPS())
		SetTextString(_mainFpsText, Str(roundFps) + " FPS")
		If roundFps >= 59
			SetTextColor(_mainFpsText, 255, 255, 255, 255)
		ElseIf roundFps >= 50
			SetTextColor(_mainFpsText, 255, 255, 0, 255)
		ElseIf roundFps >= 40
			SetTextColor(_mainFpsText, 200, 0, 0, 255)
		EndIf
		If GameState <> GameStateInGame
			SetTextPosition(_mainFpsText, GetUpperScreenX() + GetUpperScreenWidth() * 0.01, GetUpperScreenY() + GetUpperScreenHeight() * 0.01)
			SetTextSize(_mainFpsText, GetUpperScreenWidth() * 0.03)
			SetSpritePosition(_mainFpsBack, GetTextX(_mainFpsText) - GetTextTotalWidth(_mainFpsText) * 0.1, GetTextY(_mainFpsText))
			SetSpriteSize(_mainFpsBack, GetTextTotalWidth(_mainFpsText) * 1.2, GetTextTotalHeight(_mainFpsText))
		Else
			SetTextPosition(_mainFpsText, GetLowerScreenX() + GetLowerScreenWidth() * 0.01, GetLowerScreenY() + GetLowerScreenHeight() * 0.01)
			SetTextSize(_mainFpsText, GetLowerScreenWidth() * 0.03)
			SetSpritePosition(_mainFpsBack, GetTextX(_mainFpsText) - GetTextTotalWidth(_mainFpsText) * 0.1, GetTextY(_mainFpsText))
			SetSpriteSize(_mainFpsBack, GetTextTotalWidth(_mainFpsText) * 1.2, GetTextTotalHeight(_mainFpsText))
		EndIf
    Else
		SetSpriteVisible(_mainFpsBack, 0)
		SetTextVisible(_mainFpsText, 0)
	EndIf
	
	
	// Print average input timing
	If GetSettingsShowAverageInputTiming()
		SetSpriteVisible(_mainAverageInputTimingBack, 1)
		SetTextVisible(_mainAverageInputTimingText, 1)
		If MainAverageInputTimingValues.Length < 0
			SetTextString(_mainAverageInputTimingText, "0ms")
		Else
			SetTextString(_mainAverageInputTimingText, Str(Round(MainAverageInputTimingValuesSum / (MainAverageInputTimingValues.Length + 1) * 1000)) + "ms")
		EndIf
		If GameState <> GameStateInGame
			SetTextPosition(_mainAverageInputTimingText, GetUpperScreenX() + GetUpperScreenWidth() * (1.0 - 0.01), GetUpperScreenY() + GetUpperScreenHeight() * 0.01)
			SetTextSize(_mainAverageInputTimingText, GetUpperScreenWidth() * 0.03)
			SetSpritePosition(_mainAverageInputTimingBack, GetTextX(_mainAverageInputTimingText) - GetTextTotalWidth(_mainAverageInputTimingText) * 1.1, GetTextY(_mainAverageInputTimingText))
			SetSpriteSize(_mainAverageInputTimingBack, GetTextTotalWidth(_mainAverageInputTimingText) * 1.2, GetTextTotalHeight(_mainAverageInputTimingText))
		Else
			SetTextPosition(_mainAverageInputTimingText, GetLowerScreenX() + GetLowerScreenWidth() * (1.0 - 0.01), GetLowerScreenY() + GetLowerScreenHeight() * 0.01)
			SetTextSize(_mainAverageInputTimingText, GetLowerScreenWidth() * 0.03)
			SetSpritePosition(_mainAverageInputTimingBack, GetTextX(_mainAverageInputTimingText) - GetTextTotalWidth(_mainAverageInputTimingText) * 1.1, GetTextY(_mainAverageInputTimingText))
			SetSpriteSize(_mainAverageInputTimingBack, GetTextTotalWidth(_mainAverageInputTimingText) * 1.2, GetTextTotalHeight(_mainAverageInputTimingText))
		EndIf
	Else
		SetSpriteVisible(_mainAverageInputTimingBack, 0)
		SetTextVisible(_mainAverageInputTimingText, 0)
	EndIf
	
	// Scene loops
	sceneResult = 0
	Select GameState
		Case GameStateNone:
			GameState = GameStateSplash
		EndCase
		Case GameStateMusicList:
			sceneResult = SceneMusicListLoop()
			If sceneResult = SceneResultEnd
				If SceneMusicListSelectedMemoFile = ""
					GameState = GameStateMusicList
				Else
					GameState = GameStateInGame
				EndIf
			EndIf
		EndCase
		Case GameStateInGame:
			SceneInGameMemoFile = SceneMusicListSelectedMemoFile
			//SceneInGameMemoFile = "sky_high_basic.txt"  // FOR DEBUGGING
			SceneInGameAutoplay = GetSettingsAutoPlay()
			sceneResult = SceneInGameLoop()
			If sceneResult = SceneResultEnd
				If SceneInGameRetry
					GameState = GameStateInGame
				Else
					GameState = GameStateMusicList
				EndIf
			EndIf
		EndCase
	EndSelect
	
	// Render frame
    Sync()
Loop
