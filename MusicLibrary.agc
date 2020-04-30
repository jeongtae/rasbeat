#include "Constants.agc"
#include "Localizing.agc"
#include "ErrorReporting.agc"
#include "GridDrawing.agc"
#include "JMemoParser.agc"
#include "MusicRecords.agc"

Type MusicLibraryShaListItem
	Sha256String As String
	Title As String
	Artist As String
	FileName As String
EndType
Global _MusicLibraryShaList As MusicLibraryShaListItem[]

Type MusicLibraryItem
	Title As String
	Artist As String
	MusicFile As String
	CoverFile As String
	Tempo As String
	PreListeningPlayhead As Float
	Lengths As Float[3]
	Levels As Integer[3]
	MemoFiles As String[3]
	Sha256Strings As String[3]
	MusicBarLevels As Integer[3,119]
	UpdatedTimes As Integer[3]
	NotesCounts As Integer[3]
	HoldsCounts As Integer[3]
EndType
Global _MusicLibraryList As MusicLibraryItem[]

Type _MusicLibraryTempFileListItem
	UnixTime As Integer
	FileName As String
EndType

Function GetMusicLibraryList()
EndFunction _MusicLibraryList

#constant MusicLibrarySortByTitle (0)
#constant MusicLibrarySortByArtist (1)
#constant MusicLibrarySortByLevelBasic (2)
#constant MusicLibrarySortByLevelAdvanced (3)
#constant MusicLibrarySortByLevelExtreme (4)
#constant MusicLibrarySortByHighScoreAll (5)
#constant MusicLibrarySortByHighScoreBasic (6)
#constant MusicLibrarySortByHighScoreAdvanced (7)
#constant MusicLibrarySortByHighScoreExtreme (8)
#constant MusicLibrarySortByLastPlayedTimeAll (9)
#constant MusicLibrarySortByLastPlayedTimeBasic (10)
#constant MusicLibrarySortByLastPlayedTimeAdvanced (11)
#constant MusicLibrarySortByLastPlayedTimeExtreme (12)
Function _MusicLibraryCompare(criteria, idx1, idx2, reverse)
	Select criteria
		Case MusicLibrarySortByTitle
			title1$ = Lower(_MusicLibraryList[idx1].Title)
			title2$ = Lower(_MusicLibraryList[idx2].Title)
			If title1$ > title2$
				ExitFunction IfInteger(reverse, 1, -1)
			ElseIf title1$ = title2$
				ExitFunction 0
			Else
				ExitFunction IfInteger(reverse, -1, 1)
			EndIf
		EndCase
		Case MusicLibrarySortByArtist
			artist1$ = Lower(_MusicLibraryList[idx1].Artist)
			artist2$ = Lower(_MusicLibraryList[idx2].Artist)
			If artist1$ > artist2$
				ExitFunction IfInteger(reverse, 1, -1)
			ElseIf artist1$ = artist2$
				If Lower(_MusicLibraryList[idx1].Title) > Lower(_MusicLibraryList[idx2].Title)
					ExitFunction -1
				ElseIf Lower(_MusicLibraryList[idx1].Title) = Lower(_MusicLibraryList[idx2].Title)
					ExitFunction 0
				Else
					ExitFunction 1
				EndIf
			Else
				ExitFunction IfInteger(reverse, -1, 1)
			EndIf
		EndCase
		Case Default
			If MusicLibrarySortByLevelBasic <= criteria And criteria <= MusicLibrarySortByLevelExtreme
				idx = criteria - MusicLibrarySortByLevelBasic + 1
				level1 = IfInteger(_MusicLibraryList[idx1].Sha256Strings[idx] = "", IfInteger(reverse, -1, 11), _MusicLibraryList[idx1].Levels[idx])
				level2 = IfInteger(_MusicLibraryList[idx2].Sha256Strings[idx] = "", IfInteger(reverse, -1, 11), _MusicLibraryList[idx2].Levels[idx])
				If level1 > level2
					ExitFunction IfInteger(reverse, 1, -1)
				ElseIf level1 = level2
					If Lower(_MusicLibraryList[idx1].Title) > Lower(_MusicLibraryList[idx2].Title)
						ExitFunction -1
					ElseIf Lower(_MusicLibraryList[idx1].Title) = Lower(_MusicLibraryList[idx2].Title)
						ExitFunction 0
					Else
						ExitFunction 1
					EndIf
				Else
					ExitFunction IfInteger(reverse, -1, 1)
				EndIf
			ElseIf criteria = MusicLibrarySortByHighScoreAll
				idx = 0
				For i = 1 To 3
					If _MusicLibraryList[idx1].Sha256Strings[i] <> ""
						idx = i
						Exit
					EndIf
				Next
				For i = idx+1 To 3
					If _MusicLibraryList[idx1].Sha256Strings[i] <> ""
						lpt = GetMusicRecordsHighScore(_MusicLibraryList[idx1].Sha256Strings[i])
						If Not reverse
							If lpt < GetMusicRecordsHighScore(_MusicLibraryList[idx1].Sha256Strings[idx]) Then idx = i
						Else
							If lpt > GetMusicRecordsHighScore(_MusicLibraryList[idx1].Sha256Strings[idx]) Then idx = i
						EndIf
					EndIf
				Next
				score1 = GetMusicRecordsHighScore(_MusicLibraryList[idx1].Sha256Strings[idx])
				idx = 0
				For i = 1 To 3
					If _MusicLibraryList[idx2].Sha256Strings[i] <> ""
						idx = i
						Exit
					EndIf
				Next
				For i = idx+1 To 3
					If _MusicLibraryList[idx2].Sha256Strings[i] <> ""
						lpt = GetMusicRecordsHighScore(_MusicLibraryList[idx2].Sha256Strings[i])
						If Not reverse
							If lpt < GetMusicRecordsHighScore(_MusicLibraryList[idx2].Sha256Strings[idx]) Then idx = i
						Else
							If lpt > GetMusicRecordsHighScore(_MusicLibraryList[idx2].Sha256Strings[idx]) Then idx = i
						EndIf
					EndIf
				Next
				score2 = GetMusicRecordsHighScore(_MusicLibraryList[idx2].Sha256Strings[idx])
				If score1 > score2
					ExitFunction IfInteger(reverse, 1, -1)
				ElseIf score1 = score2
					If Lower(_MusicLibraryList[idx1].Title) > Lower(_MusicLibraryList[idx2].Title)
						ExitFunction -1
					ElseIf Lower(_MusicLibraryList[idx1].Title) = Lower(_MusicLibraryList[idx2].Title)
						ExitFunction 0
					Else
						ExitFunction 1
					EndIf
				Else
					ExitFunction IfInteger(reverse, -1, 1)
				EndIf
			ElseIf MusicLibrarySortByHighScoreBasic <= criteria And criteria <= MusicLibrarySortByHighScoreExtreme
				idx = criteria - MusicLibrarySortByHighScoreBasic + 1
				score1 = IfInteger(_MusicLibraryList[idx1].Sha256Strings[idx] = "", IfInteger(reverse, -1, 1000001), GetMusicRecordsHighScore(_MusicLibraryList[idx1].Sha256Strings[idx]))
				score2 = IfInteger(_MusicLibraryList[idx2].Sha256Strings[idx] = "", IfInteger(reverse, -1, 1000001), GetMusicRecordsHighScore(_MusicLibraryList[idx2].Sha256Strings[idx]))
				If score1 > score2
					ExitFunction IfInteger(reverse, 1, -1)
				ElseIf score1 = score2
					If Lower(_MusicLibraryList[idx1].Title) > Lower(_MusicLibraryList[idx2].Title)
						ExitFunction -1
					ElseIf Lower(_MusicLibraryList[idx1].Title) = Lower(_MusicLibraryList[idx2].Title)
						ExitFunction 0
					Else
						ExitFunction 1
					EndIf
				Else
					ExitFunction IfInteger(reverse, -1, 1)
				EndIf
			ElseIf criteria = MusicLibrarySortByLastPlayedTimeAll
				idx = 0
				For i = 1 To 3
					If _MusicLibraryList[idx1].Sha256Strings[i] <> ""
						idx = i
						Exit
					EndIf
				Next
				For i = idx+1 To 3
					If _MusicLibraryList[idx1].Sha256Strings[i] <> ""
						lpt = GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx1].Sha256Strings[i])
						If Not reverse
							If lpt > GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx1].Sha256Strings[idx]) Then idx = i
						Else
							If lpt < GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx1].Sha256Strings[idx]) Then idx = i
						EndIf
					EndIf
				Next
				time1 = GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx1].Sha256Strings[idx])
				
				idx = 0
				For i = 1 To 3
					If _MusicLibraryList[idx2].Sha256Strings[i] <> ""
						idx = i
						Exit
					EndIf
				Next
				For i = idx+1 To 3
					If _MusicLibraryList[idx2].Sha256Strings[i] <> ""
						lpt = GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx2].Sha256Strings[i])
						If Not reverse
							If lpt > GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx2].Sha256Strings[idx]) Then idx = i
						Else
							If lpt < GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx2].Sha256Strings[idx]) Then idx = i
						EndIf
					EndIf
				Next
				time2 = GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx2].Sha256Strings[idx])
				
				If time1 > time2
					ExitFunction IfInteger(reverse, -1, 1)
				ElseIf time1 = time2
					If Lower(_MusicLibraryList[idx1].Title) > Lower(_MusicLibraryList[idx2].Title)
						ExitFunction -1
					ElseIf Lower(_MusicLibraryList[idx1].Title) = Lower(_MusicLibraryList[idx2].Title)
						ExitFunction 0
					Else
						ExitFunction 1
					EndIf
				Else
					ExitFunction IfInteger(reverse, 1, -1)
				EndIf
			ElseIf MusicLibrarySortByLastPlayedTimeBasic <= criteria And criteria <= MusicLibrarySortByLastPlayedTimeExtreme
				idx = criteria - MusicLibrarySortByLastPlayedTimeBasic + 1
				time1 = IfInteger(_MusicLibraryList[idx1].Sha256Strings[idx] = "", IfInteger(reverse, INTEGER_MAX, INTEGER_MIN), GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx1].Sha256Strings[idx]))
				time2 = IfInteger(_MusicLibraryList[idx2].Sha256Strings[idx] = "", IfInteger(reverse, INTEGER_MAX, INTEGER_MIN), GetMusicRecordsLastPlayedTime(_MusicLibraryList[idx2].Sha256Strings[idx]))
				If time1 > time2
					ExitFunction IfInteger(reverse, -1, 1)
				ElseIf time1 = time2
					If Lower(_MusicLibraryList[idx1].Title) > Lower(_MusicLibraryList[idx2].Title)
						ExitFunction -1
					ElseIf Lower(_MusicLibraryList[idx1].Title) = Lower(_MusicLibraryList[idx2].Title)
						ExitFunction 0
					Else
						ExitFunction 1
					EndIf
				Else
					ExitFunction IfInteger(reverse, 1, -1)
				EndIf
			EndIf
		EndCase
	EndSelect
