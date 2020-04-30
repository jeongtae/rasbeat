#include "Constants.agc"
#include "GridDrawing.agc"
#include "Localizing.agc"

Type _ErrorReportingText
	TextID As Integer
	LifeTime As Float
EndType
Global _ErrorReportingTexts As _ErrorReportingText[]
Global _ErrorReportingCheckedErrors As String[]
Global _ErrorReportingNeedMovement As Float = 0.0

// Register error manually
Function InvokeError(msg As String)
	If msg <> "" Then _ErrorReportingCheckedErrors.Insert(msg)
EndFunction

// Register error by checking API
Function CheckError()
	If GetErrorOccurred() Then _ErrorReportingCheckedErrors.Insert(GetLastError())
EndFunction

// Update
Function UpdateErrorReporting()
	// For existing error texts
	For i = 0 To _ErrorReportingTexts.Length Step 1
		inc _ErrorReportingTexts[i].LifeTime, GetFrameTime()
		If _ErrorReportingTexts[i].LifeTime >= ERROR_REPORTING_DISMISSING_START
			SetTextColorAlpha(_ErrorReportingTexts[i].TextID, (1.0 - (_ErrorReportingTexts[i].LifeTime - ERROR_REPORTING_DISMISSING_START) / (ERROR_REPORTING_DISMISSING_END - ERROR_REPORTING_DISMISSING_START)) * 255.0)
		EndIf
		If _ErrorReportingTexts[i].LifeTime >= ERROR_REPORTING_DISMISSING_END
			DeleteText(_ErrorReportingTexts[i].TextID)
			_ErrorReportingTexts.Remove(i)
			dec i
		EndIf
	Next i
	
	// If need to move texts
	If _ErrorReportingNeedMovement > 0.0
		movement# = MinF(ERROR_REPORTING_MOVING_SPEED * GetFrameTime(), _ErrorReportingNeedMovement)
		For i = 0 To _ErrorReportingTexts.Length Step 1
			SetTextY(_ErrorReportingTexts[i].TextID, GetTextY(_ErrorReportingTexts[i].TextID) + movement#)
		Next i
		dec _ErrorReportingNeedMovement, movement#
	EndIf
	
	// Create texts
	CheckError()
	While _ErrorReportingCheckedErrors.Length >= 0
		msg As String
		msg = _ErrorReportingCheckedErrors[0]
		_ErrorReportingCheckedErrors.Remove(0)
		
		item As _ErrorReportingText
		textId = CreateText(msg)
		item.TextID = textId
		item.LifeTime = 0
		
		SetTextAlignment(textId, 2)
		SetTextFont(textId, GetLanguageFont())
		SetTextDepth(textId, DEPTH_ERROR_REPORTING)
		SetTextPosition(textId, GetUpperScreenX() + GetUpperScreenWidth() - 10, GetUpperScreenY() - ERROR_REPORTING_FONT_SIZE * 1.1 - _ErrorReportingNeedMovement)
		SetTextBold(textId, 1)
		SetTextSize(textId, ERROR_REPORTING_FONT_SIZE * GetLanguageFontScale())
		SetTextLineSpacing(textId, GetTextSize(textId) * GetLanguageFontLineSpacing())
		SetTextColor(textId, 255, 0, 255, 255)
		
		inc _ErrorReportingNeedMovement, ERROR_REPORTING_FONT_SIZE * 1.1
		_ErrorReportingTexts.Insert(item)
	EndWhile
EndFunction
