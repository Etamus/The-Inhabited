extends Area3D
class_name Outline

@export var mesh: MeshInstance3D
@export var counter: Material

var raycast: RayCast3D
var player: CharacterBody3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	raycast = player.raycast
	raycast.connect("raycastout", raycastout)
	
func outline() -> void:
	mesh.material_overlay = counter

func raycastout() -> void:
	mesh.material_overlay = null
	
	 
