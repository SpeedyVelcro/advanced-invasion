extends KinematicBody2D

export(NodePath) var player_path
onready var player = get_node(player_path)
onready var animated_sprite = $AnimatedSprite
onready var shield_particles = $ShieldParticles
onready var shield_timer = $ShieldTimer
onready var left_wall_raycast = $LeftWallRayCast
onready var right_wall_raycast = $RightWallRayCast
onready var animation_player = $AnimationPlayer
onready var exclamation_sprite = $ExclamationSprite
onready var ignore_player_timer = $IgnorePlayerTimer
onready var hurt_timer = $HurtTimer

enum {
	STATE_SLEEP,
	STATE_WAKE,
	STATE_PATROL,
	STATE_HURT,
	STATE_DEATH
}
var state = STATE_SLEEP
const HURT_TIME = 0.5
const FOLLOW_MINIMUM_DISTANCE = 64.0
const WALK_SPEED = 75.0
const PATROL_SHIELD_TIME_SEC = 14.0
const FIRST_SHIELD_TIME_SEC = 4.5
const MIN_WEAK_HEIGHT = -28.0 # Player must be higher than this relative y-position to damage
		# the boss with a jump attack.
const MELEE_KNOCKBACK = Vector2(200, -150)
const MELEE_DAMAGE = 1
const STARTING_HEALTH = 4
var shield_active = false setget set_shield_active, is_shield_active
var walk_direction = -1 # Corresponds to x-direction
var ignore_player_contact = false
var first_hit_done = false
var health = STARTING_HEALTH setget set_health, get_health

signal awake
signal first_hit
signal death

func _ready():
	animated_sprite.play("right")
	shield_particles.set_emitting(shield_active)
	exclamation_sprite.set_visible(false)
	animated_sprite.set_position(Vector2(0, 0))
	animated_sprite.set_modulate(Color(1, 1, 1, 1))

func change_state(p_state):
	_on_state_exit()
	state = p_state
	_on_state_enter()

func _on_state_enter(p_state = state):
	match(p_state):
		STATE_SLEEP:
			animated_sprite.play("right")
		STATE_WAKE:
			animation_player.play("wake")
			# Animation finished signal ends the state
		STATE_PATROL:
			if walk_direction > 0:
				animated_sprite.play("right")
			else:
				animated_sprite.play("left")
			set_shield_active(true)
			if health == STARTING_HEALTH:
				shield_timer.start(FIRST_SHIELD_TIME_SEC)
			else:
				shield_timer.start(PATROL_SHIELD_TIME_SEC)
		STATE_HURT:
			set_shield_active(true)
			if walk_direction > 0:
				animated_sprite.play("hurt_right")
			else:
				animated_sprite.play("hurt_left")
			hurt_timer.start(HURT_TIME)
		STATE_DEATH:
			GlobalMusic.play("invasion", 1.0)
			if walk_direction > 0:
				animated_sprite.play("surprise_right")
			else:
				animated_sprite.play("surprise_left")
			animation_player.play("death")
			emit_signal("death")

func _physics_process(_delta):
	if state == STATE_PATROL or state == STATE_HURT:
		var walk_vector = Vector2(WALK_SPEED * walk_direction, 0)
		move_and_slide(walk_vector)
		left_wall_raycast.force_raycast_update()
		right_wall_raycast.force_raycast_update()
	match(state):
		STATE_PATROL:
			if left_wall_raycast.is_colliding():
				walk_direction = 1
				animated_sprite.play("right")
			elif right_wall_raycast.is_colliding():
				walk_direction = -1
				animated_sprite.play("left")
		STATE_HURT:
			if left_wall_raycast.is_colliding():
				walk_direction = 1
				animated_sprite.play("hurt_right")
			elif right_wall_raycast.is_colliding():
				walk_direction = -1
				animated_sprite.play("hurt_left")
	
	# Detect collisions following move and slide
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			player_contact(player)

func _on_state_exit(p_state = state):
	match(p_state):
		STATE_SLEEP:
			pass # TODO: wake player
		STATE_WAKE:
			emit_signal("awake")
		STATE_PATROL:
			shield_timer.stop() # So it doesn't interfere with other states

func wake():
	if state == STATE_SLEEP:
		change_state(STATE_WAKE)

func _on_ShieldTimer_timeout():
	set_shield_active(not shield_active) # Effectively toggles shield

func update_follow(respect_min_distance = true):
	var x_diff = player.get_global_position().x - global_position.x
	if abs(x_diff) > FOLLOW_MINIMUM_DISTANCE or (not respect_min_distance):
		if x_diff != 0:
			walk_direction = sign(x_diff)
	# Update sprite
	if walk_direction > 0:
		animated_sprite.play("right")
	else:
		animated_sprite.play("left")

func player_contact(player : Node):
	if ignore_player_contact:
		return
	ignore_player_contact = true
	ignore_player_timer.start(0.1)
	# Called by Player manually when it detects a collision
	var position_condition = player.get_global_position().y < global_position.y - MIN_WEAK_HEIGHT # TODO: I think this - is wrong and should be +. Experiment later.
	var velocity_condition = player.get_previous_velocity().y >= 0
	if position_condition:
		if shield_active and velocity_condition:
			# Jumped onto shield
			# Velocity condition necessary to check here: if player's moving up
			# they were just coming out of a successful attack and shouldn't be
			# harmed.
			player.attack_bounce(false)
			print("failed attack")
		elif state == STATE_PATROL:
			# Jumped onto head while vulnerable
			player.attack_bounce(true)
			## Swap walk direction if player was in front of us so as to not attack them again
			#if sign(player.get_global_position().x - global_position.x) == walk_direction:
			#	walk_direction *= -1
			print("successful attack")
			set_health(get_health() - 1)
			if health > 0:
				change_state(STATE_HURT)
			if not first_hit_done:
				first_hit_done = true
				emit_signal("first_hit")
	else:
		# Hit sides so we do a melee attack
		print("hit by sides")
		var kb = MELEE_KNOCKBACK
		if player.get_global_position().x < global_position.x:
			kb.x *= -1
		player.hit(kb, MELEE_DAMAGE)

func _on_WakeTimer_timeout():
	if state == STATE_WAKE:
		change_state(STATE_PATROL)

func _on_HurtTimer_timeout():
	if state == STATE_HURT:
		change_state(STATE_PATROL)

func _on_IgnorePlayerTimer_timeout():
	ignore_player_contact = false

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"wake":
			if state == STATE_WAKE:
				change_state(STATE_PATROL)
		"death":
			queue_free()

# Getters and setters
func set_shield_active(value : bool):
	shield_active = value
	shield_particles.set_emitting(value)

func is_shield_active()->bool:
	return shield_active

func set_health(value : float):
	health = value
	if health <= 0:
		change_state(STATE_DEATH)

func get_health()->float:
	return health
