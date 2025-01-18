extends StaticBody3D

var i := 0

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print(i)
		i += 1
		if i < 5:
			await World.typingEffect("I can't leave now.", 0.1, 1.5)
			await World.typingEffect("I need to find the house", 0.1, 1.5)
		elif i > 4 and i < 20:
			await World.typingEffect("Which part of 'I NEED TO FIND THE HOUSE' didn't you understand?", 0.1, 1.5)
		else:
			await World.typingEffect("I'm done, you leave me no choice.", 0.1, 1.5)
