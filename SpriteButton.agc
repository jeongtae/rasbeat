#include "Constants.agc"
#include "GridDrawing.agc"
#include "ThemeLoader.agc"

#constant SpriteButtonTypeBack (1)
#constant SpriteButtonTypeNext(2)
#constant SpriteButtonTypeRetry (3)
#constant SpriteButtonTypeBell (4)
#constant SpriteButtonTypeLeft (5)
#constant SpriteButtonTypeRight (6)
#constant SpriteButtonTypeQuit (7)
#constant SpriteButtonTypeSettings (8)

Global SpriteButtonDisabled As Integer

Type _SpriteButton
	Id As Integer  // 1~10000
	ButtonType As Integer
	JButtonIndex As Integer // 1~16
	BaseSprite As Integer
	HighlightSprite As Integer
	LifeTime As Float
	PressedTime As Float
	Pressed As Integer
	Dismissing As Integer
	DismissingDelayLeft As Float
	DismissingTime As Float
	Dismissed As Integer
EndType
Global _SpriteButtons As _SpriteButton[]  // index is button sprite id

Function CreateSpriteButton(iBtn As Integer, iBtnType As Integer)
	If iBtn < 1 Or iBtn > 16 Then ExitFunction 0
	
	spriteButton As _SpriteButton
	spriteButton.Id = 1
	While _SpriteButtons.Find(spriteButton.Id) >= 0
		spriteButton.id = Random(1, 10000)
	EndWhile
	
	spriteButton.ButtonType = iBtnType
	spriteButton.JButtonIndex = iBtn
	baseImage = 0
	highlightImage = 0
	Select iBtnType
		Case SpriteButtonTypeBack:
			baseImage = GetThemeImage("btn_back")
			highlightImage = GetThemeImage("btn_back_highlight")
		EndCase
		Case SpriteButtonTypeNext:
			baseImage = GetThemeImage("btn_next")
			highlightImage = GetThemeImage("btn_next_highlight")
		EndCase
		Case SpriteButtonTypeRetry:
			baseImage = GetThemeImage("btn_retry")
			highlightImage = GetThemeImage("btn_retry_highlight")
		EndCase
		Case SpriteButtonTypeBell:
			baseImage = GetThemeImage("btn_bell")
			highlightImage = GetThemeImage("btn_bell_highlight")
		EndCase
		Case SpriteButtonTypeLeft:
			baseImage = GetThemeImage("btn_left")
			highlightImage = GetThemeImage("btn_left_highlight")
		EndCase
		Case SpriteButtonTypeRight:
			baseImage = GetThemeImage("btn_right")
			highlightImage = GetThemeImage("btn_right_highlight")
		EndCase
		Case SpriteButtonTypeQuit:
			baseImage = GetThemeImage("btn_quit")
			highlightImage = GetThemeImage("btn_quit_highlight")
		EndCase
		Case SpriteButtonTypeSettings:
			baseImage = GetThemeImage("btn_settings")
			highlightImage = GetThemeImage("btn_settings_highlight")
		EndCase
	EndSelect
	baseSprite = CreateSprite(baseImage)
	spriteButton.BaseSprite = baseSprite
	highlightSprite = CreateSprite(highlightImage)
	spriteButton.HighlightSprite = highlightSprite
	spriteButton.LifeTime = 0.0
	spriteButton.PressedTime = 0.0
	spriteButton.Pressed = 0
	spriteButton.Dismissing = 0
	spriteButton.DismissingDelayLeft = 0.0
	spriteButton.DismissingTime = 0.0
	spriteButton.Dismissed = 0
	
	SetSpriteSize(baseSprite, GetJButtonSize(), GetJButtonSize())
	SetSpriteSize(highlightSprite, GetJButtonSize(), GetJButtonSize())
	
	SetSpriteScale(baseSprite, 0.0, 0.0)
	
	SetSpritePosition(baseSprite, GetJButtonX(iBtn), GetJButtonY(iBtn))
	SetSpritePosition(highlightSprite, GetJButtonX(iBtn), GetJButtonY(iBtn))
	
	SetSpriteDepth(baseSprite, DEPTH_SPRITE_BUTTON)
	SetSpriteDepth(highlightSprite, DEPTH_SPRITE_BUTTON - 1)
	
	//SetSpriteTransparency(baseSprite, 0)
	SetSpriteColorAlpha(highlightSprite, 0)
	
	_SpriteButtons.InsertSorted(spriteButton)
