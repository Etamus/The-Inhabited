extends OptionButton

signal shadowQualityToggled

func _on_item_selected(index: int) -> void:
	emit_signal("shadowQualityToggled", index)
	#match index:
		#0: World.shadowQuality = 0
		#1: World.shadowQuality = 1
		#2: World.shadowQuality = 2
