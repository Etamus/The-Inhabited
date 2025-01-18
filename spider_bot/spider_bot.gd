extends Node3D

@export var move_speed: float = 3.0
@export var run_speed: float = 5.0  # Velocidade de corrida
@export var turn_speed: float = 3.0
@export var ground_offset: float = 0.5
@export var detection_distance: float = 10.0
@export var patrol_radius: float = 20.0  # Raio máximo da patrulha
@export var patrol_wait_time: float = 2.0  # Tempo de espera no ponto de patrulha

var player: Node3D
@onready var fl_leg: Node3D = $FrontLeftIKTarget
@onready var fr_leg: Node3D = $FrontRightIKTarget
@onready var bl_leg: Node3D = $BackLeftIKTarget
@onready var br_leg: Node3D = $BackRightIKTarget

var move_vector: Vector3 = Vector3.ZERO
var patrol_point: Vector3
var patrol_timer: float = 0.0
var is_patrolling: bool = true
var current_direction: Vector3 = Vector3.ZERO  # Guarda a direção atual do movimento

func _ready() -> void:
	player = get_node_or_null("/root/The_Inhabited/Jogador/player")
	if player == null:
		print("Player não encontrado! Tentando localizar na cena atual...")
		var root_node: Node = get_tree().current_scene
		player = _find_node_recursive(root_node, "player")
		if player == null:
			print("Erro: Jogador não encontrado na cena!")
		else:
			print("Player localizado: ", player)

	# Define o primeiro ponto de patrulha
	_set_new_patrol_point()

func _process(delta: float) -> void:
	if player == null:
		return

	var distance_to_player: float = global_position.distance_to(player.global_position)

	# Quando estiver perto do jogador, começa a perseguição
	if distance_to_player <= detection_distance:
		is_patrolling = false
		_pursue_player(delta, run_speed)
	else:
		# Continua patrulhando
		is_patrolling = true
		_patrol(delta)

	# Atualiza a rotação e o movimento do personagem
	var plane1: Plane = Plane(bl_leg.global_position, fl_leg.global_position, fr_leg.global_position)
	var plane2: Plane = Plane(fr_leg.global_position, br_leg.global_position, bl_leg.global_position)
	var avg_normal: Vector3 = ((plane1.normal + plane2.normal) / 2).normalized()

	var target_basis: Basis = _basis_from_normal(avg_normal)
	transform.basis = lerp(transform.basis, target_basis, move_speed * delta).orthonormalized()

	var avg: Vector3 = (fl_leg.position + fr_leg.position + bl_leg.position + br_leg.position) / 4
	var target_pos: Vector3 = avg + transform.basis.y * ground_offset
	var distance: float = transform.basis.y.dot(target_pos - position)
	position = lerp(position, position + transform.basis.y * distance, move_speed * delta)

func _patrol(delta: float) -> void:
	# Se o personagem chegou ao ponto de patrulha, espera antes de mudar para outro ponto
	if global_position.distance_to(patrol_point) < 1.0:
		patrol_timer += delta
		if patrol_timer >= patrol_wait_time:
			patrol_timer = 0.0
			_set_new_patrol_point()
		return

	# Olha para o ponto de patrulha
	var direction_to_patrol: Vector3 = (patrol_point - global_position).normalized()
	var angle_to_patrol: float = direction_to_patrol.angle_to(transform.basis.z)

	# Rotaciona o personagem para olhar para o ponto de patrulha
	if angle_to_patrol > 0.1:
		var turn_angle: float = min(turn_speed * delta, angle_to_patrol)
		rotate_object_local(Vector3.UP, turn_angle * sign(direction_to_patrol.cross(transform.basis.z).y))

		# Depois de girar, armazena a direção para a qual ele virou
		current_direction = direction_to_patrol

	# Move em direção ao ponto de patrulha (sem inverter a direção)
	move_vector = current_direction * move_speed * delta
	translate(move_vector)

func _set_new_patrol_point() -> void:
	# Define um ponto de patrulha aleatório dentro do raio
	var random_angle: float = randf_range(0.0, 2 * PI)
	var random_distance: float = randf_range(5.0, patrol_radius)
	patrol_point = global_position + Vector3(cos(random_angle), 0, sin(random_angle)) * random_distance

func _pursue_player(delta: float, run_speed: float) -> void:
	# Calcula a direção para o jogador
	var direction_to_player: Vector3 = (player.global_position - global_position).normalized()

	# Calcula o ângulo entre a direção atual e a direção do jogador
	var angle_to_player: float = direction_to_player.angle_to(transform.basis.z)

	# Rotaciona o personagem para a direção do jogador
	if angle_to_player > 0.1:
		var turn_angle: float = min(turn_speed * delta, angle_to_player)
		rotate_object_local(Vector3.UP, turn_angle * sign(direction_to_player.cross(transform.basis.z).y))

		# Depois de girar, armazena a direção para a qual ele virou
		current_direction = direction_to_player

	# Move o personagem em direção ao jogador com a velocidade de corrida
	move_vector = current_direction * run_speed * delta
	translate(move_vector)

func _basis_from_normal(normal: Vector3) -> Basis:
	var result: Basis = Basis()
	result.x = normal.cross(transform.basis.z)
	result.y = normal
	result.z = transform.basis.x.cross(normal)

	result = result.orthonormalized()
	result.x *= scale.x
	result.y *= scale.y
	result.z *= scale.z

	return result

func _find_node_recursive(current_node: Node, name: String) -> Node:
	if current_node.name == name:
		return current_node
	for child in current_node.get_children():
		if child is Node:
			var result: Node = _find_node_recursive(child, name)
			if result != null:
				return result
	return null
