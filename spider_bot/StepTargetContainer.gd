extends Node3D

@export var offset: float = 20.0

@onready var parent: Node3D = get_parent_node_3d()
@onready var previous_position: Vector3 = parent.global_position

func _process(delta: float) -> void:
	var velocity: Vector3 = parent.global_position - previous_position
	global_position = parent.global_position + velocity * offset
	
	previous_position = parent.global_position