EndFunction 0
Function GetMusicLibrarySortedIndexes(criteria As Integer, descend As Integer)
	result As Integer[]
	While result.Length >= 0
		result.Remove()
	EndWhile
	For i = 0 To _MusicLibraryList.Length
		result.Insert(i)
	Next
	
	//ExitFunction result
	If result.Length > 0
		For i = 1 To result.Length
			For j = i To 1 Step -1
				If _MusicLibraryCompare(criteria, result[j-1], result[j], descend) = -1
				//If Lower(_MusicLibraryList[result[j-1]].Title) > Lower(_MusicLibraryList[result[j]].Title)
					result.Swap(j-1, j)
				Else
					Exit
				EndIf
			Next
			/*
			t = result[i]
			j = i
			While Lower(_MusicLibraryList[result[j-1]].Title) > Lower(_MusicLibraryList[t].Title) And j > 0
				result[j] = result[j-1]
				dec j
			EndWhile
			result[j] = t
			*/
		Next
	EndIf
	ExitFunction result
	
	If result.Length > 0
		tempStack As Integer[]
		l = 0
		r = result.Length
		tempStack.Insert(r)
		tempStack.Insert(l)
		While tempStack.Length >= 0
			l = tempStack[tempStack.Length]
			tempStack.Remove()
			r = tempStack[tempStack.Length]
			tempStack.Remove()
			
			If r - l + 1 > 1
				p = result[r]
				i = l - 1
				j = r
				While 1
					Select criteria
						Case MusicLibrarySortByTitle
							inc i
							While Lower(_MusicLibraryList[result[i]].Title) < Lower(_MusicLibraryList[p].Title)
								inc i
							EndWhile
							dec j
							While Lower(_MusicLibraryList[result[j]].Title) > Lower(_MusicLibraryList[p].Title)
								dec j
							EndWhile
						EndCase
					EndSelect
					If i >= j Then Exit
					result.Swap(i, j)
				EndWhile
				result.Swap(i, r)
				tempStack.Insert(r)
				tempStack.Insert(i+1)
				tempStack.Insert(i-1)
				tempStack.Insert(l)
			EndIf
		EndWhile
		
		While tempStack.Length >= 0
			tempStack.Remove()
		EndWhile
		
		If descend > 0
			result.Reverse()
		EndIf
	EndIf
