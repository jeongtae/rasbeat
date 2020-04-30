#include "Constants.agc"
#include "Settings.agc"

#constant GRID_DRAWING_ 1

Type _GridDrawingPoint
	X As Float
	Y As Float
EndType

Global _GridDrawingImageId As Integer = -1
Global _GridDrawingSpriteIds As Integer[]
Global _GridDrawingButtonPositions As _GridDrawingPoint[]
Global _GridDrawingButtonSize As Float
Global _GridDrawingScreenPosition As _GridDrawingPoint
Global _GridDrawingScreenWidth As Float
Global _GridDrawingScreenHeight As Float
Global _GridDrawingLowerScreenPosition As _GridDrawingPoint
Global _GridDrawingLowerScreenWidth As Float
Global _GridDrawingLowerScreenHeight As Float

Function GetUpperScreenX()
EndFunction _GridDrawingScreenPosition.X

Function GetUpperScreenY()
EndFunction _GridDrawingScreenPosition.Y

Function GetUpperScreenWidth()
EndFunction _GridDrawingScreenWidth

Function GetUpperScreenHeight()
EndFunction _GridDrawingScreenHeight

Function GetLowerScreenX()
EndFunction _GridDrawingLowerScreenPosition.X

Function GetLowerScreenY()
EndFunction _GridDrawingLowerScreenPosition.Y

Function GetLowerScreenWidth()
EndFunction _GridDrawingLowerScreenWidth

Function GetLowerScreenHeight()
EndFunction _GridDrawingLowerScreenHeight


Function GetJButtonX(iJBtnIdx As Integer)
	If iJBtnIdx <= 0 Or iJBtnIdx > _GridDrawingButtonPositions.Length Then ExitFunction 0
EndFunction _GridDrawingButtonPositions[iJBtnIdx].X

Function GetJButtonY(iJBtnIdx As Integer)
	If iJBtnIdx <= 0 Or iJBtnIdx > _GridDrawingButtonPositions.Length Then ExitFunction 0
EndFunction _GridDrawingButtonPositions[iJBtnIdx].Y

Function GetJButtonSize()
EndFunction _GridDrawingButtonSize

Function GetJButtonSpacing()
	res# = GetJButtonX(2) - GetJButtonX(1) - GetJButtonSize()
EndFunction res#

