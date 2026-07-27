# StateMachine2D

class_name StateMachine2D
extends Node2D

@export var autostart = true
@export var initial_state_path: NodePath
@export var state_history_max_size = 5
var current_state
var state_history = []

func _ready():
	if autostart:
		start()

func start():
	current_state = get_node(initial_state_path)
	connect_state(current_state)
	current_state.enter()

func change_state(state : State2D, remember = true):
	current_state.exit()
	if remember:
		state_history.append(current_state)
		while state_history.size() > state_history_max_size:
			state_history.pop_front()
	current_state = state
	connect_state(current_state)
	current_state.enter()

func revert_state():
	change_state(state_history.pop_back(), false)

func connect_state(state):
	state.func_change_state = change_state.bind()
	state.func_revert_state = revert_state.bind()
	state.func_set_state_history = set_state_history.bind()
	state.func_get_state_history = get_state_history.bind()

# Getters and setters
func set_state_history(value : Array):
	state_history = value

func get_state_history():
	return state_history

func get_current_state():
	return current_state
