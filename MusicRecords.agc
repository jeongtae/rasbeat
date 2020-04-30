#include "Constants.agc"
#include "ErrorReporting.agc"

Type MusicRecordsItem
	ShaString As String
	HighScore As Integer
	HighScoredTime As Integer  // unix local (1970-01-01 may not 0, this is not utc0)
	FullCombo As Integer
	LastPlayedTime As Integer  // unix local (1970-01-01 may not 0, this is not utc0)
	MusicBarColors As Integer[119]
EndType

Global _MusicRecordsList As MusicRecordsItem[]

Function CompactMusicRecords()
	For i = 0 To _MusicRecordsList.Length
		found = 0
		For j = 0 To _MusicLibraryList.Length
			If found Then Exit
			For k = 0 To _MusicLibraryList[j].Sha256Strings.Length
				If _MusicRecordsList[i].ShaString = _MusicLibraryList[j].Sha256Strings[k]
					found = 1
					Exit
				EndIf
			Next
		Next
		If found = 0
			_MusicRecordsList.Remove(i)
			dec i
		EndIf
	Next
EndFunction

Function ReadMusicRecordsFromFile()
	file = OpenToRead("/records.dat")
	CheckError()
	If file = 0 Then ExitFunction
	
	tempList As MusicRecordsItem[]
	
	failedToRead = 0
	While Not FileEOF(file) And Not failedToRead
		item As MusicRecordsItem
		
		pos = GetFilePos(file)
		If pos = GetFileSize(file) Then Exit
		item.ShaString = ReadString2(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.HighScore = ReadInteger(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.HighScoredTime = ReadInteger(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.FullCombo = ReadInteger(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		pos = GetFilePos(file)
		item.LastPlayedTime = ReadInteger(file)
		If pos = GetFilePos(file) Then failedToRead = 1
		
		For i = 0 To 119
			pos = GetFilePos(file)
			item.MusicBarColors[i] = ReadByte(file)
			If pos = GetFilePos(file) Then failedToRead = 1
		Next
		
		If pos = GetFilePos(file) Then failedToRead = 1
		tempList.InsertSorted(item)
	EndWhile
	
	CloseFile(file)
	
	If failedToRead
		InvokeError("Failed to read records file.")
		ExitFunction
	EndIf
	
	While _MusicRecordsList.Length >= 0
		For i = 0 To 119
			_MusicRecordsList[_MusicRecordsList.Length].MusicBarColors.Remove()
		Next
		_MusicRecordsList.Remove()
	EndWhile
	_MusicRecordsList = tempList
EndFunction

Function WriteMusicRecordsToFile()
	file = OpenToWrite("raw:" + GetReadPath() + "records.dat")
	CheckError()
	If file = 0
		InvokeError("Failed to write records file.")
		ExitFunction
	EndIf
	
	For i = 0 To _MusicRecordsList.Length
		WriteString2(file, _MusicRecordsList[i].ShaString)
		WriteInteger(file, _MusicRecordsList[i].HighScore)
		WriteInteger(file, _MusicRecordsList[i].HighScoredTime)
		WriteInteger(file, _MusicRecordsList[i].FullCombo)
		WriteInteger(file, _MusicRecordsList[i].LastPlayedTime)
		For j = 0 To 119
			WriteByte(file, _MusicRecordsList[i].MusicBarColors[j])
		Next
	Next
	
	CloseFile(file)
EndFunction

Function GetMusicRecords(sSha As String)
	emptyItem As MusicRecordsItem
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Or listIdx < 0 Then ExitFunction emptyItem
EndFunction _MusicRecordsList[listIdx]

Function GetMusicRecordsHighScore(sSha As String)
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Or listIdx < 0 Then ExitFunction 0
EndFunction _MusicRecordsList[listIdx].HighScore

Function GetMusicRecordsHighScoredTime(sSha As String)
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Or listIdx < 0 Then ExitFunction 0
EndFunction _MusicRecordsList[listIdx].HighScoredTime

Function GetMusicRecordsFullCombo(sSha As String)
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Or listIdx < 0 Then ExitFunction 0
EndFunction _MusicRecordsList[listIdx].FullCombo

Function GetMusicRecordsLastPlayedTime(sSha As String)
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Or listIdx < 0 Then ExitFunction 0
EndFunction _MusicRecordsList[listIdx].LastPlayedTime

Function GetMusicRecordsMusicBarColors(sSha As String)
	emptyArr As Integer[119]
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Or listIdx < 0
		For i = 0 To 119
			emptyArr[i] = 1
		Next
		ExitFunction emptyArr
	EndIf
EndFunction _MusicRecordsList[listIdx].MusicBarColors

Function SetMusicRecords(recordItem Ref As MusicRecordsItem)
	If recordItem.ShaString = "" Or recordItem.MusicBarColors.Length <> 119 Then ExitFunction
	
	listIdx = _MusicRecordsList.Find(recordItem.ShaString)
	
	If listIdx < 0
		item As MusicRecordsItem
		item.ShaString = recordItem.ShaString
		item.HighScore = recordItem.HighScore
		item.HighScoredTime = recordItem.HighScoredTime
		item.FullCombo = recordItem.FullCombo
		item.LastPlayedTime = recordItem.LastPlayedTime
		For i = 0 To 119
			item.MusicBarColors[i] = recordItem.MusicBarColors[i]
		Next
		_MusicRecordsList.InsertSorted(item)
	Else
		_MusicRecordsList[listIdx].HighScore = recordItem.HighScore
		_MusicRecordsList[listIdx].HighScoredTime = recordItem.HighScoredTime
		_MusicRecordsList[listIdx].FullCombo = recordItem.FullCombo
		_MusicRecordsList[listIdx].LastPlayedTime = recordItem.LastPlayedTime
		For i = 0 To 119
			_MusicRecordsList[listIdx].MusicBarColors[i] = recordItem.MusicBarColors[i]
		Next
	EndIf
EndFunction

Function SetMusicRecordsLastPlayedTime(sSha As String, iTime As Integer)
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Then ExitFunction
	If listIdx < 0
		item As MusicRecordsItem
		item.ShaString = sSha
		item.HighScore = 0
		item.HighScoredTime =  0
		item.FullCombo = 0
		item.LastPlayedTime = iTime
		For i = 0 To 119
			item.MusicBarColors[i] = 1
		Next
		_MusicRecordsList.InsertSorted(item)
	Else
		_MusicRecordsList[listIdx].LastPlayedTime = iTime
	EndIf
EndFunction

Function SetMusicRecordsFullCombo(sSha As String, iFullCombo As Integer)
	listIdx = _MusicRecordsList.Find(sSha) 	
	If sSha = "" Then ExitFunction
	If listIdx < 0
		item As MusicRecordsItem
		item.ShaString = sSha
		item.HighScore = 0
		item.HighScoredTime =  0
		item.FullCombo = iFullCombo
		item.LastPlayedTime = 0
		For i = 0 To 119
			item.MusicBarColors[i] = 1
		Next
		_MusicRecordsList.InsertSorted(item)
	Else
		_MusicRecordsList[listIdx].FullCombo = iFullCombo
	EndIf
EndFunction

/*
Function SetMusicRecords(sSha As String, iHighScore As Integer, iHighScoredTime As Integer, iLastPlayedTime As Integer, aMusicBarColors Ref As Integer[])
	If sSha = "" Or aMusicBarColors.Length <> 119 Then ExitFunction
	
	listIdx = _MusicRecordsList.Find(sSha) 	
	If listIdx < 0
		item As MusicRecordsItem
		item.ShaString = sSha
		item.HighScore = iHighScore
		item.HighScoredTime = iHighScoredTime
		item.LastPlayedTime = iLastPlayedTime
		For i = 0 To 119
			item.MusicBarColors[i] = aMusicBarColors[i]
		Next
		_MusicRecordsList.InsertSorted(item)
	Else
		_MusicRecordsList[listIdx].HighScore = iHighScore
		_MusicRecordsList[listIdx].HighScoredTime = iHighScoredTime
		_MusicRecordsList[listIdx].LastPlayedTime = iLastPlayedTime
		For i = 0 To 119
			_MusicRecordsList[listIdx].MusicBarColors[i] = aMusicBarColors[i]
		Next
	EndIf
EndFunction*/
/*
Function SetMusicRecordsScore(sSha As String, iScore As Integer)
EndFunction

Function SetMusicRecordsMusicBarColors(sSha As String, iScore As Integer)
EndFunction

Function SetMusicRecordsUnixTime(sSha As String, iUnixTime As Integer)
EndFunction
*/
