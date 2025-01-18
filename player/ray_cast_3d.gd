extends RayCast3D

var raycast: RayCast3D = self

signal raycastout

func _physics_process(delta: float) -> void:
	interaction()
	
func interaction() -> void:
	var target := raycast.get_collider()
	
	if raycast.is_colliding() and target.has_method("outline"):
		target.outline()
	
	if raycast.is_colliding() and target.has_method("interact") and Input.is_action_just_pressed("leftClick"):
		target.interact()
		
	if !raycast.is_colliding():
		emit_signal("raycastout")
