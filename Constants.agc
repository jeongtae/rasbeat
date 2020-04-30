#constant DEBUG_MODE (0)

#constant INTEGER_MIN (-2147483648)
#constant INTEGER_MAX (2147483647)

// Scan Codes @ https://www.appgamekit.com/documentation/guides/scancodes.htm
#constant KEY_ESCAPE 27
#constant KEY_SPACE 13
#constant KEY_1 49
#constant KEY_2 50
#constant KEY_3 51
#constant KEY_4 52
#constant KEY_Q 81
#constant KEY_W 87
#constant KEY_E 69
#constant KEY_R 82
#constant KEY_A 65
#constant KEY_S 83
#constant KEY_D 68
#constant KEY_F 70
#constant KEY_Z 90
#constant KEY_X 88
#constant KEY_C 67
#constant KEY_V 86

#constant READ_PATH ("/media/")
#constant LANG_PATH ("/media/lang/")
#constant MUSIC_PATH ("/media/music/")
#constant FONTS_PATH ("/media/fonts/")
#constant UIRES_PATH ("/media/ui/")
#constant THEMES_PATH ("/media/themes/")
#constant MARKERS_PATH ("/media/markers/")

#constant RESOLUTION_WIDTH (1080)
#constant RESOLUTION_HEIGHT (1920)
/*
#constant INGAME_JUDGE_ALLOWING_TIME_PERFECT (0.042)
#constant INGAME_JUDGE_ALLOWING_TIME_GREAT (0.084)
#constant INGAME_JUDGE_ALLOWING_TIME_GOOD (0.126)
#constant INGAME_JUDGE_ALLOWING_TIME_BAD (0.252)
*/
#constant SCORE_EXC (1000000)
#constant SCORE_SSS (980000)
#constant SCORE_SS (950000)
#constant SCORE_S (900000)
#constant SCORE_A (850000)
#constant SCORE_B (800000)
#constant SCORE_C (700000)
#constant SCORE_D (500000)

/* Depth */

// General
#constant DEPTH_ERROR_REPORTING (0)
#constant DEPTH_GRID (100)
#constant DEPTH_SCREEN_FADING (101)
#constant DEPTH_FPS (130)
#constant DEPTH_FPS_BACK (131)
#constant DEPTH_SPRITE_BUTTON (200)
#constant DEPTH_BUTTON_GLOW (125)

// System Settings
#constant DEPTH_SET_TEXT (110)
#constant DEPTH_SET_BACK (120)

// Library
#constant DEPTH_LIB_TEXT (110)
#constant DEPTH_LIB_PROG_BAR (113)
#constant DEPTH_LIB_PROG_BAR_BACK (115)
#constant DEPTH_LIB_PROG_BACK (117)
#constant DEPTH_LIB_BACK (120)

#constant COVER_CACHE_LENGTH (48)

// Music List - Upper Screen
#constant DEPTH_MUSICLISTSCREEN_BACK_EMPTY (148)
#constant DEPTH_MUSICLISTSCREEN_TEXTS (150)
#constant DEPTH_MUSICLISTSCREEN_MUSIC_BAR_DOT (150)
#constant DEPTH_MUSICLISTSCREEN_BACK (190)
// Music List - LowerScreen
#constant DEPTH_MUSICLIST_MARKER (290)
#constant DEPTH_MUSICLIST_MARKEREFFECT (291)
#constant DEPTH_MUSICLIST_MARKERBACK (292)
#constant DEPTH_MUSICLIST_TOGGLEBUTTON_TEXT (295)
#constant DEPTH_MUSICLIST_TOGGLEBUTTON (296)
#constant DEPTH_MUSICLIST_BACK_EMPTY (301)
#constant DEPTH_MUSICLIST_MUSICBUTTON_RATING (305)
#constant DEPTH_MUSICLIST_MUSICBUTTON_DISK (310)
#constant DEPTH_MUSICLIST_MUSICBUTTON_COVER (330)
#constant DEPTH_MUSICLIST_MUSICBUTTON_COVER_DEFAULT (340)
#constant DEPTH_MUSICLIST_MUSICBUTTON_TITLE (345)
#constant DEPTH_MUSICLIST_BACK (350)

