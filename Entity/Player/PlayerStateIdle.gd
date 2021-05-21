# PlayerStateIdle.gd

extends PlayerState

var walk_speed = 135
var jump_speed = 400
var falling = false
var coyote_time_active = false
const COYOTE_TIME_SEC = 0.1

func _on_state_enter():
	._on_state_enter()
	halt_x_velocity()
	#if kinematic_body.is_on_floor():
	#	enable_snap()
	enable_snap() # Pretty sure it's actually fine to enable snap while in the air

func _physics_process(_delta):
	# Coyote time
	if not falling:
		if not kinematic_body.is_on_floor():
			falling = true
			if get_velocity.call_func().y >= 0:
				$CoyoteTimer.start(COYOTE_TIME_SEC)
				coyote_time_active = true
	elif kinematic_body.is_on_floor():
		falling = false
		coyote_time_active = false
	
	halt_x_velocity()
	var prev_velocity = get_velocity.call_func()
	var velocity = Vector2(0, 0)
	velocity += get_walk_unit_vector() * walk_speed
	velocity += get_jump_unit_vector() * jump_speed
	if velocity.y < -20:
		# We're jumping so disable snap
		disable_snap() # This disables it for a frame
		# Also make sure old y isn't upward, to avoid stacking up velocities from various sources
		prev_velocity.y = max(prev_velocity.y, 0)
	# Replace the x velocity with our new horizontal movement
	set_velocity.call_func(velocity + prev_velocity)

func get_walk_unit_vector():
	var vector = Vector2(0, 0)
	if not input_locked:
		if Input.is_action_pressed("move_left"):
			vector.x -= Input.get_action_strength("move_left")
		if Input.is_action_pressed("move_right"):
			vector.x += Input.get_action_strength("move_right")
	return vector

func get_jump_unit_vector():
	var jump_condition = kinematic_body.is_on_floor() or coyote_time_active
	if Input.is_action_pressed("jump") and jump_condition and not input_locked:
		coyote_time_active = false
		return Vector2(0, -1)
	else:
		return Vector2(0, 0)

func halt_x_velocity():
	var v = get_velocity.call_func()
	v.x = 0
	set_velocity.call_func(v)

func _on_CoyoteTimer_timeout():
	coyote_time_active = false
