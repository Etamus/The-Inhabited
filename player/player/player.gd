extends CharacterBody3D


@export_category("Settings Player")

@export var defaultSpeed: float = 2
@export var  jumpForce: float = 3.5
@export var runningSpeed: float = 5
@export var player: CharacterBody3D
var speed: float = defaultSpeed

@export_category("Settings Camera")
@export var mouseSensitivity := 0.2
@export var cameraLimitDown := -80.0
@export var cameraLimitUp := 60.0
@export var camera: Camera3D
@export var shakeFixTimer: Timer

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
var collision: bool
var grounded: bool = false
var moving: bool
var running: bool
var canRegenStammina: bool
var canRun: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camVertical := 0
var initialRotation: Vector3

var mouseVisibility: bool
var screenMode: bool

#Obiovisily?
var input_dir := Vector2(0, 0)
var direction := Vector3(0, 0, 0)

var crouching := false
signal raycastout

func _ready() -> void:
	
	animationPlayer.play("transitionIn")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	initialRotation = camera.rotation_degrees
	
#Camera move and mouse Input 
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
		
	

func _physics_process(delta: float) -> void:
	
	interaction()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
	
	#Func to run
	run()
	checkStammina()
	crouch()
	
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		footsteps()
		moving = true
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		camera.position = Vector3(0, 0, 0)
		moving = false

	move_and_slide()



func crouch() -> void:
	if Input.is_action_just_pressed("ctrl"):
		crouching = !crouching
		crouchTween = get_tree().create_tween()
		
		match crouching:
			true:
				crouchTween.tween_property(player, "scale", Vector3(0.6, 0.6, 0.6), 0.3)
				defaultSpeed = 1
				
			false:
				crouchTween.tween_property(player, "scale", Vector3(1, 1, 1), 0.3)
				defaultSpeed = 2
		
		
func run() -> void:
	if crouching: return
	if Input.is_action_pressed("shift") and canRun and moving:
		progressBarControl.show()
		if !canRun: return
		speed = runningSpeed
		recoveryTimer.stop()
		if !running:
			stamminaTimer.start()
		running = true
		
	else:
		speed = defaultSpeed
		
	if Input.is_action_just_released("shift"):
		stamminaTimer.stop()
		canRegenStammina = true

		if canRegenStammina:
			recoveryTimer.start()
		
		running = false
func checkStammina() -> void:
	if progressBarControl.value == 0:
		canRun = false
		
	if progressBarControl.value == 100:
		progressBarControl.hide()
		canRegenStammina = true
		canRun = true
		
func footsteps() -> void:
	if running and canRun:
		if !is_on_floor(): return
		if footstepsTimer.time_left <= 0:
			footstepAudio.pitch_scale = randf_range(0.8, 1.2)
			footstepAudio.play()
			footstepsTimer.start(0.3)
			animateCameraTween()
			
	else:
		if !is_on_floor(): return
		if footstepsTimer.time_left <= 0:
			footstepAudio.pitch_scale = randf_range(0.8, 1.2)
			footstepAudio.play()
			footstepsTimer.start(0.75)
			
func animateCameraTween() -> void:
	cameraTween = get_tree().create_tween()
	
	cameraTween.tween_property(camera, "position", Vector3(0, 0.1, 0), 0.1)
	cameraTween.tween_property(camera, "position", Vector3(0, 0, 0), 0.1)
	

func _on_timer_timeout() -> void:
	await World.typingEffect("Here I am, following what an unknown voice says.", 0.1, 1.5)
	#await World.typingEffect("Let's see where it takes me.", 0.1, 1.5)
	#await World.typingEffect("They said It was a huge, old house... somewhere around here", 0.1, 1.5)
func interaction() -> void:
	var target := raycast.get_collider()
	
	if raycast.is_colliding() and target.has_method("outline"):
		target.outline()
	
	if raycast.is_colliding() and target.has_method("interact") and Input.is_action_just_pressed("leftClick"):
		target.interact()
		
	if !raycast.is_colliding():
		emit_signal("raycastout")
			
