extends SpotLight3D


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		#turn off/turn on
		visible = !visible
		
