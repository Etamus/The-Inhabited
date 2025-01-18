extends Node3D

@export var screamingAudio: AudioStreamPlayer3D

@export var falseWall: MeshInstance3D
@export var falseWallCollisor: StaticBody3D
@export var player: CharacterBody3D
@export var drawer: MeshInstance3D

@onready var formaDaPorta: MeshInstance3D = $"../../Abandoned_House/Casa/%Marco_P_010"

var forniture: Array[MeshInstance3D]
var fornitureTween: Tween
var falseWallTween: Tween
var targetPosition: Vector3
var playerCamera: Camera3D

signal noteAdded

func _ready() -> void:
	playerCamera = player.camera
	for item in get_tree().get_nodes_in_group("tvRoomForniture"):
		forniture.append(item)
		
	EventsResources.connect("allTvsOff", allTvsOff)

func allTvsOff() -> void:
	
	if !EventsResources.interactions["roomsIndex"] == 2: return
	fornitureTween = get_tree().create_tween()
	falseWallTween = get_tree().create_tween()
	print("worked")
	screamingAudio.play()
	
	#Adding the note to the scene and puting it inside the drawer
	var note: PackedScene = load("res://objects/notes/roomNote.tscn")
	var noteInstance: MeshInstance3D = note.instantiate()
	drawer.add_child(noteInstance)
	emit_signal("noteAdded")
	#for item in forniture:
		#targetPosition = item.global_position + Vector3(0, 1.4, 0)
		#
		#fornitureTween.parallel().tween_property(item, "global_position", targetPosition, 2)
		#
	
	formaDaPorta.visible = false
	falseWallCollisor.set_collision_layer_value(1, true)
	falseWallTween.parallel().tween_property(falseWall, "transparency", 0, 2.5)
	
	
func _on_room_tv_body_entered(body: Node3D) -> void:
	if !body.is_in_group("player"): return
	EventsResources.interactions["roomsIndex"] = 2
	
