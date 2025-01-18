extends Area3D




func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		await World.typingEffect("That must be the house", 0.1, 1.5)
		queue_free()
