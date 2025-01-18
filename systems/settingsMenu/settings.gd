extends Control

signal fogToggled
signal shadowToggled
signal shadowQualityToggled
signal volumFogToggled

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		
		if !get_tree().paused:
			get_tree().paused = true
			self.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			
		else:
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			self.hide()
	

func _on_fog_button_toggled(toggled_on: bool) -> void:
	emit_signal("fogToggled", toggled_on)


func _on_shadow_button_toggled(toggled_on: bool) -> void:
	emit_signal("shadowToggled", toggled_on)


func _on_shadow_configs_item_selected(index: int) -> void:
	emit_signal("shadowQualityToggled", index)


func _on_volum_fog_button_toggled(toggled_on: bool) -> void:
	emit_signal("volumFogToggled", toggled_on)