EndFunction spriteButton.Id

Function GetSpriteButtonPressed(iSpriteBtnId As Integer)
	idx = _SpriteButtons.Find(iSpriteBtnId)
	If idx >= 0
		If _SpriteButtons[idx].LifeTime >= SPRITE_BUTTON_APPEARING_TIME And Not _SpriteButtons[idx].Dismissing Then ExitFunction GetJButtonPressed(_SpriteButtons[idx].JButtonIndex) 
	EndIf
EndFunction 0

Function DismissSpriteButton(iSpriteBtnId As Integer, iHasDelay As Integer)
	idx = _SpriteButtons.Find(iSpriteBtnId)
	If idx >= 0
		If Not _SpriteButtons[idx].Dismissing
			_SpriteButtons[idx].Dismissing = 1
			If iHasDelay Then _SpriteButtons[idx].DismissingDelayLeft = SPRITE_BUTTON_DISMISSING_DELAY
		EndIf
	EndIf
EndFunction

Function GetSpriteButtonDismissed(iSpriteBtnId As Integer)
	idx = _SpriteButtons.Find(iSpriteBtnId)
	If idx >= 0 Then ExitFunction _SpriteButtons[idx].Dismissed
EndFunction 0

Function GetSpriteButtonDismissing(iSpriteBtnId As Integer)
	idx = _SpriteButtons.Find(iSpriteBtnId)
	If idx >= 0 Then ExitFunction _SpriteButtons[idx].Dismissing
EndFunction 0

Function DeleteSpriteButton(iSpriteBtnId As Integer)
	idx = _SpriteButtons.Find(iSpriteBtnId)
	If idx >= 0 
		DeleteSprite(_SpriteButtons[idx].BaseSprite)
		DeleteSprite(_SpriteButtons[idx].HighlightSprite)
		_SpriteButtons.Remove(idx)
	EndIf
EndFunction

