extends Node


var notes: Dictionary = {
	
}

func addIten(itemName: String, value: Texture2D) -> void:
	notes[itemName] = value
	
func showItem() -> void:
	pass
