#include "Constants.agc"
#include "ErrorReporting.agc"
#include "StringUtil.agc"
#include "Localizing.agc"

#constant JMemoDifficultyNone (0)
#constant JMemoDifficultyBasic (1)
#constant JMemoDifficultyAdvanced (2)
#constant JMemoDifficultyExtreme (3)

#constant JMEMO_BUTTON_CHARS ("口①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ┼｜―∨∧＞＜")  // left 4 chars
#constant JMEMO_BUTTON_NUM_CHARS ("①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ")
#constant JMEMO_HOLD_LASER ("┼｜―")
#constant JMEMO_HOLD_SIGNS ("∨∧＞＜")
#constant JMEMO_NOTES_CHARS ("－①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ")  // right chars

Type JMemoTableItem
	Time As Float  // can be negative
	Button As Integer  // 1~16
	ArrowIndex As Integer  // 1~16
	HoldingEndTime As Float
	Judged As Integer // 0 or 1
EndType

Type JMemoMusicBarItem
	TableIndexStart As Integer
	TableIndexEnd As Integer
	Level As Integer // 0~8
	Color As Integer // 0~3
EndType

/*
 TableItemIndex
 1  2  3  4
 5  6  7  8
 9 10 11 12
13 14 15 16
*/

Type JMemo
	Title As String
	Artist As String
	Difficulty As Integer //1~3 or 0
	Level As Integer //1~10 or 0
	Tempo As String
	Length As Float
	PreListeningPlayhead As Float
	MusicFile As String
	CoverFile As String
	Table As JMemoTableItem[]
	MusicBar As JMemoMusicBarItem[]  // 0~119
	BeatTimings As Float[]
	NotesCount As Integer  // 0~
	HoldsCount As Integer
	Sha256String As String
EndType

Type JMemoError
	Code As Integer
	Message As String
EndType

Type _JMemoQueueItem
	Time As Float
	Pointer As Integer  // 1~16
EndType

