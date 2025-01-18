extends Outline

@export var light: OmniLight3D
@export var switchOn: AudioStreamPlayer3D
@export var switchOff: AudioStreamPlayer3D

func interact() -> void:
	light.visible = !light.visible
	
	if light.visible: switchOn.play()
	else: switchOff.play()
