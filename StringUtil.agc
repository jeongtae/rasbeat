// Delete spaces at left of given string
Function LTrim(str As String)
	count = 0
	i = 1
	While i <= Len(str)
		If Mid(str, i, 1) = " "
			inc count
			inc i
		Else
			i = Len(str) + 1
		EndIf
	EndWhile
	result$ = Right(str, Len(str) - count) 
EndFunction result$

// Delete spaces at right of given string
Function RTrim(str As String)
	count = 0
	i = Len(str)
	While i >= 1
		If Mid(str, i, 1) = " "
			inc count
			dec i
		Else
			i = 0
		EndIf
	EndWhile
	result$ = Left(str, Len(str) - count) 
EndFunction result$

// Delete spaces of given string
Function Trim(str As String)
	result$ = LTrim(RTrim(str))
EndFunction result$

// Delete file extension of given string
Function RemovePathExtension(str As String)
	index = FindStringReverse(str, ".")
	If index > 0
		str = Left(str, index - 1)
	EndIf
EndFunction str

// Get file extension of given string
Function GetPathExtension(str As String)
	index = FindStringReverse(str, ".")
	If index > 0
		str = Right(str, Len(str) - index)
	EndIf
EndFunction str

// Find characters index
Function FindChars(str As String, chars As String)
	For i = 1 To Len(str) Step 1
		For j = 1 To Len(chars) Step 1
			If Mid(str, i, 1) = Mid(chars, j, 1) Then ExitFunction i
		Next j
	Next i
EndFunction 0

// Find characters count
Function FindCharsCount(str As String, chars As String)
	result = 0
	For i = 1 To Len(str) Step 1
		For j = 1 To Len(chars) Step 1
			If Mid(str, i, 1) = Mid(chars, j, 1) Then inc result
		Next j
	Next i
EndFunction result

Function ReplaceChars(str As String, findchars As String, replace As String, qty As Integer)
	resultStr$ = ""
	replaced = 0
	For i = 1 To Len(str)
		For j = 1 To Len(findchars)
			cur$ = Mid(str, i, 1)
			If cur$ = Mid(findchars, j, 1) And (qty < 0 Or replaced < qty)
				resultStr$ = resultStr$ + replace
				inc replaced
			Else
				resultStr$ = resultStr$ + cur$
			EndIf
		Next
	Next
EndFunction resultStr$
