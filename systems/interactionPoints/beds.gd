extends Area3D

@export var audio: AudioStreamPlayer

func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("player"): return
	audio.play()
	self.queue_free()
