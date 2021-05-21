# State2D.gd

class_name State2D
extends Node2D

var func_change_state : FuncRef
var func_revert_state : FuncRef
var func_set_state_history : FuncRef
var func_get_state_history : FuncRef
var state_active = false 
export var invisible_when_inactive = true

signal state_entered
signal state_exited

func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	if invisible_when_inactive:
		set_visible(false)

func enter():
	state_active = true
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	if invisible_when_inactive:
		set_visible(true)
	_on_state_enter()
	emit_signal("state_entered")

func exit():
	_on_state_exit()
	emit_signal("state_exited")
	set_process(false)
	set_physics_process(false)
	set_process_input(true)
	if invisible_when_inactive:
		set_visible(false)
	state_active = false

func _on_state_enter():
	pass # To be overwritten

func _on_state_exit():
	pass # To be overwritten

# funcrefs
func change_state(state):
	func_change_state.call_func(state)

func revert_state():
	func_revert_state.call_func()

func set_state_history():
	func_set_state_history.call_func()

func get_state_history():
	func_get_state_history.call_func()

# Setter and getters
func is_state_active():
	return state_active
