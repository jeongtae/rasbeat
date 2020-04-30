#include "Constants.agc"

// Public properties
Global SceneTitleEx1 As Integer
Global SceneTitleEx2 As Float

// Scene
Global _SceneTitleLooping As Integer = 0
Global _SceneTitleLifeTime As Float

// State
#constant _SceneTitleStateNone (0)
#constant _SceneTitleStateSample1 (1)
#constant _SceneTitleStateSample2 (2)
Global _SceneTitleState As Integer

// Main looping
Function SceneTitleLoop()
	result = SceneResultContinue
	inc _SceneTitleLifeTime, GetFrameTime()
	
	If Not _SceneTitleLooping
		_SceneTitleLooping = 1
		_SceneTitleState = _SceneTitleStateSample1
		_SceneTitleLifeTime = 0.0
		
		// Initialize scene here
		
	EndIf
	
	Select _SceneTitleState
		Case _SceneTitleStateSample1:
			
			// Main codes here
			
			If 0 Then _SceneTitleState = _SceneTitleStateSample2
		EndCase
		Case _SceneTitleStateSample2:
			
			// Main codes here
			
			If 0 Then result = SceneResultEnd
		EndCase
	EndSelect
	
	If result = SceneResultEnd Then _SceneInGameLooping = 0
EndFunction result