// In Game - Upper Screen
#constant DEPTH_SCREEN_READY (160)
#constant DEPTH_SCREEN_MUSIC_BAR_BAR (163)
#constant DEPTH_SCREEN_MUSIC_BAR_DOT (165)
#constant DEPTH_SCREEN_COVER (167)
#constant DEPTH_SCREEN_TEXTS (170)
#constant DEPTH_SCREEN_BACK (190)
// In Game - Lower Screen
#constant DEPTH_BG_GO (205)
#constant DEPTH_START_HERE (207)
#constant DEPTH_HOLDGLOW (208)
#constant DEPTH_MARKER (209)
#constant DEPTH_ARROWGLOW (210)
#constant DEPTH_ARROW (211)
#constant DEPTH_LASER (212)
#constant DEPTH_ARROWBORDER (213)
#constant DEPTH_JUDGEMENT_EFFECT (220)
#constant DEPTH_RATING_CHAR (231)
#constant DEPTH_RATING_TEXT (233)
#constant DEPTH_CLEARED_BIG (235)
#constant DEPTH_CLEARED_SMALL (236)
#constant DEPTH_CLEARED_BACKFADE (237)
#constant DEPTH_FULLCOMBO (238)
#constant DEPTH_FULLCOMBO_BACKFADE (239)
#constant DEPTH_COMBO_ZERO (240)
#constant DEPTH_COMBO (241)
#constant DEPTH_BG_SHUTTER_TOP (300)
#constant DEPTH_BG_SHUTTER_BOTTOM (310)
#constant DEPTH_BG_SHUTTER_PARTICLES (320)
#constant DEPTH_BG_SHUTTER_BACK_FADE2 (330)
#constant DEPTH_BG_SHUTTER_BACK_FADE1 (340)
#constant DEPTH_BG_SHUTTER_BACK (350)
// Background
//#constant DEPTH_BACKGROUND (10000)

#constant MARKER_FPS (30.0)

#constant SPRITE_BUTTON_APPEARING_TIME (0.25)
#constant SPRITE_BUTTON_APPEARING_SCALING_FACTOR (0.7)
#constant SPRITE_BUTTON_HIGHLIGHTING_SCALING_TIME (0.15)
#constant SPRITE_BUTTON_HIGHLIGHTING_SCALING_FACTOR (0.90)
#constant SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME1 (0.05)
#constant SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME2 (0.4)
#constant SPRITE_BUTTON_DISMISSING_DELAY (0.475)
#constant SPRITE_BUTTON_DISMISSING_TIME (0.15)
#constant SPRITE_BUTTON_DISMISSING_SCALING_FACTOR (0.7)

#constant MUSICLIST_BUTTONS_CREATING_ANIM_TIME (1.2)
#constant MUSICLIST_BUTTONS_DISK_ANIM_TIME (0.25)

#constant INGAME_PREPARING_TEXT_FADE_START (0.5)
#constant INGAME_PREPARING_TEXT_FADE_END (1.0)
#constant INGAME_PREPARING_READY_START (0.5)
#constant INGAME_PREPARING_READY_END (2.0)
#constant INGAME_PREPARING_GO_START (2.2)
#constant INGAME_PREPARING_GO_END (3.2)
#constant INGAME_PREPARING_END (3.2)
#constant INGAME_START_HERE_DISMISSING_TIME (0.5)
#constant INGAME_START_HERE_DISMISSING_OFFSET (-0.5)
#constant INGAME_WATING_BEFORE_MUSIC_START (1.5)
#constant INGAME_WATING_AFTER_MUSIC_END (4.5)

