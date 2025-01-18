extends Node3D

#Settings
var shadowQuality: int
var shadow: bool
var fog: bool
var fogConfig: int

var label: Label
var chars := []
var textList := []
var isTyping := false

func typingEffect(text: String, charTime: float, awaitTime: float) -> void:
	#Default values
	#charTime = 0.1 && awaitTime = 1.5
	
	if isTyping: return
	isTyping = true
	chars = text.split("")  
	
	for i: String in chars:
		textList.append(i)
		text = "".join(textList)
		label.text = text
		await get_tree().create_timer(charTime).timeout
		
	await get_tree().create_timer(awaitTime).timeout
	
	resetVars()
	
func resetVars() -> void:
	isTyping = false
	label.text = ""
	chars = []
	textList = []
	