Function RedrawGrid(iRed As Integer)
	scrTop As Float
	scrLeft As Float
	scrRight As Float
	scrRatio As Float
	btnsBottom As Float
	btnsLeft As Float
	btnsRight As Float
	btnsSpacing As Float
	scrHeight As Float
	btnsSideLen As Float
	btnSize As Float
	
	scrTop = GetSettingsUSTop()
	scrLeft = GetSettingsUSLeft()
	scrRight = GetSettingsUSRight()
	scrRatio = 16.0 / 10.0  //fixed
	btnsBottom = GetSettingsLSBottom()
	btnsLeft = GetSettingsLSLeft()
	btnsRight = GetSettingsLSRight()
	btnsSpacing = GetSettingsLSSpacing()
	
	scrHeight = (RESOLUTION_WIDTH - scrLeft - scrRight) * (1.0 / scrRatio)
	btnsSideLen = RESOLUTION_WIDTH - btnsLeft - btnsRight
	btnSize = (btnsSideLen - btnsSpacing * 3.0) / 4.0
	
	// Delete original grids
	While _GridDrawingSpriteIds.Length >= 0
		DeleteSprite(_GridDrawingSpriteIds[_GridDrawingSpriteIds.Length])
		_GridDrawingSpriteIds.Remove()
	EndWhile
	
	// Create grid color
	If _GridDrawingImageId >= 0 Then DeleteImage(_GridDrawingImageId)
	_GridDrawingImageId = CreateImageColor(iRed, 0, 0, 255)
	
	// Screen Top
	_GridDrawingAddGrid(0, 0, RESOLUTION_WIDTH, scrTop)
	// Screen Left
	_GridDrawingAddGrid(0, scrTop, scrLeft, scrHeight)
	// Screen Right
	_GridDrawingAddGrid(RESOLUTION_WIDTH - scrRight, scrTop, scrRight, scrHeight)
	
	// Between Screen and Buttons
	_GridDrawingAddGrid(0, scrTop + scrHeight, RESOLUTION_WIDTH, RESOLUTION_HEIGHT - btnsBottom - btnsSideLen - scrTop - scrHeight)
	
	// Buttons Bottom
	_GridDrawingAddGrid(0, RESOLUTION_HEIGHT - btnsBottom, RESOLUTION_WIDTH, btnsBottom)
	// Buttons Left
	_GridDrawingAddGrid(0, RESOLUTION_HEIGHT - btnsBottom - btnsSideLen, btnsLeft, btnsSideLen)
	// Buttons Right
	_GridDrawingAddGrid(RESOLUTION_WIDTH - btnsRight, RESOLUTION_HEIGHT - btnsBottom - btnsSideLen, btnsRight, btnsSideLen)
	
	// Buttons Internal Grids
	If GetSettingsLSSpacingVisible()
		For i = 1 To 3 Step 1
			_GridDrawingAddGrid(btnsLeft + btnSize * 1.0 * i + btnsSpacing * 1.0 * (i - 1), RESOLUTION_HEIGHT - btnsBottom - btnsSideLen, btnsSpacing, btnsSideLen)
			_GridDrawingAddGrid(btnsLeft, RESOLUTION_HEIGHT - btnsBottom - btnsSideLen + btnSize * 1.0 * i + btnsSpacing * 1.0 * (i - 1), btnsSideLen, btnsSpacing)
		Next
	EndIf
	
	// Store screen position and size
	_GridDrawingScreenPosition.X = scrLeft
	_GridDrawingScreenPosition.Y = scrTop
	_GridDrawingScreenWidth = RESOLUTION_WIDTH - scrLeft - scrRight
	_GridDrawingScreenHeight = scrHeight
	
	// Store button positions and size
	While _GridDrawingButtonPositions.Length >= 0
		_GridDrawingButtonPositions.Remove()
	EndWhile
	pos As _GridDrawingPoint
	pos.X = 0
	pos.Y = 0
	_GridDrawingButtonPositions.Insert(pos)
	For i = 1 To 4 Step 1
		pos.Y = RESOLUTION_HEIGHT - btnsBottom - btnsSideLen + (btnSize + btnsSpacing) * 1.0 * (i - 1)
		For j = 1 To 4 Step 1
			pos.X = btnsLeft + (btnSize + btnsSpacing) * 1.0 * (j - 1)
			_GridDrawingButtonPositions.Insert(pos)
		Next j
	Next i
	_GridDrawingButtonSize = btnSize
	
	// Store lower screen position and size
	_GridDrawingLowerScreenPosition.X = btnsLeft
	_GridDrawingLowerScreenPosition.Y = _GridDrawingButtonPositions[1].Y
	_GridDrawingLowerScreenWidth = RESOLUTION_WIDTH - btnsLeft - btnsRight
	_GridDrawingLowerScreenHeight = RESOLUTION_HEIGHT - btnsBottom - _GridDrawingLowerScreenPosition.Y
EndFunction

Function _GridDrawingAddGrid(fX As Float, fY As Float, fWidth As Float, fHeight As Float)
	If fX >= RESOLUTION_WIDTH Or fY >= RESOLUTION_HEIGHT Or fWidth <= 0 Or fHeight <= 0 Then ExitFunction 0
	spriteId = CreateSprite(_GridDrawingImageId)
	SetSpriteDepth(spriteId, DEPTH_GRID)
	SetSpriteSize (spriteId, fWidth, fHeight)
	SetSpritePosition(spriteId, fX, fY)
	_GridDrawingSpriteIds.Insert(spriteId)
EndFunction 1
