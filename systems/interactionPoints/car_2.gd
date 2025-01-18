extends Area3D

var canType := true

func _on_area_entered(area: Area3D) -> void:
	if !canType: return
	if area.is_in_group("playerAim"): 
		await World.typingEffect("Is that snow?", 0.1, 1.5)
		await World.typingEffect("Where did all this snow come from?", 0.1, 1.5)
		await World.typingEffect("I didn't even know it could snow in this country.", 0.1, 1.5)
		await World.typingEffect("It's not even cold.", 0.1, 1.5)
		await World.typingEffect("Something feels... off.", 0.1, 1.5)
		canType = false
