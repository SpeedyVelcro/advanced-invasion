extends KinematicBody2D

signal death
signal health_changed(new_value)

export(int, "Left", "Right") var start_direction
var gravity_enabled = true
var gravity = 750
var creep_bounce_speed = 340
var previous_velocity = Vector2(0, 0) # Velocity at the start of each frame, before applying move_and_slide.
# previous_velocity is useful for determining which way player was moving when they collide with a virus
# (e.g. to determine whether they were falling onto its head or walking into it)
var velocity = Vector2(0, 0) # Carried over between frames
var up_direction = Vector2(0, -1)
var snap_vector = Vector2(0, 2)
onready var snap_enabled = true
var snap_auto_enable = true # Whether snap auto-enables after one frame
export var hit_invincibility = false
var max_health = 3
var health = max_health
var lives_enabled = true
var dead = false
onready var knockback_state = get_node("StateMachine2D/Knockback")
onready var idle_state = get_node("StateMachine2D/Idle")
var bullet_resource = preload("res://Entity/Player/PlayerBullet/PlayerBullet.tscn")
var facing = Vector2.LEFT
const BULLET_ORIGIN_RIGHT = Vector2(9, 0)
var bullet_speed = 256
var harm_block_bounce_up = Vector2(0, -300)
var harm_block_bounce_right = Vector2(200, 0)
var harm_block_bounce_down = Vector2(0, 100)
var hit_by_bullet_knockback = Vector2(200, -150)
export var input_locked = false setget set_input_locked, is_input_locked
export var gun_enabled = true setget set_gun_enabled, is_gun_enabled
onready var gun_audio_player = $GunAudioStreamPlayer2D
onready var burn_audio_player = $BurnAudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	lives_enabled = StoryStatus.get_lives_enabled()
	# Set up the state machine before it starts.
	var states = $StateMachine2D.get_children()
	for state in states:
		if state is PlayerState:
			state.set_kinematic_body(self)
			state.connect("player_state_entered", self, "_on_PlayerState_player_state_entered")
			state.connect("snap_enable", self, "_on_PlayerState_snap_enable")
			state.connect("snap_disable", self, "_on_PlayerState_snap_disable")
			state.set_velocity = funcref(self, "set_velocity")
			state.get_velocity = funcref(self, "get_velocity")
	$StateMachine2D.start()
	# Ensure hit invincibility starts off
	hit_invincibility = false
	$AnimatedSprite.set_visible(true)
	# Ensure input locks of states match initial value
	set_input_locked(input_locked)
	# Set facing
	match start_direction:
		0:
			$AnimatedSprite.play("left")
			facing = Vector2.LEFT
		1:
			$AnimatedSprite.play("right")
			facing = Vector2.RIGHT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Choose facing
	# TODO: this should check facing variable and facing variable should be set
			# by states
	if Input.is_action_pressed("move_right") and not input_locked:
		$AnimatedSprite.set_animation("right")
		facing = Vector2.RIGHT
	elif Input.is_action_pressed("move_left") and not input_locked:
		$AnimatedSprite.set_animation("left")
		facing = Vector2.LEFT
	
	# Fire bullet
	if Input.is_action_just_pressed("attack") and (not input_locked) and gun_enabled:
		gun_audio_player.play()
		var bul = bullet_resource.instance()
		get_parent().add_child(bul)
		# TODO: set bullet position
		bul.set_global_position(get_global_position())
		if facing.x > 0:
			bul.position += BULLET_ORIGIN_RIGHT
		else:
			bul.position += BULLET_ORIGIN_RIGHT * -1
		# TODO: set bullet velocity
		bul.apply_central_impulse(facing * bullet_speed)

