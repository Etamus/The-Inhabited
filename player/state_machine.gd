extends Node

@export var initialState: State
var currentState: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.connect("transitioned", onChildTransition)
			
	if initialState:
		initialState.enter()
		currentState = initialState
func _process(delta: float) -> void:
	if currentState:
		currentState.update(delta)

func _physics_process(delta: float) -> void:
	if currentState:
		currentState.physicsUpdate(delta)

func onChildTransition(state: State, newStateName: State) -> void:
	if state != currentState: return
	
	var newState: State = states.get(newStateName.to_lower())
	if !newState: return
	
	if currentState:
		currentState.exit()
		
	newState.enter()
	
	currentState = newState
