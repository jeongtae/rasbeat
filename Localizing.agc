#include "Constants.agc"
#include "ErrorReporting.agc"
#include "StringUtil.agc"

Type LanguageInfo
	Name As String
	Author As String
	File As String
	Font As Integer
	BoldFont As Integer
	//EnglishFont As Integer
	//EnglishBoldFont As Integer
EndType

Type _LocallizingDictionaryItem
	Key As String
	Value As String
EndType

Global _LocalizingDictionary As _LocallizingDictionaryItem[]
Global _LocalizingInfo As LanguageInfo

Global _LocalizingFontScale As Float = 1.0
Global _LocalizingFontLineSpacing As Float = 0.0

Function GetLanguageList()
	list As LanguageInfo[]
	If SetFolder(LANG_PATH) = 0 Then ExitFunction list
	file$ = GetFirstFile(0)  //ReadFolder
	While list.Length >= 0
		list.Remove()
	EndWhile
	While file$ <> ""
		If CompareString(Lower(Right(file$, 4)), ".txt", 1, -1)
			item As LanguageInfo
			item.Name = ""
			item.Author = ""
			item.File = file$
			item.Font = 0
			item.BoldFont = 0
			//item.EnglishFont = 0
			fileId = OpenToRead(file$)
			CheckError()
			If fileId > 0
				line As String
				While FileEOF(fileId) = 0
					line = ReadLine(fileId)
					// Remove Comment (//)
					commentIndex = FindString(line, "//")
					If commentIndex > 0 Then line = Left(line, commentIndex - 1)
					// If a=b type
					If FindStringCount(line, "=") >= 1
						leftPart$ = Lower(Trim(Left(line, FindString(line, "=") - 1)))
						rightPart$ = Trim(Right(line, Len(line) - FindString(line, "=")))
						Select leftPart$
							Case "lang":
								If item.Name = "" Then item.Name = rightPart$
							EndCase
							Case "author":
								If item.Author = "" Then item.Author = rightPart$
							EndCase
						EndSelect
					EndIf
					If item.Name <> "" And item.Author <> "" Then Exit
				EndWhile
				If item.Name = "" Then item.Name = RemovePathExtension(file$)
				CloseFile(fileId)
				list.InsertSorted(item)
			EndIf
		EndIf
		file$ = GetNextFile()
	EndWhile
EndFunction list

Function GetLanguageInfo()
EndFunction _LocalizingInfo
Function GetLanguageFont()
EndFunction _LocalizingInfo.Font
Function GetLanguageBoldFont()
EndFunction _LocalizingInfo.BoldFont
Function GetLanguageFontScale()
EndFunction _LocalizingFontScale
Function GetLanguageFontLineSpacing()
EndFunction _LocalizingFontLineSpacing
/*
Function GetLanguageEnglishFont()
EndFunction _LocalizingInfo.EnglishFont
Function GetLanguageEnglishBoldFont()
EndFunction _LocalizingInfo.EnglishBoldFont
*/

Function SetLanguage(szFile As String)
	If Lower(szFile) = "auto"
		szFile = Left(Lower(GetDeviceLanguage()), 5) + ".txt"
		If Not GetFileExists(LANG_PATH + szFile) Then szFile = "en_us.txt"
	EndIf
	If Not GetFileExists(LANG_PATH + szFile)
		list As LanguageInfo[]
		list = GetLanguageList()
		If list.Length >= 0
			szFile = list[0].File
		Else
			Message("Failed to load language file.")
			End
			ExitFunction 0
		EndIf
		While list.Length >= 0
			list.Remove()
		EndWhile
	EndIf
	fileId = OpenToRead(LANG_PATH + szFile)
	CheckError()
	If fileId = 0 Then ExitFunction 0
	While _LocalizingDictionary.Length >= 0
		_LocalizingDictionary.Remove()
	EndWhile
	_LocalizingInfo.Name = ""
	_LocalizingInfo.Author = ""
	_LocalizingInfo.File = szFile
	If _LocalizingInfo.Font > 0 Then DeleteFont(_LocalizingInfo.Font)
	If _LocalizingInfo.BoldFont > 0 Then DeleteFont(_LocalizingInfo.BoldFont)
	_LocalizingInfo.Font = 0
	_LocalizingInfo.BoldFont = 0
	_LocalizingFontScale = 1.0
	_LocalizingFontLineSpacing = 0.0
	line As String
	While Not FileEOF(fileId)
		line = ReadLine(fileId)
		// Remove Comment (//)
		commentIndex = FindString(line, "//")
		If commentIndex > 0 Then line = Left(line, commentIndex - 1)
		// If a=b type
		If FindStringCount(line, "=") >= 1
			leftPart$ = Lower(Trim(Left(line, FindString(line, "=") - 1)))
			rightPart$ = Trim(Right(line, Len(line) - FindString(line, "=")))
			Select leftPart$
				Case "lang":
					If _LocalizingInfo.Name = "" Then _LocalizingInfo.Name = rightPart$
				EndCase
				Case "author":
					If _LocalizingInfo.Author = "" Then _LocalizingInfo.Author = rightPart$
				EndCase
				Case "font":
					If _LocalizingInfo.Font = 0
						path$ = FONTS_PATH + ReplaceString(rightPart$, "/", "", -1)
						If GetFileExists(path$) Then _LocalizingInfo.Font = LoadFont(path$)
						CheckError()
					EndIf
				EndCase
				Case "boldfont":
					If _LocalizingInfo.BoldFont = 0
						path$ = FONTS_PATH + ReplaceString(rightPart$, "/", "", -1)
						If GetFileExists(path$) Then _LocalizingInfo.BoldFont = LoadFont(path$)
						CheckError()
					EndIf
				EndCase
				Case "fontscale":
					_LocalizingFontScale = MaxF(0.1, ValFloat(rightPart$))
				EndCase
				Case "fontlinespacing":
					_LocalizingFontLineSpacing = ValFloat(rightPart$)
				EndCase
				/*
				Case "enfont":
					If _LocalizingInfo.EnglishFont = 0
						path$ = FONTS_PATH + ReplaceString(rightPart$, "/", "", -1)
						If GetFileExists(path$) Then _LocalizingInfo.EnglishFont = LoadFont(path$)
						CheckError()
					EndIf
				EndCase
				Case "enboldfont":
					If _LocalizingInfo.EnglishBoldFont = 0
						path$ = FONTS_PATH + ReplaceString(rightPart$, "/", "", -1)
						If GetFileExists(path$) Then _LocalizingInfo.EnglishBoldFont = LoadFont(path$)
						CheckError()
					EndIf
				EndCase
				*/
				Case Default:
					item As _LocallizingDictionaryItem
					item.Key = Upper(leftPart$)
					item.Value = rightPart$
					_LocalizingDictionary.InsertSorted(item)
				EndCase
			EndSelect
		EndIf
	EndWhile
	If _LocalizingInfo.Name = "" Then RemovePathExtension(szFile)
	//If _LocalizingInfo.BoldFont = 0 Then _LocalizingInfo.BoldFont = _LocalizingInfo.Font
	CloseFile(fileId)
EndFunction 1

Function GetLocalizedString(szKey As String)
	result As String
	index = _LocalizingDictionary.Find(szKey)
	If index >= 0
		result = ReplaceString(_LocalizingDictionary[index].Value, "%n", Chr(10), -1)
	Else
		InvokeError("Failed to localize " + szKey + ".")
		result = szKey
	EndIf
EndFunction result
