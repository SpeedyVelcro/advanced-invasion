# PlayerState.gd

class_name PlayerState
extends State2D

var set_velocity # Set to a funcref by Player.gd
var get_velocity # As above
var kinematic_body # Set to kinematic body by Player.gd
var input_locked
export var gravity_enabled = true

signal player_state_entered(gravity_enabled) # Automatically connected by Player.gd
signal snap_disable(auto_enable)
signal snap_enable

func _on_state_enter():
	emit_signal("player_state_entered", gravity_enabled)

func disable_snap(auto_enable = true):
	# auto_enable means snap will enable again at the end of the next _physics_process()
	emit_signal("snap_disable", auto_enable)

func enable_snap():
	emit_signal("snap_enable")

# Setters and getters
func set_kinematic_body(node):
	kinematic_body = node

func get_kinematic_body():
	return kinematic_body

func set_input_locked(value : bool):
	input_locked = value

func is_input_locked()->bool:
	return input_locked