#constant INGAME_BONUS_COUNT_PERFECTGREAT (2)
#constant INGAME_BONUS_COUNT_GOOD (1)
#constant INGAME_BONUS_COUNT_BADMISS (-4)

#constant INGAME_BEATBOUNCE_OFFSET (-0.080)
#constant INGAME_BEATBOUNCE_UP_TIME (0.060)

#constant INGAME_COMBO_DIGIT_SHAKING_TIME (0.08)

#constant ERROR_REPORTING_DISMISSING_START (9.5)
#constant ERROR_REPORTING_DISMISSING_END (10.0)
#constant ERROR_REPORTING_MOVING_SPEED (200)
#constant ERROR_REPORTING_FONT_SIZE (24)

#constant SceneResultContinue (0)
#constant SceneResultEnd (1)

Function MaxI(a As Integer, b As Integer)
	If a > b Then ExitFunction a
EndFunction b

Function MinI(a As Integer, b As Integer)
	If a < b Then ExitFunction a
EndFunction b

Function MaxF(a As Float, b As Float)
	If a > b Then ExitFunction a
EndFunction b

Function MinF(a As Float, b As Float)
	If a < b Then ExitFunction a
EndFunction b

Function DeleteSpritesInArray(arr Ref As Integer[])
	While arr.Length >= 0
		If GetSpriteExists(arr[arr.Length]) Then DeleteSprite(arr[arr.Length])
		arr.Remove()
	EndWhile
EndFunction

Function GetDayOfWeekFromUnix(unixtime As Integer)
	res = Mod((floor(unixtime / 86400) + 4), 7)
EndFunction res

Global _FixUnitTimeLocalToUtcOffset As Integer = 0
Global _FixUnitTimeLocalToUtcCalculated As Integer = 0
Function FixUnixTimeLocalToUtc(unixtime As Integer)
	If Not _FixUnitTimeLocalToUtcCalculated
		timestr$ = GetCurrentTime()
		datestr$ = GetCurrentDate()
		timeval = GetUnixTime()
		time2 = Val(GetStringToken2(timestr$, ":", 1)) * 3600 + Val(GetStringToken2(timestr$, ":", 2)) * 60 + Val(GetStringToken2(timestr$, ":", 3)) // H*3600 + M*60 + S
		time1 = GetHoursFromUnix(timeval) * 3600 + GetMinutesFromUnix(timeval) * 60 + GetSecondsFromUnix(timeval) // 9
		
		day2 = Val(GetStringToken2(datestr$, ":", 3))
		day1 = GetDaysFromUnix(timeval)
		
		If day2 <> day1
			If day2 > day1 And day2 - day1 < 15
				inc day2, 3600*24
			Else
				inc day1, 3600*24
			EndIf
		EndIf
		
		_FixUnitTimeLocalToUtcOffset = time2 - time1
		
		_FixUnitTimeLocalToUtcCalculated = 1
	EndIf
EndFunction unixtime + _FixUnitTimeLocalToUtcOffset

Function IfInteger(criteria As Integer, t As Integer, f As Integer)
	result As Integer
	If criteria
		result = t
	Else
		result = f
	EndIf
EndFunction result

Function IfFloat(criteria As Integer, t As Float, f As Float)
	result As Float
	If criteria
		result = t
	Else
		result = f
	EndIf
EndFunction result

Function IfString(criteria As Integer, t As String, f As String)
	result As String
	If criteria
		result = t
	Else
		result = f
	EndIf
EndFunction result


