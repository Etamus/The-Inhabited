extends Node

var TvsOffEmited: bool = false

var tvsStates: Dictionary = {
	"tvsOn": 3
	
}

#Reference
# 0 = anyPlace; 1 = livingRoom; 2 = tvRoom; 3 = upstairsNearTv
var interactions: Dictionary = {
	"roomsIndex": 0
	
}

signal allTvsOff


func addState(operation: String, number: int) -> void:
	
	match operation:
		"more": 
			tvsStates["tvsOn"] += number
				
		"less":
			tvsStates["tvsOn"] -= number
			if tvsStates["tvsOn"] == 0 && !TvsOffEmited:
				print("0 tvs on")
				emit_signal("allTvsOff")
				TvsOffEmited = true
