# StateMachine2D

class_name StateMachine2D
extends Node2D

export var autostart = true
export(NodePath) var initial_state_path
export var state_history_max_size = 5
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
	state.func_change_state = funcref(self, "change_state")
	state.func_revert_state = funcref(self, "revert_state")
	state.func_set_state_history = funcref(self, "set_state_history")
	state.func_get_state_history = funcref(self, "get_state_history")

# Getters and setters
func set_state_history(value : Array):
	state_history = value

func get_state_history():
	return state_history

func get_current_state():
	return current_state