Function UpdateSpriteButtons()
	For i = 0 To _SpriteButtons.Length Step 1
		// Increase timers
		inc _SpriteButtons[i].LifeTime, GetFrameTime()
		`inc _SpriteButtons[i].PressedTime, GetFrameTime()
		
		// Get sprite button from array, and init variables
		spriteButton As _SpriteButton
		spriteButton = _SpriteButtons[i]
		lifeTime# = spriteButton.LifeTime
		baseSprite = spriteButton.BaseSprite
		highlightSprite = spriteButton.HighlightSprite
		jBtnIdx = spriteButton.JButtonIndex
		pressedTime# = spriteButton.PressedTime
		dismissingTime# = spriteButton.DismissingTime
		
		// Appearing (cant push button while appearing)
		If lifeTime# < SPRITE_BUTTON_APPEARING_TIME
			SetSpriteColorAlpha(spriteButton.BaseSprite, (lifeTime# / SPRITE_BUTTON_APPEARING_TIME) ^ 2 * 255)
			_SpriteButtonSetScale(i, SPRITE_BUTTON_APPEARING_SCALING_FACTOR + (lifeTime# / SPRITE_BUTTON_APPEARING_TIME) * (1.0 - SPRITE_BUTTON_APPEARING_SCALING_FACTOR))
		// Dismissing
		ElseIf spriteButton.Dismissing And spriteButton.DismissingDelayLeft <= 0.0
			SetSpriteColorAlpha(spriteButton.HighlightSprite, 0)
			
			_SpriteButtonSetScale(i, SPRITE_BUTTON_DISMISSING_SCALING_FACTOR + MaxF(1.0 - dismissingTime# / SPRITE_BUTTON_DISMISSING_TIME, 0.0) * (1.0 - SPRITE_BUTTON_DISMISSING_SCALING_FACTOR))
			SetSpriteColorAlpha(spriteButton.BaseSprite, MaxI(255.0 -(dismissingTime# / SPRITE_BUTTON_DISMISSING_TIME) ^ 0.5 * 255.0, 0))
			If DismissingTime# > SPRITE_BUTTON_DISMISSING_TIME Then _SpriteButtons[i].Dismissed = 1
			
			inc _SpriteButtons[i].DismissingTime, GetFrameTime()
		// Appeared
		Else
			If spriteButton.Dismissing Then dec _SpriteButtons[i].DismissingDelayLeft, GetFrameTime()
			// Set scale and alpha to 100%
			_SpriteButtonSetScale(i, 1.0)
			SetSpriteColorAlpha(spriteButton.BaseSprite, 255)
			// If pressed
			If (GetJButtonPressed(jBtnIdx) Or _SpriteButtons[i].Pressed) And Not SpriteButtonDisabled
				inc _SpriteButtons[i].PressedTime, GetFrameTime()
				_SpriteButtons[i].Pressed = 1
				
				If GetJButtonPressed(jBtnIdx) And Not spriteButton.Dismissing
					If GetJButtonPressed(jBtnIdx)
						Select spriteButton.ButtonType
							Case SpriteButtonTypeLeft:
								PlaySound(GetThemeSound("snd_left"))
							EndCase
							Case SpriteButtonTypeRight:
								PlaySound(GetThemeSound("snd_right"))
							EndCase
							Case SpriteButtonTypeBell:
								PlaySound(GetThemeSound("snd_bell"))
							EndCase
							Case Default:
								PlaySound(GetThemeSound("snd_ok"))
							EndCase
						EndSelect
					EndIf
					_SpriteButtons[i].PressedTime = 0
				EndIf
				
				// Scaling
				If pressedTime# < SPRITE_BUTTON_HIGHLIGHTING_SCALING_TIME / 2.0
					_SpriteButtonSetScale(i, 1.0 - (pressedTime# / (SPRITE_BUTTON_HIGHLIGHTING_SCALING_TIME / 2.0)) * (1.0 - SPRITE_BUTTON_HIGHLIGHTING_SCALING_FACTOR))
				Else
					_SpriteButtonSetScale(i, MinF(SPRITE_BUTTON_HIGHLIGHTING_SCALING_FACTOR + (pressedTime# / 2.0 / (SPRITE_BUTTON_HIGHLIGHTING_SCALING_TIME / 2.0)) * (1.0 - SPRITE_BUTTON_HIGHLIGHTING_SCALING_FACTOR), 1.0))
				EndIf
				
				// Glittering
				If pressedTime# < SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME1
					SetSpriteColorAlpha(highlightSprite, (pressedTime# / (SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME1)) * 255)
				Else
					SetSpriteColorAlpha(highlightSprite, MaxI(255.0 - ((pressedTime# - SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME1) / SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME2) * 255.0, 0))
				EndIf
				
				// Reset pressing status
				If pressedTime# > SPRITE_BUTTON_HIGHLIGHTING_SCALING_TIME And pressedTime# > SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME1 + SPRITE_BUTTON_HIGHLIGHTING_GLITTERING_TIME2
					_SpriteButtons[i].PressedTime = 0.0
					_SpriteButtons[i].Pressed = 0
				EndIf
			EndIf
		EndIf
	Next
EndFunction

Function _SpriteButtonSetScale(arrIdx As Integer, fScale As Float)
	spriteButton As _SpriteButton
	spriteButton = _SpriteButtons[arrIdx]
	SetSpriteScale(spriteButton.BaseSprite, fScale, fScale)
	SetSpriteScale(spriteButton.HighlightSprite, fScale, fScale)
	SetSpritePosition(spriteButton.BaseSprite, GetJButtonX(spriteButton.JButtonIndex) + (1.0 - fScale) * 0.5 * GetJButtonSize(), GetJButtonY(spriteButton.JButtonIndex) + (1.0 - fScale) * 0.5 * GetJButtonSize())
	SetSpritePosition(spriteButton.HighlightSprite, GetSpriteX(spriteButton.BaseSprite), GetSpriteY(spriteButton.BaseSprite))
EndFunction
