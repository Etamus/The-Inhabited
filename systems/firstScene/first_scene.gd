extends Control

@export var animationPlayer: AnimationPlayer
@export var audio: AudioStreamPlayer
@export var richLabel: RichTextLabel
@export var label: Label
@export var videoTurnOn: VideoStreamPlayer
@export var videoTurnOff: VideoStreamPlayer

var worldScene := load("res://world.tscn")
var visibleChars := 0
var canAdvance := false
var speedUp := true
var canSkip := false

func _ready() -> void:
	label.hide()
	richLabel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	videoTurnOn.play()
	
	
func _process(delta: float) -> void:
	if richLabel.visible_ratio < 1:
		richLabel.visible_ratio += 0 * delta
		
	if visibleChars != richLabel.visible_characters:
		visibleChars = richLabel.visible_characters
		audio.pitch_scale = randf_range(0.8, 1.2)
		audio.play()
	if Input.is_action_just_pressed("leftClick") and canSkip:
		if speedUp: 
			animationPlayer.speed_scale = 6
		else: 
			animationPlayer.speed_scale = 1
			
		speedUp = !speedUp
	changeScene()

func changeScene() -> void:
	if !canAdvance: return
	for key in range(0, 512):
		if Input.is_key_pressed(key):
			videoTurnOff.play()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	canAdvance = true
	animationPlayer.speed_scale = 1
	label.show()
	animationPlayer.play("labelAnim")

func _on_video_stream_player_finished() -> void:
	animationPlayer.play("typing")
	richLabel.show()
	canSkip = true

func _on_turn_off_finished() -> void:
	get_tree().change_scene_to_file(worldScene.resource_path)
