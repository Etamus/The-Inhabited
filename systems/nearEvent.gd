extends Node

class_name ObjectInteract

@export_category("Player")
@export var player: CharacterBody3D

@export_category("Object")
@export var object: MeshInstance3D

@export_category("Params")
@export var texts: Array[String] = []
@export var interactDistance: float = 1.2
@export var disToStopText: float
@export var canShowText: bool = true
@export var lookingLimitX: float = 0.8

var playerDirection: Vector3
var directionToObject: Vector3
var dotProduct: float
var distanceToPlayer: float

var i: int = 0

signal lookingAt
signal notLookingAt

func _process(delta: float) -> void:
	if looking() and distanceToPlayer < interactDistance:
		emit_signal("lookingAt")
		if !canShowText: return
		showText()
		
	else: emit_signal("notLookingAt")
func showText() -> void:
	canShowText = false
	while i < texts.size():
		#If the player be too far away it will not show the text anymore once it's showing
		if distanceToPlayer > disToStopText: set_process(false); return;
		await World.typingEffect(texts[i], 0.1, 1.5)
		i += 1
	
func looking() -> bool:
	#Calcs distance to player
	distanceToPlayer = object.global_position.distance_to(player.global_position)
	
	#Calcs if the player and object are in front of each other
	playerDirection = -player.global_transform.basis.z.normalized()
	directionToObject = (object.global_position - player.global_position).normalized()
	dotProduct = playerDirection.dot(directionToObject)
	
	#Returns the result of the calcs with an error margin
	return dotProduct > lookingLimitX
