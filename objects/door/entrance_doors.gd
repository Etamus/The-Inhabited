extends Area3D

@export var animationPlayer: AnimationPlayer
@export var mesh: MeshInstance3D
@export var audio: AudioStreamPlayer3D
@export var counter: Material

var doorOpened := false
var canInteract := true

func _ready() -> void:
	# Inicia o estado da porta fechada sem tocar na animação
	doorOpened = false

func interact() -> void:
	if canInteract and not animationPlayer.is_playing():
		canInteract = false
		
		# Verifica se a porta está aberta ou fechada e aciona a animação correspondente
		if doorOpened:
			animationPlayer.play("close")
		else:
			animationPlayer.play("open")
		
		# Toca o som se estiver configurado
		if audio and not audio.is_playing():
			audio.play()
		
		# Alterna o estado da porta
		doorOpened = !doorOpened
		
		# Aguarda a animação terminar antes de permitir nova interação
		await animationPlayer.animation_finished
		
		canInteract = true

func outline() -> void:
	# Aplica o material de destaque quando o jogador estiver perto
	mesh.material_overlay = counter

func raycastout() -> void:
	# Remove o destaque quando o jogador não estiver perto
	mesh.material_overlay = null