Function GetTimeElapsedString(unixtime1 As Integer, unixtime2 As Integer)
	unixtime1 = FixUnixTimeLocalToUtc(unixtime1)
	unixtime1Date = unixtime1 - GetHoursFromUnix(unixtime1)*3600 - GetMinutesFromUnix(unixtime1)*60 - GetSecondsFromUnix(unixtime1)
	unixtime1DateWeek = unixtime1Date - GetDayOfWeekFromUnix(unixtime1Date) * 3600 * 24
	unixtime2 = FixUnixTimeLocalToUtc(GetUnixTime())
	unixtime2Date = unixtime2 - GetHoursFromUnix(unixtime2)*3600 - GetMinutesFromUnix(unixtime2)*60 - GetSecondsFromUnix(unixtime2)
	unixtime2DateWeek = unixtime2Date - GetDayOfWeekFromUnix(unixtime2Date) * 3600 * 24
	timediff = unixtime2 - unixtime1
	datediff = (unixtime2Date - unixtime1Date) / (3600 * 24)
	weekdiff = (unixtime2DateWeek - unixtime1DateWeek) / (3600 * 24 * 7)
	resultText$ = ""
	If GetMonthFromUnix(unixtime1) <> GetMonthFromUnix(unixtime2) And weekdiff >=  4  // 1 month and 4 weeks
		resultText$ = GetLocalizedString("TIME_YM")
		resultText$ = ReplaceString(resultText$, "%y", Str(GetYearFromUnix(unixtime1)), -1)
		resultText$ = ReplaceString(resultText$, "%m", Str(GetMonthFromUnix(unixtime1)), -1)
		//resultText$ = ReplaceString(resultText$, "%d", Str(GetDaysFromUnix(unixtime1)), -1)
	ElseIf weekdiff >= 2  // 2 weeks
		resultText$ = GetLocalizedString("TIME_W_WEEKS_AGO")
		resultText$ = ReplaceString(resultText$, "%w", Str(weekdiff), -1)
	ElseIf weekdiff = 1 And datediff >= 7 // 1 week and 7 days
		resultText$ = GetLocalizedString("TIME_LAST_WEEK")
	ElseIf datediff >= 2  // 2 days
		resultText$ = GetLocalizedString("TIME_D_DAYS_AGO")
		resultText$ = ReplaceString(resultText$, "%d", Str(datediff), -1)
	ElseIf datediff = 1 /*And timediff >= 3600 * 12 */ // 1 day and 12 hours
		resultText$ = GetLocalizedString("TIME_YESTERDAY")
	ElseIf timediff >= 3600 - 30
		resultText$ = GetLocalizedString("TIME_H_HOURS_AGO")
		resultText$ = ReplaceString(resultText$, "%h", Str(Round(timediff / 1200.0)/3), -1)
	ElseIf timediff >= 30
		resultText$ = GetLocalizedString("TIME_M_MINUTES_AGO")
		resultText$ = ReplaceString(resultText$, "%m", Str(Round(timediff / 60.0)), -1)
	Else
		resultText$ = GetLocalizedString("TIME_MOMENT_AGO")
	EndIf
EndFunction resultText$


Function GetSortingString(iValue As Integer)
	Global SortingStrings As String[12] = ["SETTINGS_SORT_BY_TITLE", "SETTINGS_SORT_BY_ARTIST",
	"SETTINGS_SORT_BY_LEVELBASIC", "SETTINGS_SORT_BY_LEVELADVANCED", "SETTINGS_SORT_BY_LEVELEXTREME",
	"SETTINGS_SORT_BY_HIGHSCOREALL",
	"SETTINGS_SORT_BY_HIGHSCOREBASIC", "SETTINGS_SORT_BY_HIGHSCOREADVANCED", "SETTINGS_SORT_BY_HIGHSCOREEXTREME",
	"SETTINGS_SORT_BY_LASTPLAYEDTIMEALL",
	"SETTINGS_SORT_BY_LASTPLAYEDTIMEBASIC", "SETTINGS_SORT_BY_LASTPLAYEDTIMEADVANCED", "SETTINGS_SORT_BY_LASTPLAYEDTIMEEXTREME"]
	If 0 <= iValue And iValue <= SortingStrings.Length Then ExitFunction SortingStrings[iValue]
EndFunction ""
Function GetSortingStringLastIndex()
EndFunction SortingStrings.Length


#constant SIMPLE_EFFECT_PLAYING_TIME (0.5)
