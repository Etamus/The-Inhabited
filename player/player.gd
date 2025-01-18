extends CharacterBody3D


@export_category("Settings Player")

@export var defaultSpeed: float = 2
@export var  jumpForce: float = 3.5
@export var runningSpeed: float = 3.5
@export var player: CharacterBody3D


@export_category("Settings Camera")
@export var mouseSensitivity := 0.2
@export var cameraLimitDown := -80.0
@export var cameraLimitUp := 60.0
@export var camera: Camera3D

@export_category("Settings Stammina Bar")
@export var progressBarControl: ProgressBar
@export var stamminaTimer: Timer
@export var recoveryTimer: Timer

@export_category("Settings Footsteps")
@export var footstepAudio: AudioStreamPlayer3D
@export var footstepsTimer: Timer
@export var talkTimer: Timer

@export var animationPlayer: AnimationPlayer
@export var raycast: RayCast3D

var cameraTween: Tween
var crouchTween: Tween

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camVertical := 0
var speed: float = defaultSpeed
var mouseVisibility: bool
var screenMode: bool
var crouching: bool = false
var initialRotation: Vector3
var input_dir := Vector2(0, 0)
var direction := Vector3(0, 0, 0)

enum States {walking, running, crouch, jump}
var state: States = States.walking

func _ready() -> void:
	
	animationPlayer.play("transitionIn")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	initialRotation = camera.rotation_degrees

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSensitivity))
	
		camVertical -= event.relative.y * mouseSensitivity
		camVertical = clamp(camVertical, cameraLimitDown, cameraLimitUp)
		
		$head/vertical.rotation_degrees.x = camVertical
		
	if Input.is_action_just_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if !mouseVisibility else Input.MOUSE_MODE_CAPTURED)
		mouseVisibility = !mouseVisibility
	
	if Input.is_action_just_pressed("f11"):
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func changeState(newState: States) -> void:
	state = newState
	
func _physics_process(delta: float) -> void:
	
	#Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	match state:
		States.walking:
			walking()
		States.jump:
			jump(delta)
		States.crouch:
			crouch()
			
	move_and_slide()

	
func walking() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("shift"): speed = runningSpeed; footsteps(true)
	else: speed = defaultSpeed
	
	if direction:
		footsteps(false)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		camera.position = Vector3(0, 0, 0)
	
	if Input.is_action_just_pressed("jump") and is_on_floor(): changeState(States.jump)
	if Input.is_action_just_pressed("ctrl"):
		crouching = !crouching
		changeState(States.crouch)
		
func jump(delta: float) -> void:
	velocity.y = jumpForce
	if is_on_floor(): changeState(States.walking)

func crouch() -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
			
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		camera.position = Vector3(0, 0, 0)
	
	if Input.is_action_just_pressed("ctrl"):
		crouching = !crouching
		
	match crouching:
		true:
			crouchTween = get_tree().create_tween()
			crouchTween.tween_property(player, "scale", Vector3(0.6, 0.6, 0.6), 0.3)
			speed = 1.3
			
		false:
			crouchTween = get_tree().create_tween()
			crouchTween.tween_property(player, "scale", Vector3(1, 1, 1), 0.3)
			speed = 2
			changeState(States.walking)
	
	
func footsteps(running: bool) -> void:
	if !is_on_floor() or input_dir == Vector2(0, 0) or is_on_wall(): return
	
	if footstepsTimer.time_left <= 0 && running:
		footstepAudio.pitch_scale = randf_range(0.8, 1.2)
		footstepAudio.play()
		footstepsTimer.start(0.3)
		
		cameraTween = get_tree().create_tween()
		cameraTween.tween_property(camera, "position", Vector3(0, 0.1, 0), 0.1)
		cameraTween.tween_property(camera, "position", Vector3(0, 0, 0), 0.1)
	else:
		if footstepsTimer.time_left <= 0:
			footstepAudio.pitch_scale = randf_range(0.8, 1.2)
			footstepAudio.play()
			footstepsTimer.start(0.75)


func _on_timer_timeout() -> void:
	await World.typingEffect("...", 0.1, 1.5)
