
Type _NoteTimingOffsetsItem
	Key As String
	Value As Integer
EndType
Global _NoteTimingOffsetsList As _NoteTimingOffsetsItem[]

Function ReadNoteTimingOffsetsFromFile()
	If Not GetFileExists("raw:" + GetReadPath() + "notetimingoffsets.txt") Then ExitFunction
	fileId = OpenToRead("/notetimingoffsets.txt")
	CheckError()
	If fileId = 0 Then ExitFunction
	
	While _NoteTimingOffsetsList.Length >= 0
		_NoteTimingOffsetsList.Remove()
	EndWhile
	
	line As String
	While Not FileEOF(fileId)
		offsetItem As _NoteTimingOffsetsItem
		line = ReadLine(fileId)
		// Remove Comment (//)
		commentIndex = FindString(line, "//")
		If commentIndex > 0 Then line = Left(line, commentIndex - 1)
		// If a=b type
		If FindStringCount(line, "=") >= 1
			offsetItem.Key = Lower(Trim(Left(line, FindString(line, "=") - 1)))
			offsetItem.Value = Val(Trim(Right(line, Len(line) - FindString(line, "="))))
			_NoteTimingOffsetsList.InsertSorted(offsetItem)
		EndIf
	EndWhile
	
	CloseFile(fileId)
EndFunction

Function WriteNoteTimingOffsetsToFile()
	If _NoteTimingOffsetsList.Length < 0
		If GetFileExists("raw:" + GetReadPath() + "notetimingoffsets.txt") Then DeleteFile("raw:" + GetReadPath() + "notetimingoffsets.txt")
		ExitFunction
	EndIf
	file = OpenToWrite("raw:" + GetReadPath() + "notetimingoffsets.txt")
	CheckError()
	If file = 0
		InvokeError("Failed to write note timing offsets file.")
		ExitFunction
	EndIf
	
	For i = 0 To _NoteTimingOffsetsList.Length
		shaItemIdx = _MusicLibraryShaList.Find(_NoteTimingOffsetsList[i].Key)
		If shaItemIdx < 0 /*Or _NoteTimingOffsetsList[i].Value = 0*/ Then Continue
		shaItem As MusicLibraryShaListItem
		shaItem = _MusicLibraryShaList[shaItemIdx]
		//WriteString(file, shaItem.Sha256String + " = " + Str(_NoteTimingOffsetsList[i].Value) + " // " + shaItem.Title + " - " + shaItem.Artist)
		WriteString(file, shaItem.Sha256String + " = " + Str(_NoteTimingOffsetsList[i].Value) + " // " + shaItem.FileName)
	Next
	CloseFile(file)
EndFunction

Function GetNoteTimingOffset(szSha As String)
	idx = _NoteTimingOffsetsList.Find(szSha)
	If idx < 0 Then ExitFunction 0
EndFunction _NoteTimingOffsetsList[idx].Value

Function SetNoteTimingOffset(szSha As String, iValue As Integer)
	If szSha = "" Then ExitFunction
	idx = _NoteTimingOffsetsList.Find(szSha)
	If idx >= 0
		If iValue <> 0
			_NoteTimingOffsetsList[idx].Value = iValue
		Else
			_NoteTimingOffsetsList.Remove(idx)
		EndIf
	Else
		If iValue <> 0
			offsetItem As _NoteTimingOffsetsItem
			offsetItem.Key = szSha
			offsetItem.Value = iValue
			_NoteTimingOffsetsList.InsertSorted(offsetItem)
		EndIf
	EndIf
EndFunction
