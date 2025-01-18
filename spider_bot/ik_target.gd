extends Marker3D

@export var step_target: Node3D
@export var step_distance: float = 3.0

@export var adjacent_target: Node3D
@export var opposite_target: Node3D

var is_stepping: bool = false

func _process(delta: float) -> void:
	if !is_stepping and !adjacent_target.is_stepping and abs(global_position.distance_to(step_target.global_position)) > step_distance:
		step()
		opposite_target.step()

func step() -> void:
	var target_pos: Vector3 = step_target.global_position
	var half_way: Vector3 = (global_position + step_target.global_position) / 2
	is_stepping = true
	
	var t: Tween = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + owner.basis.y, 0.1)
	t.tween_property(self, "global_position", target_pos, 0.1)
	t.tween_callback(func() -> void: is_stepping = false)
