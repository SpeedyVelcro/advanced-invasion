extends KinematicBody2D

export var activated = false setget set_activated, is_activated
export var player_activates = true
export var activate_immediately = true
export var pause_time_sec = 2.0
export var speed = 35.0
export var stopping_at_start = false
export var stopping_at_end = false
export var remember_stop_settings = false # Whether stopping_at_x resets to false on stop
onready var start_position = position
var end_position
var forward = true # True if next state is STATE_FORWARD, false if STATE_REVERSE

signal activated

enum {
	STATE_WAIT,
	STATE_IDLE,
	STATE_FORWARD,
	STATE_REVERSE
}
var state = STATE_WAIT

func _ready():
	for child in get_children():
		if child is Position2D:
			end_position = position + child.get_position()
			child.queue_free()
	if activated:
		change_state(STATE_IDLE)
	_on_state_enter()

func change_state(p_state):
	_on_state_exit()
	state = p_state
	_on_state_enter()

func _on_state_enter(p_state = state):
	match(p_state):
		STATE_WAIT:
			pass
		STATE_IDLE:
			$IdleTimer.start(pause_time_sec)

func _on_state_exit(p_state = state):
	match(p_state):
		STATE_WAIT:
			pass

func _physics_process(delta):
	match(state):
		STATE_FORWARD:
			var frame_speed = speed * delta
			if position.distance_to(end_position) <= frame_speed:
				position = end_position
				if stopping_at_end:
					change_state(STATE_WAIT)
					if not remember_stop_settings:
						stopping_at_end = false
				else:
					change_state(STATE_IDLE)
			else:
				position += (end_position - position).normalized() * frame_speed
		STATE_REVERSE:
			var frame_speed = speed * delta
			if position.distance_to(start_position) <= frame_speed:
				position = start_position
				if stopping_at_start:
					change_state(STATE_WAIT)
					if not remember_stop_settings:
						stopping_at_start = false
				else:
					change_state(STATE_IDLE)
			else:
				position += (start_position - position).normalized() * frame_speed

# Getters and setters
func set_activated(value : bool):
	activated = value
	if activated and state == STATE_WAIT:
		emit_signal("activated")
		change_state(STATE_IDLE)
		if activate_immediately:
			$IdleTimer.stop()
			_on_IdleTimer_timeout()
	elif (not activated) and state != STATE_WAIT:
		change_state(STATE_WAIT)

func is_activated()->bool:
	return activated

func _on_IdleTimer_timeout():
	if state == STATE_IDLE:
		if forward:
			forward = false
			change_state(STATE_FORWARD)
		else:
			forward = true
			change_state(STATE_REVERSE)

func _on_PlayerActivationArea_body_entered(_body):
	# Mask ensures this is the player
	if player_activates and (not activated):
		set_activated(true) # Use the setter as this handles everything