Function JMemoParser_Parse(szFile As String, tError Ref As JMemoError, fOffset As Float)
	emptyMap As JMemo
	// Check txt file and open
	If Not GetFileExists(MUSIC_PATH + szFile)
		tError.Code = 1
		tError.Message = GetLocalizedString("ERR_MEMO_FILE_IS_NOT_EXISTING") + " (" + MUSIC_PATH + szFile + ")"
		ExitFunction emptyMap
	EndIf
	fileId = OpenToRead(MUSIC_PATH + szFile)
	CheckError()
	If fileId = 0
		tError.Code = 2
		tError.Message = GetLocalizedString("ERR_MEMO_FAILED_TO_OPEN_FILE") + " (" + MUSIC_PATH + szFile + ")"
		ExitFunction emptyMap
	EndIf
	
	// Initialize varaibles
	memo As JMemo
	memo.Title = ""
	memo.Artist = ""
	memo.Difficulty = JMemoDifficultyNone
	memo.Level = 0
	memo.Length = 0.0
	memo.PreListeningPlayhead = 0.0
	memo.Tempo = ""
	memo.MusicFile = ""
	memo.CoverFile = ""
	memo.NotesCount = 0
	memo.HoldsCount = 0
	isRasmemo As Integer = 0
	offset As Float = 0.0  // time offset
	curTempo As Float = 0.0
	curRow As Integer = 0  // 1~4 or 0
	buttonsMap As String[16]
	notesQueue As _JMemoQueueItem[]
	watingEndPointMap As Integer[16]  // if wating end point then value >= 0 (jMemoIdx)
	For i = 1 To 16
		watingEndPointMap[i] = -1
	Next
	
	// Parsing
	line As String
	lineNumber As Integer = 1
	
	holdByArrow = 0
	
	partialBeatCount = 0
	While Not FileEOF(fileId)
		line = ReadLine(fileId)
		// Remove comment
		commentIndex = FindString(line, "//")
		If commentIndex > 0 Then line = Left(line, commentIndex - 1)
		// If a=b form
		If FindStringCount(line, "=") >= 1
			// If interrupting buttons map
			If curRow > 1
				tError.Code = 3
				tError.Message = GetLocalizedString("ERR_MEMO_INTERRUPTING_BUTTONS_MAP") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
				CloseFile(fileId)
				ExitFunction emptyMap
			EndIf
			// Trim key and value
			leftPart$ = Trim(Left(line, FindString(line, "=") - 1))
			rightPart$ = Trim(Right(line, Len(line) - FindString(line, "=")))
			// Read
			Select Lower(leftPart$)
				Case "#title":  // Title
					If memo.Title = "" Then memo.Title = rightPart$
				EndCase
				Case "#artist":  // Artist
					If memo.Artist = "" Then memo.Artist = rightPart$
				EndCase
				Case "#dif":  // Difficulty
					If memo.Difficulty = JMemoDifficultyNone
						rightPart$ = Lower(rightPart$)
						If rightPart$ = "bsc" Or rightPart$ = "basic" Or Val(rightPart$) = JMemoDifficultyBasic
							memo.Difficulty = JMemoDifficultyBasic
						ElseIf rightPart$ = "adv" Or rightPart$ = "advanced" Or Val(rightPart$) = JMemoDifficultyAdvanced
							memo.Difficulty = JMemoDifficultyAdvanced
						ElseIf rightPart$ = "ext" Or rightPart$ = "extreme" Or Val(rightPart$) = JMemoDifficultyExtreme
							memo.Difficulty = JMemoDifficultyExtreme
						Else
							memo.Difficulty = JMemoDifficultyNone
							tError.Code = 18
							tError.Message = GetLocalizedString("ERR_MEMO_SPECIFIED_WRONG_DIF") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
					EndIf
				EndCase
				Case "#lev":  // Artist
					If memo.Level = 0
						memo.Level = Val(rightPart$)
						If memo.Level > 10 Or memo.Level < 0
							memo.Level = 0
							tError.Code = 20
							tError.Message = GetLocalizedString("ERR_MEMO_SPECIFIED_WRONG_LEVEL") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
					EndIf
				EndCase
				Case "#tempo":  // Tempo (BPM)
					If memo.Tempo = ""
						memo.Tempo = rightPart$
					EndIf
				EndCase
				Case "t":  // Tempo (BPM)
					If ValFloat(rightPart$) <= 0
						tError.Code = 4
						tError.Message = GetLocalizedString("ERR_MEMO_SPECIFIED_WRONG_TEMPO") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
						CloseFile(fileId)
						ExitFunction emptyMap
					EndIf
					curTempo = ValFloat(rightPart$)
					If memo.Tempo = "" Then memo.Tempo = Str(Round(curTempo))
				EndCase
				Case "a":  // Move Playhead Absolutely
					offset = ValFloat(rightPart$) * 0.001
					If memo.Table.Length >= 0
						If offset <= memo.Table[memo.Table.Length].Time
							tError.Code = 22
							tError.Message = GetLocalizedString("ERR_MEMO_SPECIFIED_WRONG_TIME") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
					EndIf
				EndCase
				Case "r":  // Move Playhead Relative
					inc offset, ValFloat(rightPart$) * 0.001
					If memo.Table.Length >= 0
						If offset < memo.Table[memo.Table.Length].Time
							tError.Code = 22
							tError.Message = GetLocalizedString("ERR_MEMO_SPECIFIED_WRONG_TIME") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
					EndIf
				EndCase
				Case "m":  // Music file name
					If memo.MusicFile = ""
						rightPart$ = ReplaceString(rightPart$, "/", "", -1)
						If Lower(Right(rightPart$, 4)) <> ".mp3"
							tError.Code = 5
							tError.Message = GetLocalizedString("ERR_MEMO_SUPPORTS_ONLY_MP3") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
						If Not GetFileExists(MUSIC_PATH + rightPart$)
							tError.Code = 6
							tError.Message = GetLocalizedString("ERR_MEMO_MUSIC_FILE_IS_NOT_EXISTING") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
						memo.MusicFile = rightPart$
					EndIf
				EndCase
				Case "#holdbyarrow"
					holdByArrow = Val(rightPart$)
					If holdByArrow <> 0 Then holdByArrow = 1
				EndCase
				Case "prelistening":
					If memo.PreListeningPlayhead = 0.0
						If ValFloat(rightPart$) < 0.0
							tError.Code = 7
							tError.Message = GetLocalizedString("ERR_MEMO_SPECIFIED_WRONG_PRELISTENINGPLAYHEAD") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
						memo.PreListeningPlayhead = ValFloat(rightPart$)
					EndIf
				EndCase
				Case "cover":  // Cover image file name
					If memo.CoverFile = ""
						rightPart$ = ReplaceString(rightPart$, "/", "", -1)
						If Lower(Right(rightPart$, 4)) <> ".png" And Lower(Right(rightPart$, 4)) <> ".jpg"
							tError.Code = 8
							tError.Message = GetLocalizedString("ERR_MEMO_SUPPORTS_ONLY_PNG_JPG") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
						If Not GetFileExists(MUSIC_PATH + rightPart$)
							tError.Code = 9
							tError.Message = GetLocalizedString("ERR_MEMO_COVER_FILE_IS_NOT_EXISTING") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
							CloseFile(fileId)
							ExitFunction emptyMap
						EndIf
						memo.CoverFile = rightPart$
					EndIf
				EndCase
				Case Default: // Will be ignored
				EndCase
			EndSelect
		// If #memoN form
		ElseIf Lower(Trim(line)) = "#memo" Or Lower(Trim(line)) = "#memo1" Or Lower(Trim(line)) = "#memo2"
			tError.Code = 10
			tError.Message = GetLocalizedString("ERR_MEMO_CAN_BE_PARSED_ONLY_RASMEMO_TYPE") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
			CloseFile(fileId)
			ExitFunction emptyMap
		ElseIf Lower(Trim(line)) = "#rasmemo"
			isRasmemo = 1
		// If 口③④口 |①－②－| form
		ElseIf Len(ReplaceString(line, " ", "", -1)) >= 4 And FindCharsCount(Left(ReplaceString(line, " ", "", -1), 4), JMEMO_BUTTON_CHARS) = 4 
			// Remove spaces
			line = ReplaceString(line, " ", "", -1)
			
			// Is Rasmemo
			If isRasmemo = 0
				tError.Code = 10
				tError.Message = GetLocalizedString("ERR_MEMO_CAN_BE_PARSED_ONLY_RASMEMO_TYPE") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
				CloseFile(fileId)
				ExitFunction emptyMap
			EndIf
			
			// Validate tempo
			If curTempo = 0
				tError.Code = 11
				tError.Message = GetLocalizedString("ERR_MEMO_TEMPO_IS_ZERO") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
				CloseFile(fileId)
				ExitFunction emptyMap
			EndIf
			
			If curRow = 0 Then inc curRow
			
			// Write buttons map (always exists)
			For i = 1 To 4 Step 1
				buttonsMap[(curRow - 1) * 4 + i] = Mid(line, i, 1)
			Next i
			
			// Write notes queue (when exists)
			If Len(line) > 4
				If Len(line) < 7 Or Mid(line, 5, 1) <> "|" Or Mid(line, Len(line), 1) <> "|" Or FindCharsCount(Mid(line, 6, Len(line) - 6), JMEMO_NOTES_CHARS) <> Len(line) - 6
					tError.Code = 12
					tError.Message = GetLocalizedString("ERR_MEMO_UNINTELLIGIBLE_LINE") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
					CloseFile(fileId)
					ExitFunction emptyMap
				EndIf
				tempQueue As Integer[]
				While tempQueue.Length >= 0
					tempQueue.Remove()
				EndWhile
				// Make temp queue what stores button pointer number
				For i = 6 To Len(line) - 1 Step 1
					tempQueue.Insert(FindString(JMEMO_NOTES_CHARS, Mid(line, i, 1)) - 1)
				Next
				// Add to notes queue
				For i = 0 To tempQueue.Length Step 1
					If tempQueue[i] > 0
						queueItem As _JMemoQueueItem
						
						Select tempQueue.Length
							Case 2: //야매? ( |---| 일때)
								queueItem.Time = offset + ((60.0 / curTempo * 1.0) * i / (tempQueue.Length+1))*0.75
							EndCase
							Case 1: //야매? ( |--| 일때)
								queueItem.Time = offset + ((60.0 / curTempo * 1.0) * i / (tempQueue.Length+1))*0.5
							EndCase
							Case 0: //야매? ( |-| 일때)
								queueItem.Time = offset + ((60.0 / curTempo * 1.0) * i / (tempQueue.Length+1))*0.25
							EndCase
							Case Default:
								queueItem.Time = offset + (60.0 / curTempo * 1.0) * i / (tempQueue.Length+1)  // There is 1 beat at one line
							EndCase
						EndSelect
						
						queueItem.Pointer = tempQueue[i]
						notesQueue.Insert(queueItem)
					EndIf
				Next
				
				
				If memo.BeatTimings.Length < 0 Then memo.BeatTimings.Insert(offset)
				
				// Add 1 beat time
				inc offset, 60.0 / curTempo * 1.0
				
				
				Select tempQueue.Length
					//야매? ( |---| 일때)
					Case 2:
						inc partialBeatCount, 3
						dec offset, 60.0 / curTempo * 0.25
						If partialBeatCount = 4
							memo.BeatTimings.Insert(offset)
							partialBeatCount = 0
						EndIf
					EndCase
					//야매? ( |--| 일때)
					Case 1:
						inc partialBeatCount, 2
						dec offset, 60.0 / curTempo * 0.5
						If partialBeatCount = 4
							memo.BeatTimings.Insert(offset)
							partialBeatCount = 0
						EndIf
					EndCase
					//야매? ( |-| 일때)
					Case 0:
						inc partialBeatCount, 1 
						dec offset, 60.0 / curTempo * 0.75
						If partialBeatCount = 4
							memo.BeatTimings.Insert(offset)
							partialBeatCount = 0
						EndIf
					EndCase
					Case Default:
						// Add beat timing
						memo.BeatTimings.Insert(offset)
						partialBeatCount = 0
					EndCase
				EndSelect
				
				
			EndIf
			
			inc curRow
			
			// Flush buttons map and notes queue where rows complete
			If curRow = 5
				holdMap As Integer[16] // 버튼맵에 대치한다, 각 버튼맵 칸이 어디서 화살표가 날아오는지 저장
				For i = 1 To 16
					holdMap[i] = 0
				Next
				If holdByArrow
					For i = 1 To 46  // 먼저 번호 적힌 순서대로 우선권 부여
						ch$ = Mid(JMEMO_BUTTON_NUM_CHARS, i, 1)
						For j = 1 To 16
							If buttonsMap[j] = ch$ And watingEndPointMap[j] < 0
								// find at top 1∨ (farest)
								makeToLinked = 0
								k = j - 4
								While k >= 1
									num = FindString(JMEMO_BUTTON_NUM_CHARS, buttonsMap[k])  // index no.
									If num >= i Or buttonsMap[k] = Left(JMEMO_BUTTON_CHARS, 1)  // >를 >=로 고쳐서 현재 번호는 막힌 길로 지정, 지나간 번호만 뚫린 길
										Exit  // 아직 안나온 번호거나 빈칸이면 막혔으니까 Exit
									ElseIf num = 0
										num = FindString(JMEMO_HOLD_SIGNS, buttonsMap[k])  // hold no. 1:∨, 2:∧, 3:＞, 4:＜
										If num = 1
											holdMap[j] = k
											makeToLinked = k  // 십자로 이어진 길로 표시할 예정
										ElseIf num = 0
											num = FindString(JMEMO_HOLD_LASER, buttonsMap[k])  // laser no. 1:+, 2:| 3:-
											If num <> 1 And num <> 2/* And watingEndPointMap[k] < 0*/ Then Exit  // 레이저로 이어져있지도 않으면 막혔으니까 Exit
										EndIf
									EndIf
									dec k, 4
								EndWhile
								If makeToLinked > 0 Then buttonsMap[makeToLinked] = Left(JMEMO_HOLD_LASER, 1)  // 십자 표시
								
								// find at bottom 2∧ (farest)
								makeToLinked = 0
								k = j + 4
								While k <= 16
									num = FindString(JMEMO_BUTTON_NUM_CHARS, buttonsMap[k])  // index no.
									If num >= i Or buttonsMap[k] = Left(JMEMO_BUTTON_CHARS, 1)
										Exit
									ElseIf num = 0
										num = FindString(JMEMO_HOLD_SIGNS, buttonsMap[k])  // hold no. 1:∨, 2:∧, 3:＞, 4:＜
										If num = 2
											holdMap[j] = k
											makeToLinked = k
										ElseIf num = 0
											num = FindString(JMEMO_HOLD_LASER, buttonsMap[k])  // laser no. 1:+, 2:| 3:-
											If num <> 1 And num <> 2/* And watingEndPointMap[k] < 0*/ Then Exit
										EndIf
									EndIf
									inc k, 4
								EndWhile
								If makeToLinked > 0 Then buttonsMap[makeToLinked] = Left(JMEMO_HOLD_LASER, 1)
								
								// find at left 3＞ (farest)
								makeToLinked = 0
								k = j - 1
								While k > ((j - 1) / 4) * 4
									num = FindString(JMEMO_BUTTON_NUM_CHARS, buttonsMap[k])  // index no.
									If num >= i Or buttonsMap[k] = Left(JMEMO_BUTTON_CHARS, 1)
										Exit
									ElseIf num = 0
										num = FindString(JMEMO_HOLD_SIGNS, buttonsMap[k])  // hold no. 1:∨, 2:∧, 3:＞, 4:＜
										If num = 3
											holdMap[j] = k
											makeToLinked = k
										ElseIf num = 0
											num = FindString(JMEMO_HOLD_LASER, buttonsMap[k])  // laser no. 1:+, 2:| 3:-
											If num <> 1 And num <> 3/* And watingEndPointMap[k] < 0*/ Then Exit
										EndIf
									EndIf
									dec k
								EndWhile
								If makeToLinked > 0 Then buttonsMap[makeToLinked] = Left(JMEMO_HOLD_LASER, 1)
								
								// find at right 4＜ (farest)
								makeToLinked = 0
								k = j + 1
								While k <= ((j - 1) / 4 + 1) * 4
									num = FindString(JMEMO_BUTTON_NUM_CHARS, buttonsMap[k])  // index no.
									If num >= i Or buttonsMap[k] = Left(JMEMO_BUTTON_CHARS, 1)
										Exit
									ElseIf num = 0
										num = FindString(JMEMO_HOLD_SIGNS, buttonsMap[k])  // hold no. 1:∨, 2:∧, 3:＞, 4:＜
										If num = 4
											holdMap[j] = k
											makeToLinked = k
										ElseIf num = 0
											num = FindString(JMEMO_HOLD_LASER, buttonsMap[k])  // laser no. 1:+, 2:| 3:-
											If num <> 1 And num <> 3/* And watingEndPointMap[k] < 0*/ Then Exit
										EndIf
									EndIf
									inc k
								EndWhile
								If makeToLinked > 0 Then buttonsMap[makeToLinked] = Left(JMEMO_HOLD_LASER, 1)
							EndIf
						Next
					Next
				EndIf
				For i = 0 To notesQueue.Length
					// Figure out time and button number
					noteTime# = notesQueue[i].Time
					charToFind$ = Mid(JMEMO_BUTTON_CHARS, notesQueue[i].Pointer + 1, 1)
					
					For j = 1 To 16
						If buttonsMap[j] = charToFind$
							If watingEndPointMap[j] < 0
								tableItem As JMemoTableItem
								tableItem.Time = noteTime#
								tableItem.Button = j  // 1~16
								If holdByArrow
									tableItem.ArrowIndex = holdMap[j]
									If holdMap[j] > 0
										If watingEndPointMap[j] >= 0
											//에러
											//이미 홀드노트 시작된 상태인데 또 시작함
											tError.Code = 13
											tError.Message = GetLocalizedString("ERR_MEMO_HOLD_NOTE_OVERLAPPED") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
											CloseFile(fileId)
											ExitFunction emptyMap
										EndIf
										watingEndPointMap[j] = memo.Table.Length + 1
									EndIf
								Else
									tableItem.ArrowIndex = 0
								EndIf
								tableItem.HoldingEndTime = 0.0
								tableItem.Judged = 0
								
								memo.Table.Insert(tableItem)
							
								inc memo.NotesCount
							//ElseIf holdMap[j] > 0
								// 에러
								//종결버튼인데 홀드 방향이 지정됨 -> 은 그럴리 없으므로 에러처리 x
							Else
								// 종결버튼 처리
								memo.Table[watingEndPointMap[j]].HoldingEndTime = noteTime#
								watingEndPointMap[j] = -1
								inc memo.HoldsCount
							EndIf
						EndIf
					Next
				Next
					
				// Clear buttons map
				For i = 1 To buttonsMap.Length Step 1
					buttonsMap[i] = ""
				Next i
				// Clear queue
				While notesQueue.Length >= 0
					notesQueue.Remove()
				EndWhile
				// Clear hold map
				//While holdMap.Length >= 0
					//holdMap.Remove()
				//EndWhile
				// Reset current row
				curRow = 1
			EndIf
		// If unknown form
		ElseIf Len(Trim(line)) > 0 And Len(Trim(line)) <> FindCharsCount(Trim(line), "0123456789")
			tError.Code = 12
			tError.Message = GetLocalizedString("ERR_MEMO_UNINTELLIGIBLE_LINE") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
			CloseFile(fileId)
			ExitFunction emptyMap
		EndIf
		inc lineNumber
	EndWhile
	
	// Close file
	CloseFile(fileId)
	
	// Add more beat timings
	For i = 1 To 20
		memo.BeatTimings.Insert(memo.BeatTimings[memo.BeatTimings.Length] + 60.0 / curTempo * 1.0)
	Next
	
	
	// if no music
	If memo.MusicFile = ""
		tError.Code = 14
		tError.Message = GetLocalizedString("ERR_MEMO_MUSIC_FILE_NOT_SPECIFIED")
		ExitFunction emptyMap
	EndIf
	
	// if no content
	If curRow <> 1 Or memo.NotesCount = 0
		tError.Code = 15
		tError.Message = GetLocalizedString("ERR_MEMO_IS_NOT_COMPLETED") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
		ExitFunction emptyMap
	EndIf
	
	// if no dif
	If memo.Level = 0
		tError.Code = 19
		tError.Message = GetLocalizedString("ERR_MEMO_NOT_SPECIFIED_DIF") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
		ExitFunction emptyMap
	EndIf
	
	// if no level
	If memo.Level = 0
		tError.Code = 21
		tError.Message = GetLocalizedString("ERR_MEMO_NOT_SPECIFIED_LEVEL") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
		ExitFunction emptyMap
	EndIf
	
	// If watingEndPointMap is left
	For i = 1 To 16
		// 에러
		If watingEndPointMap[i] >= 0
			tError.Code = 16
		tError.Message = GetLocalizedString("ERR_MEMO_ENDLESS_HOLD_NOTE") + " (" + MUSIC_PATH + szFile + " : " + Str(lineNumber) + ")"
		ExitFunction emptyMap
		EndIf
	Next
	
	// calculate SHA-256
	sha256plain$ = ""
	For i = 0 To memo.Table.Length
		sha256plane$ = sha256plane$ + ("(" + /*Str(Round(memo.Table[i].Time * 1000)) + "," + */Str(memo.Table[i].Button) /* + "," + Str(memo.Table[i].HoldTriangle) + "," + Str(Round(memo.Table[i].HoldingTime * 1000)) */ + ")")
	Next
	memo.Sha256String = Sha256(sha256plane$)
	
	memo.Length = memo.Table[memo.Table.Length].Time
	For i = memo.Table.Length To MaxI(0, memo.Table.Length - 32) Step -1
		memo.Length = MaxF(memo.Length, memo.Table[i].HoldingEndTime)
	Next
	
	// apply notes delay settings
	/*
	For i = 0 To memo.Table.Length
		inc memo.Table[i].Time, GetSettingsNotesDelayOffset()
		If memo.Table[i].HoldingEndTime <> 0.0 Then inc memo.Table[i].HoldingEndTime, GetSettingsNotesDelayOffset()
	Next
	For i = 0 To memo.BeatTimings.Length
		inc memo.BeatTimings[i], GetSettingsNotesDelayOffset()
	Next
	*/
	
	//nto
	noteTimingOffset# = GetNoteTimingOffset(memo.Sha256String) * 0.001
	
	// apply notes delay settings
	For i = 0 To memo.Table.Length
		inc memo.Table[i].Time, (GetSettingsNotesDelayOffset() + noteTimingOffset# + fOffset)
		If memo.Table[i].HoldingEndTime <> 0.0 Then inc memo.Table[i].HoldingEndTime, (GetSettingsNotesDelayOffset() + noteTimingOffset# + fOffset)
	Next
	For i = 0 To memo.BeatTimings.Length
		inc memo.BeatTimings[i], (GetSettingsNotesDelayOffset() + noteTimingOffset# + fOffset)
	Next
	
	// make music bar
	totalTime# = memo.Length - memo.Table[0].Time
	divTime# = totalTime# / 120.0
	startIdx = 0
	For i = 1 To 120
		mbItem As JMemoMusicBarItem
		mbItem.TableIndexStart = startIdx//-1
		mbItem.TableIndexEnd = startIdx//-1
		mbItem.Color = 0
		mbItem.Level = 0
			
		endIdx = startIdx
		
		If startIdx > memo.Table.Length
			
		ElseIf i > 1 And memo.Table[startIdx].Time <= (i - 1) * divTime# + memo.Table[0].Time		
			
		Else
			If i = 120
				endIdx = memo.Table.Length
			Else
				If endIdx + 1 <= memo.Table.Length
					While memo.Table[endIdx + 1].Time <= i * divTime# + memo.Table[0].Time
						inc endIdx
						If endIdx + 1 > memo.Table.Length Then Exit
					EndWhile
				EndIf
			EndIf
			
			mbItem.TableIndexStart = startIdx
			mbItem.TableIndexEnd = endIdx
			mbItem.Color = 0
			holdsCount = 0
			If holdByArrow
				For j = startIdx To EndIdx
					If memo.Table[j].ArrowIndex > 0 Then inc holdsCount
				Next
			EndIf
			mbItem.Level = MaxI(1, MinI(8, Round((endIdx - startIdx + 1 + holdsCount) / divTime#)))  // notes per second (1~8)
			
			startIdx = endIdx + 1
		EndIf
		
		memo.MusicBar.Insert(mbItem)
	Next
EndFunction memo