func _physics_process(delta):
	# Gravity
	if gravity_enabled:
		if is_on_floor():
			# Cancel downward velocity from gravity
			velocity.y = min(velocity.y, 0)
		else:
			velocity.y += gravity * delta # This is a rate of change, so multiplied by delta
	
	# Preserve velocity before we get stopped by walls in move_and_slide
	# so colliders can know which way we were moving before
	previous_velocity = velocity
	
	# Movement
	if snap_enabled:
		velocity = move_and_slide_with_snap(velocity, snap_vector, up_direction)
		# Get rid of extra up velocity from going up slopes
		if is_on_floor():
			velocity.y = max(0, velocity.y) # Make sure y velocity isn't negative
			# CLARIFICATION: when you put an upwards velocity (such as when going
			# up a slope) into move_and_slide_with_snap, this effectively is unused
			# and is carried over into the returned velocity vector. So if we jump
			# afterwards (jumping in this implementation ADDS y velocity), the jump
			# would be higher if we didn't get rid of it.
	else:
		velocity = move_and_slide(velocity, up_direction)
		if snap_auto_enable:
			snap_enabled = true
	
	# Detect collisions following move and slide
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player_collider"):
			# All objects in player_collider group should have this method
			collider.player_contact(self)
	
	# Harm raycast
	# I am REALLY not happy with how this work. This is a hack job.
	# Will refactor and come up with something better in Advanced Invasion 2
	$HarmBlockCastDownLeft.force_raycast_update()
	$HarmBlockCastDownRight.force_raycast_update()
	$HarmBlockCastUpLeft.force_raycast_update()
	$HarmBlockCastUpRight.force_raycast_update()
	var harm_collider_down = $HarmBlockCastDownLeft.is_colliding() or $HarmBlockCastDownRight.is_colliding()
	var harm_collider_up = $HarmBlockCastUpLeft.is_colliding() or $HarmBlockCastUpRight.is_colliding()
	if harm_collider_down:
		velocity.y = harm_block_bounce_up.y
		burn_audio_player.play()
		hit(Vector2(0, 0), 1)
	elif harm_collider_up:
		velocity.y = harm_block_bounce_down.y
		burn_audio_player.play()
		hit(Vector2(0, 0), 1)

func hit(knockback, damage, ignore_invincibility = false, knockback_ignores_invincibility = true):
	# -1 is insta-kill
	if not dead:
		if (not hit_invincibility) or ignore_invincibility:
			$HitPlayer.play("hit") # Animation changes hit_invincibility property
			if lives_enabled and damage != -1:
				set_health(get_health() - damage)
			elif damage != 0:
				die()
		if (not hit_invincibility) or knockback_ignores_invincibility:
			if (knockback.length_squared() > 0):
				knockback_state.start_new_knockback(knockback)
				if not knockback_state.is_state_active():
					$StateMachine2D.change_state(knockback_state)

func teleport(new_position):
	position = new_position
	$CameraPlayer.force_update_scroll()
	$CameraPlayer.reset_smoothing()

func _on_HarmBlockAreaSide_body_entered(body):
	burn_audio_player.play()
	if body.get_global_position().x < global_position.x:
		hit(harm_block_bounce_right, 1)
	else:
		var kb = harm_block_bounce_right
		kb.x *= -1
		hit(kb, 1)

func attack_bounce(success = true, fail_damage = 1):
	# Executes the player's post-jump-attack bounce
	# First move up 1 pixel to avoid re-triggering bounce
	position.y -= 1
	if success:
		velocity.y = -1 * creep_bounce_speed
		if not idle_state.is_state_active():
			$StateMachine2D.change_state(idle_state)
	else:
		var kb = Vector2(0, -1)
		kb.y *= creep_bounce_speed
		hit(kb, 1)

func _on_PlayerState_player_state_entered(grav_enabled):
	gravity_enabled = grav_enabled

func _on_PlayerState_snap_disable(auto_enable):
	snap_enabled = false
	snap_auto_enable = auto_enable

func _on_PlayerState_snap_enable():
	snap_enabled = true

func die():
	print("Death")
	emit_signal("death")
	dead = true

func _on_Hitbox_attacked(damage, from_direction):
	# This happens when you're hit by a virus bullet
	var kb = hit_by_bullet_knockback
	kb.x *= sign(from_direction.x) # If it's zero we'll just bounce upwards, which I guess is fine
	hit(kb, damage)

# Getters and setters
func set_health(new_health):
	if health != new_health:
		emit_signal("health_changed", new_health)
	health = new_health
	print("health is now " + str(health))
	if (health <= 0):
		# Death code
		die()

func get_health():
	return health

# Getters and setters
func set_facing(value: Vector2):
	facing = value
	if facing.x > 0:
		$AnimatedSprite.set_animation("right")
	if facing.x < 0:
		$AnimatedSprite.set_animation("left")

func set_velocity(value):
	velocity = value

func get_velocity():
	return velocity

func get_previous_velocity():
	return previous_velocity

func set_input_locked(value : bool):
	input_locked = value
	var states = $StateMachine2D.get_children()
	for state in states:
		if state is PlayerState:
			state.set_input_locked(value)

func is_input_locked()->bool:
	return input_locked

func set_gun_enabled(value : bool):
	gun_enabled = value

func is_gun_enabled()->bool:
	return gun_enabled