EndFunction result

Function ReadMusicLibraryFromFile()
	file = OpenToRead("/musiclib.dat")
	CheckError()
	If file = 0 Then ExitFunction
	
	tempList As MusicLibraryItem[]
	tempList2 As MusicLibraryShaListItem[]
	
	failedToRead = 0
	While Not FileEOF(file) And Not failedToRead
		item As MusicLibraryItem
		
		pos = GetFilePos(file)
		If pos = GetFileSize(file) Then Exit
		item.Title = ReadString2(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.Artist = ReadString2(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.MusicFile = ReadString2(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.CoverFile = ReadString2(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.Tempo = ReadString2(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.PreListeningPlayhead = ReadFloat(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		For i = 0 To 3
			pos = GetFilePos(file)
			item.Lengths[i] = ReadFloat(file)
			If pos = GetFilePos(file) Then failedToRead = 1
			
			pos = GetFilePos(file)
			item.Levels[i] = ReadInteger(file)
			If pos = GetFilePos(file) Then failedToRead = 1
			
			pos = GetFilePos(file)
			item.MemoFiles[i] = ReadString2(file)
			If pos = GetFilePos(file) Then failedToRead = 1
			
			pos = GetFilePos(file)
			item.Sha256Strings[i] = ReadString2(file)
			If pos = GetFilePos(file) Then failedToRead = 1
			
			pos = GetFilePos(file)
			item.UpdatedTimes[i] = ReadInteger(file)
			If pos = GetFilePos(file) Then failedToRead = 1
			
			pos = GetFilePos(file)
			item.NotesCounts[i] = ReadInteger(file)
			If pos = GetFilePos(file) Then failedToRead = 1
			
			pos = GetFilePos(file)
			item.HoldsCounts[i] = ReadInteger(file)
			If pos = GetFilePos(file) Then failedToRead = 1
		Next
		
		For i = 0 To 3
			For j = 0 To 119
				pos = GetFilePos(file)
				item.MusicBarLevels[i,j] = ReadByte(file)
				If pos = GetFilePos(file) Then failedToRead = 1
			Next
		Next
		
		If pos = GetFilePos(file) Then failedToRead = 1
		tempList.InsertSorted(item)
		
		For i = 0 To 3
			If item.Sha256Strings[i] <> ""
				shaItem As MusicLibraryShaListItem
				shaItem.Sha256String = item.Sha256Strings[i]
				shaItem.Title = item.Title
				shaItem.Artist = item.Artist
				shaItem.FileName = item.MemoFiles[i]
				tempList2.InsertSorted(shaItem)
			EndIf
		Next
	EndWhile
	
	CloseFile(file)
	
	If failedToRead
		InvokeError("Failed to read music library file.")
		ExitFunction
	EndIf
	
	While _MusicLibraryList.Length >= 0
		For i = 0 To 3
			_MusicLibraryList[_MusicLibraryList.Length].Levels.Remove()
			_MusicLibraryList[_MusicLibraryList.Length].MemoFiles.Remove()
			_MusicLibraryList[_MusicLibraryList.Length].Sha256Strings.Remove()
			_MusicLibraryList[_MusicLibraryList.Length].UpdatedTimes.Remove()
			_MusicLibraryList[_MusicLibraryList.Length].NotesCounts.Remove()
			_MusicLibraryList[_MusicLibraryList.Length].HoldsCounts.Remove()
			For j = 0 To 119
				_MusicLibraryList[_MusicLibraryList.Length].MusicBarLevels[i].Remove()
			Next
		Next
		_MusicLibraryList.Remove()
	EndWhile
	_MusicLibraryList = tempList
	
	While _MusicLibraryShaList.Length >= 0
		_MusicLibraryShaList.Remove()
	EndWhile
	_MusicLibraryShaList = tempList2
EndFunction

Function WriteMusicLibraryToFile()
	file = OpenToWrite("raw:" + GetReadPath() + "musiclib.dat")
	CheckError()
	If file = 0
		InvokeError("Failed to write music library file.")
		ExitFunction
	EndIf
	
	For i = 0 To _MusicLibraryList.Length
		WriteString2(file, _MusicLibraryList[i].Title)
		WriteString2(file, _MusicLibraryList[i].Artist)
		WriteString2(file, _MusicLibraryList[i].MusicFile)
		WriteString2(file, _MusicLibraryList[i].CoverFile)
		WriteString2(file, _MusicLibraryList[i].Tempo)
		WriteFloat(file, _MusicLibraryList[i].PreListeningPlayhead)
		For j = 0 To 3
			WriteFloat(file, _MusicLibraryList[i].Lengths[j])
			WriteInteger(file, _MusicLibraryList[i].Levels[j])
			WriteString2(file, _MusicLibraryList[i].MemoFiles[j])
			WriteString2(file, _MusicLibraryList[i].Sha256Strings[j])
			WriteInteger(file, _MusicLibraryList[i].UpdatedTimes[j])
			WriteInteger(file, _MusicLibraryList[i].NotesCounts[j])
			WriteInteger(file, _MusicLibraryList[i].HoldsCounts[j])
		Next
		For j = 0 To 3
			For k = 0 To 119
				WriteByte(file, _MusicLibraryList[i].MusicBarLevels[j,k])
			Next
		Next
	Next
	
	CloseFile(file)
EndFunction

Function UpdateMusicLibrary(mode As Integer)
	blackImage = CreateImageColor(100, 100, 100, 255)
	whiteImage = CreateImageColor(255, 255, 255, 255)
	backSpriteId = CreateSprite(blackImage)
	SetSpriteSize(backSpriteId, RESOLUTION_WIDTH, RESOLUTION_HEIGHT)
	SetSpritePosition(backSpriteId, 0, 0)
	SetSpriteDepth(backSpriteId, DEPTH_LIB_BACK)
	
	progBackSpriteId = CreateSprite(whiteImage)
	SetSpriteSize(progBackSpriteId, GetUpperScreenWidth() * 0.8, GetUpperScreenHeight() * 0.06)
	SetSpritePosition(progBackSpriteId, GetUpperScreenX() + GetUpperScreenWidth() * 0.1, GetUpperScreenY() + GetUpperScreenHeight() * 0.667)
	SetSpriteDepth(progBackSpriteId, DEPTH_LIB_PROG_BACK)
	
	thickness# = GetSpriteHeight(progBackSpriteId) * 0.12
	
	progBarBackSpriteId = CreateSprite(blackImage)
	SetSpriteSize(progBarBackSpriteId, GetSpriteWidth(progBackSpriteId) - thickness# * 2, GetSpriteHeight(progBackSpriteId) - thickness# * 2)
	SetSpritePosition(progBarBackSpriteId, GetSpriteX(progBackSpriteId) + thickness#, GetSpriteY(progBackSpriteId) + thickness#)
	SetSpriteDepth(progBarBackSpriteId, DEPTH_LIB_PROG_BAR_BACK)
	
	progBarSpriteId = CreateSprite(whiteImage)
	progBarMaxWidth# = GetSpriteWidth(progBarBackSpriteId) - thickness# * 2
	progBarHeight# = GetSpriteHeight(progBarBackSpriteId) - thickness# * 2
	SetSpriteSize(progBarSpriteId, 0.0, progBarHeight#)
	SetSpritePosition(progBarSpriteId, GetSpriteX(progBarBackSpriteId) + thickness#, GetSpriteY(progBarBackSpriteId) + thickness#)
	SetSpriteDepth(progBarSpriteId, DEPTH_LIB_PROG_BAR_BACK)
	
	titleTextId = CreateText(GetLocalizedString("LIBRARY_UPDATING"))
	If GetLanguageBoldFont() <> 0
		SetTextFont(titleTextId, GetLanguageBoldFont())
	Else
		SetTextFont(titleTextId, GetLanguageFont())
		SetTextBold(titleTextId, 1)
	EndIf
	SetTextColor(titleTextId, 255, 255, 255, 255)
	SetTextAlignment(titleTextId, 1)
	SetTextDepth(titleTextId, DEPTH_LIB_TEXT)
	SetTextSize(titleTextId, GetUpperScreenWidth() * 0.05 * GetLanguageFontScale())
	SetTextLineSpacing(titleTextId, GetTextSize(titleTextId) * GetLanguageFontLineSpacing())
	SetTextPosition(titleTextId, GetUpperScreenX() + GetUpperScreenWidth() * 0.5, GetUpperScreenY() + GetUpperScreenHeight() * 0.333)
	
	progTextId = CreateText("")
	SetTextFont(progTextId, GetLanguageFont())
	SetTextColor(progTextId, 255, 255, 255, 255)
	SetTextAlignment(progTextId, 1)
	SetTextDepth(progTextId, DEPTH_LIB_TEXT)
	SetTextSize(progTextId, GetUpperScreenWidth() * 0.03 * GetLanguageFontScale())
	SetTextLineSpacing(progTextId, GetTextSize(progTextId) * GetLanguageFontLineSpacing())
	SetTextPosition(progTextId, GetUpperScreenX() + GetUpperScreenWidth() * 0.5, GetUpperScreenY() + GetUpperScreenHeight() * 0.75)
	
	If SetFolder(MUSIC_PATH) = 0
		InvokeError("Failed to access music folder.")
		DeleteSprite(backSpriteId)
		ExitFunction
	EndIf
	
	fileList As String[]
	While fileList.Length >= 0
		fileList.Remove()
	EndWhile
	
	errorList As JMemoError[]
	While errorList.Length >= 0
		errorList.Remove()
	EndWhile
	
	file$ = GetFirstFile(0)
	If mode = 1  //all
		While file$ <> ""
			If CompareString(Lower(Right(file$, 4)), ".txt", 1, -1) Then fileList.InsertSorted(file$)
			file$ = GetNextFile()
		EndWhile
		While _MusicLibraryList.Length >= 0
			_MusicLibraryList.Remove()
		EndWhile
		While _MusicLibraryShaList.Length >= 0
			_MusicLibraryShaList.Remove()
		EndWhile
	ElseIf mode = 2  //new
		While file$ <> ""
			If CompareString(Lower(Right(file$, 4)), ".txt", 1, -1)
				For i = 0 To _MusicLibraryList.Length
					If _MusicLibraryList[i].MemoFiles[1] = file$ Then Goto DontAdd
					If _MusicLibraryList[i].MemoFiles[2] = file$ Then Goto DontAdd
					If _MusicLibraryList[i].MemoFiles[3] = file$ Then Goto DontAdd
				Next
				fileList.InsertSorted(file$)
				DontAdd:
			EndIf
			file$ = GetNextFile()
		EndWhile
	ElseIf mode = 3  //recently 10
		tempFileList As _MusicLibraryTempFileListItem[]
		For i = 0 To _MusicLibraryList.Length
			For j = 1 To 3
				If _MusicLibraryList[i].Sha256Strings[j] = "" Then Continue
				tItem As _MusicLibraryTempFileListItem
				tItem.UnixTime = _MusicLibraryList[i].UpdatedTimes[j]
				tItem.FileName = _MusicLibraryList[i].MemoFiles[j]
				tempFileList.InsertSorted(tItem)
			Next
		Next
		
		For i = 0 To 9
			If tempFileList.Length - i < 0 Then Exit
			fileList.InsertSorted(tempFileList[tempFileList.Length - i].FileName)
		Next
		While tempFileList.Length >= 0
			tempFileList.Remove()
		EndWhile
		
		For i = 0 To _MusicLibraryList.Length
			For j = 1 To 3
				If fileList.Find(_MusicLibraryList[i].MemoFiles[j]) >= 0
					_MusicLibraryList[i].Lengths[j] = 0.0
					_MusicLibraryList[i].Levels[j] = 0
					_MusicLibraryList[i].MemoFiles[j] = ""
					_MusicLibraryList[i].Sha256Strings[j] = ""
					_MusicLibraryList[i].UpdatedTimes[j] = 0
					_MusicLibraryList[i].NotesCounts[j] = 0
					_MusicLibraryList[i].HoldsCounts[j] = 0
					For k = 0 To 119
						_MusicLibraryList[i].MusicBarLevels[j,k] = 0
					Next
					
					If _MusicLibraryList[i].Sha256Strings[1] = "" And _MusicLibraryList[i].Sha256Strings[2] = "" And _MusicLibraryList[i].Sha256Strings[3] = ""
						_MusicLibraryList.Remove(i)
						dec i
					EndIf
				EndIf
			Next
		Next
	Else  // Flush
		While file$ <> ""
			If CompareString(Lower(Right(file$, 4)), ".txt", 1, -1) Then fileList.InsertSorted(file$)
			file$ = GetNextFile()
		EndWhile
		For i = 0 To _MusicLibraryList.Length
			For j = 1 To 3
				If fileList.Find(_MusicLibraryList[i].MemoFiles[j]) < 0
					_MusicLibraryList[i].Lengths[j] = 0.0
					_MusicLibraryList[i].Levels[j] = 0
					_MusicLibraryList[i].MemoFiles[j] = ""
					_MusicLibraryList[i].Sha256Strings[j] = ""
					_MusicLibraryList[i].UpdatedTimes[j] = 0
					_MusicLibraryList[i].NotesCounts[j] = 0
					_MusicLibraryList[i].HoldsCounts[j] = 0
					For k = 0 To 119
						_MusicLibraryList[i].MusicBarLevels[j,k] = 0
					Next
					
					If _MusicLibraryList[i].Sha256Strings[1] = "" And _MusicLibraryList[i].Sha256Strings[2] = "" And _MusicLibraryList[i].Sha256Strings[3] = ""
						_MusicLibraryList.Remove(i)
					EndIf
				EndIf
			Next
		Next
		While fileList.Length >= 0
			fileList.Remove()
		EndWhile
	EndIf
	SetTextString(progTextId, "0 / " + Str(fileList.Length + 1))
	
	Sync()
	For fileListIdx = 0 To fileList.Length
		memo As JMemo
		memoError As JMemoError
		memoError.Code = 0
		memo = JMemoParser_Parse(fileList[fileListIdx], memoError, 0.0)
		If memoError.Code > 0
			errorList.Insert(memoError)
			//InvokeError(memoError.Message)
			//InvokeError("Memo error (" + fileList[fileListIdx] + ")")
		Else
			shaItem As MusicLibraryShaListItem
			shaItem.Sha256String = memo.Sha256String
			shaItem.Title = memo.Title
			shaItem.Artist = memo.Artist
			shaItem.FileName = fileList[fileListIdx]
			//If _MusicLibraryShaList.Find(shaItem) >= 0 Then _MusicLibraryShaList.Remove(_MusicLibraryShaList.Find(shaItem))
			_MusicLibraryShaList.InsertSorted(shaItem)
			
			createNew = 0
			/*For i = 0 To _MusicLibraryList.Length
				If _MusicLibraryList[i].Title = memo.Title And _MusicLibraryList[i].Artist = memo.Artist
					createNew = 0
				Else
					createNew = 1
				EndIf
			Next*/
			listIdx = _MusicLibraryList.Find(memo.Title)
			If listIdx < 0
				createNew = 1
			ElseIf _MusicLibraryList[listIdx].Artist <> memo.Artist
				createNew = 1
				For i = listIdx To _MusicLibraryList.Length
					If _MusicLibraryList[i].Title <> memo.Title Then Exit
					If _MusicLibraryList[i].Artist = memo.Artist
						listIdx = i
						createNew = 0
						Exit
					EndIf
				Next
			EndIf
			
			//createNew= 1  //debug
			If createNew
				item As MusicLibraryItem
				item.Title = memo.Title
				item.Artist = memo.Artist
				item.MusicFile = memo.MusicFile
				item.CoverFile = memo.CoverFile
				item.Tempo = memo.Tempo
				item.PreListeningPlayhead = memo.PreListeningPlayhead
				For i = 0 To 3
					If i = memo.Difficulty
						item.Lengths[i] = memo.Length
						item.Levels[i] = memo.Level
						item.MemoFiles[i] = fileList[fileListIdx]
						item.Sha256Strings[i] = memo.Sha256String
						item.UpdatedTimes[i] = GetUnixTime()
						item.NotesCounts[i] = memo.NotesCount
						item.HoldsCounts[i] = memo.HoldsCount
						For j = 0 To 119
							item.MusicBarLevels[i,j] = memo.MusicBar[j].Level
						Next
					Else
						item.Lengths[i] = 0.0
						item.Levels[i] = 0
						item.MemoFiles[i] = ""
						item.Sha256Strings[i] = ""
						item.UpdatedTimes[i] = 0
						item.NotesCounts[i] = 0
						item.HoldsCounts[i] = 0
						For j = 0 To 119
							item.MusicBarLevels[i,j] = 0
						Next
					EndIf
				Next
				/*idxToInsert = 0
				For i = 0 To _MusicLibraryList.Length
					If Lower(_MusicLibraryList.Title) < 
				Next
				_MusicLibraryList.Insert(item, idxtToInsert)*/
				_MusicLibraryList.InsertSorted(item)
			Else
				If _MusicLibraryList[listIdx].Sha256Strings[memo.Difficulty] <> ""
					errorItem As JMemoError
					errorItem.Code = 17
					errorItem.Message = GetLocalizedString("ERR_MEMO_FILE_HAS_BEEN_OVERRIEDED") + " (" + _MusicLibraryList[listIdx].MemoFiles[memo.Difficulty] + ")"
					errorList.Insert(errorItem)
				EndIf
				_MusicLibraryList[listIdx].Lengths[memo.Difficulty] = memo.Length
				_MusicLibraryList[listIdx].Levels[memo.Difficulty] = memo.Level
				_MusicLibraryList[listIdx].MemoFiles[memo.Difficulty] = fileList[fileListIdx]
				_MusicLibraryList[listIdx].Sha256Strings[memo.Difficulty] = memo.Sha256String
				_MusicLibraryList[listIdx].UpdatedTimes[memo.Difficulty] = GetUnixTime()
				_MusicLibraryList[listIdx].NotesCounts[memo.Difficulty] = memo.NotesCount
				_MusicLibraryList[listIdx].HoldsCounts[memo.Difficulty] = memo.HoldsCount
				
				For i = 0 To 119
					_MusicLibraryList[listIdx].MusicBarLevels[memo.Difficulty,i] = memo.MusicBar[i].Level
				Next
			EndIf
		EndIf
		SetSpriteSize(progBarSpriteId, progBarMaxWidth# * (fileListIdx+1) / (fileList.Length+1), progBarHeight#)
		SetTextString(progTextId, Str(fileListIdx+1) + " / " + Str(fileList.Length + 1))
		Sync()
	Next
	
	Sleep(100)
	
	DeleteSprite(progBackSpriteId)
	DeleteSprite(progBarBackSpriteId)
	DeleteSprite(progBarSpriteId)
	
	SetTextString(titleTextId, GetLocalizedString("LIBRARY_UPDATING_COMPTETE"))
	SetTextString(progTextId, GetLocalizedString("LIBRARY_PRESS_ANY_BUTTON_TO_CONTINUE"))
	
	errorTextId = CreateText("")
	SetTextFont(errorTextId, GetLanguageFont())
	SetTextColor(errorTextId, 255, 255, 255, 255)
	SetTextAlignment(errorTextId, 1)
	SetTextDepth(errorTextId, DEPTH_LIB_TEXT)
	SetTextSize(errorTextId, GetUpperScreenWidth() * 0.04 * GetLanguageFontScale())
	SetTextLineSpacing(errorTextId, GetTextSize(errorTextId) * GetLanguageFontLineSpacing())
	SetTextPosition(errorTextId, GetUpperScreenX() + GetUpperScreenWidth() * 0.5, GetUpperScreenY() + GetUpperScreenHeight() * 0.5)
	
	errorTitleIds As Integer[]
	While errorTitleIds.Length >= 0
		errorTitleIds.Remove()
	EndWhile
	errorTextIds As Integer[]
	While errorTextIds.Length >= 0
		errorTextIds.Remove()
	EndWhile
	
	If errorList.Length >= 0
		errorText$ = GetLocalizedString("LIBRARY_N_ERRORS_OCCURED")
		errorText$ = ReplaceString(errorText$, "%d", Str(errorList.Length + 1), -1)
		SetTextString(errorTextId, errorText$)
		For i = 0 To errorList.Length
			if i > 15 Then Exit
			errorText$ = GetLocalizedString("LIBRARY_ERROR_N_CODE_C")
			errorText$ = ReplaceString(errorText$, "%d", Str(i + 1), -1)
			errorText$ = ReplaceString(errorText$, "%c", Str(errorList[i].Code), -1)
			errorTitleId = CreateText(errorText$)
			If GetLanguageBoldFont() <> 0
				SetTextFont(errorTitleId, GetLanguageBoldFont())
			Else
				SetTextFont(errorTitleId, GetLanguageFont())
				SetTextBold(errorTitleId, 1)
			EndIf
			SetTextColor(errorTitleId, 255, 255, 255, 255)
			SetTextAlignment(errorTitleId, 0)
			SetTextDepth(errorTitleId, DEPTH_LIB_TEXT)
			SetTextSize(errorTitleId, GetUpperScreenWidth() * 0.025 * GetLanguageFontScale())
			SetTextLineSpacing(errorTitleId, GetTextSize(errorTitleId) * GetLanguageFontLineSpacing())
			SetTextPosition(errorTitleId, GetJButtonX(i+1) + GetJButtonSize() * 0.05, GetJButtonY(i+1) + GetJButtonSize() * 0.05)
			errorTitleIds.Insert(errorTitleId)
			errorMsgId = CreateText(errorList[i].Message)
			SetTextFont(errorMsgId, GetLanguageFont())
			SetTextColor(errorMsgId, 255, 255, 255, 255)
			SetTextAlignment(errorMsgId, 0)
			SetTextDepth(errorMsgId, DEPTH_LIB_TEXT)
			SetTextSize(errorMsgId, GetUpperScreenWidth() * 0.02 * GetLanguageFontScale())
			SetTextLineSpacing(errorMsgId, GetTextSize(errorMsgId) * GetLanguageFontLineSpacing())
			SetTextPosition(errorMsgId, GetJButtonX(i+1) + GetJButtonSize() * 0.05, GetJButtonY(i+1) + GetJButtonSize() * 0.18)
			SetTextMaxWidth(errorMsgId, GetJButtonSize() - GetTextX(errorMsgId) + GetJButtonX(i+1))
			errorTextIds.Insert(errorMsgId)
		Next
	EndIf
	
	Sync()
	blinkTimer# = 0.0
	While 1
		Sync()
		inc blinkTimer#, GetFrameTime()
		If blinkTimer# > 0.667 Then SetTextVisible(errorTextId, 0)
		If blinkTimer# > 1.0
			SetTextVisible(errorTextId, 1)
			blinkTimer# = 0.0
		EndIf
		UpdateJButtonStates()
		cont = 0
		For i = 0 To 16
			If GetJButtonPressed(i) Then cont = 1
		Next
		If cont Then Exit
	EndWhile
	
	For i = 0 To errorTitleIds.Length
		DeleteText(errorTitleIds[i])
	Next
	For i = 0 To errorTextIds.Length
		DeleteText(errorTextIds[i])
	Next
	
	DeleteSprite(backSpriteId)
	DeleteText(titleTextId)
	DeleteText(progTextId)
	DeleteText(errorTextId)
	DeleteImage(blackImage)
	DeleteImage(whiteImage)
EndFunction
