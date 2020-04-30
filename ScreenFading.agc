#include "Constants.agc"

#constant SCREEN_FADING_TIME (0.25)

Global _ScreenFadingSpriteId As Integer = 0
Global _ScreenFadingFactor As Float = 1.0
Global _ScreenFadingFadeOutMode As Integer = 1

Function UpdateScreenFading()
	If _ScreenFadingSpriteId = 0
		_ScreenFadingSpriteId = CreateSprite(CreateImageColor(0, 0, 0, 255))
		SetSpritePosition(_ScreenFadingSpriteId, 0, 0)
		SetSpriteSize(_ScreenFadingSpriteId, RESOLUTION_WIDTH, RESOLUTION_HEIGHT)
		SetSpriteDepth(_ScreenFadingSpriteId, DEPTH_SCREEN_FADING)
		SetSpriteColorAlpha(_ScreenFadingSpriteId, 0)
	EndIf
	If _ScreenFadingFadeOutMode
		inc _ScreenFadingFactor, GetFrameTime() / SCREEN_FADING_TIME
		If _ScreenFadingFactor > 1.0 Then _ScreenFadingFactor = 1.0
	Else
		dec _ScreenFadingFactor, GetFrameTime() / SCREEN_FADING_TIME
		If _ScreenFadingFactor < 0.0 Then _ScreenFadingFactor = 0.0
	EndIf
	SetSpriteColorAlpha(_ScreenFadingSpriteId, 255 * _ScreenFadingFactor)
EndFunction

Function StartScreenFadeOut()
	_ScreenFadingFadeOutMode = 1
EndFunction

Function StartScreenFadeIn()
	_ScreenFadingFadeOutMode = 0
EndFunction

Function GetScreenFadeOutCompleted()
EndFunction _ScreenFadingFactor >= 1.0

Function GetScreenFadeInCompleted()
EndFunction _ScreenFadingFactor <= 0.0
