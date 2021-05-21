extends KinematicBody2D

signal death

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var gravity_enabled = true
var gravity = 850
var walk_speed = 120
var jump_speed = 450
var creep_bounce = false
var creep_bounce_speed = 300
var velocity = Vector2()
var up_direction = Vector2(0, -1)
var snap_vector = Vector2(0, 2)
var just_jumped = false
var ragdoll = false
var ragdoll_resistance = 10
var invincibility = 0
var max_health = 3
var health = max_health

# Called when the node enters the scene tree for the first time.
func _ready():
	$CameraPlayer.make_current()
	# Set up the state machine before it starts.
	var states = $StateMachine2D.get_children()
	for state in states:
		if state is PlayerState:
			state.connect("player_state_entered", self, "_on_player_state_entered")
	$StateMachine2D.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Choose facing
	if Input.is_action_pressed("move_right"):
		$AnimatedSprite.set_animation("right")
	elif Input.is_action_pressed("move_left"):
		$AnimatedSprite.set_animation("left")

func _physics_process(delta):
	velocity.y += gravity * delta # This is a rate of change, so multiplied by delta
	# Reminder to my stupid self: none of the others need to be multiplied
	# by delta because move_and_slide incorporates delta timing
	if creep_bounce:
		velocity.y = -creep_bounce_speed
	else:
		velocity += get_jump_unit_vector() * jump_speed
	if ragdoll:
		velocity.x -= ragdoll_resistance * sign(velocity.x)
	else:
		velocity.x = 0
		velocity += get_walk_unit_vector() * walk_speed
	if (just_jumped or creep_bounce):
		velocity = move_and_slide(velocity, up_direction)
		just_jumped = false
		creep_bounce = false
	else:
		velocity = move_and_slide_with_snap(velocity, snap_vector, up_direction)
	if velocity.x > -2 and velocity.x < 2:
		ragdoll = false
	# Round sprite position to prevent jitter
	# get_node("../Sprite").position = Vector2(floor(position.x), floor(position.y))

func get_walk_unit_vector():
	var vector = Vector2(0, 0)
	if Input.is_action_pressed("move_left"):
		vector.x -= Input.get_action_strength("move_left")
	if Input.is_action_pressed("move_right"):
		vector.x += Input.get_action_strength("move_right")
	return vector

func get_jump_unit_vector():
	if Input.is_action_pressed("jump") and is_on_floor():
		just_jumped = true
		return Vector2(0, -1)
	else:
		return Vector2(0, 0)

func hit(knockback, damage):
	if (knockback.length_squared() > 0):
		velocity = knockback
		ragdoll = true
	set_health(get_health() - damage)
	# set invincibility, damage if there is no invincibility

func teleport(new_position):
	position = new_position
	$CameraPlayer.force_update_scroll()
	$CameraPlayer.reset_smoothing()

func _on_AttackArea2D_body_entered(body):
	# Jump attack
	if body.get_groups().has("creep"):
		var success = body.hit_jump()
		if success:
			creep_bounce = true
		else:
			pass

func _on_player_state_entered(grav_enabled):
	gravity_enabled = grav_enabled

func set_health(new_health):
	health = new_health
	# TODO: send signal HERE to update health GUI
	print("health is now " + str(health))
	if (health <= 0):
		# Death code
		print("death")
		emit_signal("death")

func get_health():
	return health
