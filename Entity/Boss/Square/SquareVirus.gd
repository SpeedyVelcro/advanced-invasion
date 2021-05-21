extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite
onready var shield_particles_left = $ShieldParticlesLeft
onready var shield_particles_right = $ShieldParticlesRight
onready var seek_min_timer = $SeekMinTimer
onready var seek_max_timer = $SeekMaxTimer
onready var vulnerable_start_timer = $VulnerableStartTimer
onready var vulnerable_end_timer = $VulnerableEndTimer
onready var height_tween = $HeightTween
onready var animation_player = $AnimationPlayer
onready var attack_area = $AttackArea
onready var hitbox = $Hitbox
onready var impact_audio_player = $ImpactAudioStreamPlayer2D
var shield_active = false setget set_shield_active, is_shield_active
enum {
	STATE_SLEEP,
	STATE_SEEK,
	STATE_DROP,
	STATE_BOUNCE,
	STATE_VULNERABLE,
	STATE_HANG_BACK,
	STATE_RETURN,
	STATE_DEATH
}
var state = STATE_SLEEP
var next_state = state
var velocity = Vector2(0, 0)
var seek_height = 0.0
export(NodePath) var player_path
onready var player = get_node(player_path)
var stage = 0
const STAGE_THRESHOLD = [66.0, 33.0]
const MINIMUM_SKIP_DAMAGE = 10.0
const SEEK_SPEED = 5.0
const SEEK_ACCELERATION = [500.0, 650.0, 950.0]
const DRAG = 150.0
const SEEK_DECELERATION = [600.0, 1000.0, 1700.0]
const SEEK_BUFFER = 32.0
const FALL_ACCELERATION = 700.0
const SEEK_MIN_TIME = 0.2
const SEEK_MAX_TIME = 2.5
const UP_DIRECTION = Vector2(0, -1)
const VULNERABLE_START_TIME = 0.25
const VULNERABLE_END_TIME = 4.0
const MAX_HEALTH = 100.0
const MAX_DROP = [2, 3, 4]
const HANG_BACK_HEIGHT = 360.0 # Relative height
const HANG_BACK_TWEEN_TIME = 1.0
const RETURN_TWEEN_TIME = 1.0
const SIDE_KNOCKBACK = Vector2(300, -250)
var drop_count = 0
var health = MAX_HEALTH
var damage_accumulated = 0.0
var seek_min_time_elapsed = false
var seek_max_time_elapsed = false
var vulnerable_end_time_elapsed = false
var current_fall_speed = 0.0

signal health_changed(health, max_health)
signal hang_back
signal death

func _ready():
	set_shield_active(shield_active) # update particles
	_on_state_enter()

func animate_drop():
	animated_sprite.play("drop")

func animate_front():
	animated_sprite.play("front")

func start():
	seek_height = position.y
	change_state(STATE_SEEK)

func return_to_fight():
	if state == STATE_HANG_BACK:
		change_state(STATE_RETURN)

func change_state(p_state):
	next_state = p_state
	_on_state_exit()
	state = p_state
	_on_state_enter()

func _on_state_enter(p_state = state):
	match(p_state):
		STATE_SEEK:
			velocity = Vector2(0, 0)
			seek_min_timer.start(SEEK_MIN_TIME)
			seek_max_timer.start(SEEK_MAX_TIME)
			seek_min_time_elapsed = false
			seek_max_time_elapsed = false
			if player.global_position.x < global_position.x:
				animated_sprite.play("left")
			else:
				animated_sprite.play("right")
		STATE_DROP:
			current_fall_speed = 0.0
			velocity = Vector2(0, 0)
			animated_sprite.play("drop")
			drop_count += 1
		STATE_BOUNCE:
			# This state can be either a bounce or a recovery.
			# Because of this, sprite animation is set on the exit of the previous state.
			velocity.y = -current_fall_speed
		STATE_VULNERABLE:
			# Start timer is when shields go down and face changes.
			vulnerable_start_timer.start(VULNERABLE_START_TIME)
			vulnerable_end_timer.start(VULNERABLE_END_TIME)
			drop_count = 0
			vulnerable_end_time_elapsed = false
			damage_accumulated = 0.0
		STATE_HANG_BACK:
			emit_signal("hang_back")
			var target_pos = global_position
			target_pos.y = seek_height - HANG_BACK_HEIGHT
			height_tween.interpolate_property(self, "global_position", null, target_pos,
					HANG_BACK_TWEEN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
			height_tween.start()
		STATE_RETURN:
			var target_pos = global_position
			target_pos.y = seek_height
			height_tween.interpolate_property(self, "global_position", null, target_pos,
					RETURN_TWEEN_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
			height_tween.start()
		STATE_DEATH:
			animation_player.play("death")
			attack_area.set_deferred("monitoring", false)
			attack_area.set_deferred("monitorable", false)
			emit_signal("death")
			GlobalMusic.stop(2.0)
			hitbox.set_active(false)
			set_shield_active(false)

func _physics_process(delta):
	match(state):
		STATE_SEEK:
			var last_velocity = velocity
			velocity -= DRAG * velocity.normalized() * delta
			var x_difference = player.global_position.x - global_position.x
			if abs(x_difference) >= SEEK_BUFFER:
				# Accelerate towards playerr
				velocity.x += SEEK_ACCELERATION[stage] * sign(x_difference) * delta
			else:
				# Close - decelerate
				if abs(velocity.x) <= abs(SEEK_DECELERATION[stage] * delta):
					velocity.x = 0
				else:
					velocity.x -= SEEK_DECELERATION[stage] * sign(velocity.x) * delta
			if velocity.x > 0:
				animated_sprite.play("right")
			elif velocity.x < 0:
				animated_sprite.play("left")
			velocity = move_and_slide(velocity)
			# Sign of velocity flipping is a sign we crossed stopping point
			if (velocity.x == 0) or (sign(velocity.x) != sign(last_velocity.x)):
				# Come to stop so check if it's time to fall
				if seek_min_time_elapsed and (abs(x_difference) < SEEK_BUFFER):
					change_state(STATE_DROP)
				elif seek_max_time_elapsed:
					change_state(STATE_DROP)
		STATE_DROP:
			# No drag because the downward movement needs to be identical
			# to the upwards movement
			velocity.y += FALL_ACCELERATION * delta # Moving down; down direction is acceleration
			current_fall_speed = velocity.y
			velocity = move_and_slide(velocity, UP_DIRECTION)
			if is_on_floor():
				impact_audio_player.play()
				if drop_count < MAX_DROP[stage]:
					change_state(STATE_BOUNCE)
				else:
					change_state(STATE_VULNERABLE)
		STATE_BOUNCE:
			# Decelerate by acceleration value so we end up in the same place.
			velocity.y += FALL_ACCELERATION * delta# Moving up; Down direction is deceleration
			if velocity.y >= 0:
				# Set our height just to avoid small errors accumulating
				position.y = seek_height
				change_state(STATE_SEEK)
			velocity = move_and_slide(velocity)
		STATE_VULNERABLE:
			var stage_condition = false
			if stage < STAGE_THRESHOLD.size():
				stage_condition = health <= STAGE_THRESHOLD[stage]
			var health_condition = damage_accumulated >= MINIMUM_SKIP_DAMAGE
			if vulnerable_end_time_elapsed or (stage_condition and health_condition):
				if stage_condition:
					change_state(STATE_HANG_BACK)
					stage += 1
				else:
					change_state(STATE_BOUNCE)
			

func _on_state_exit(p_state = state):
	match(p_state):
		STATE_SEEK:
			velocity = Vector2(0, 0)
			seek_min_timer.stop()
			seek_max_timer.stop()
		STATE_DROP:
			animated_sprite.play("land")
		STATE_VULNERABLE:
			vulnerable_end_timer.stop()
			vulnerable_start_timer.stop()
			# Both STATE_BOUNCE and STATE_HANG_BACK when shields active and front sprite
			animated_sprite.play("front")
			set_shield_active(true)
		STATE_HANG_BACK:
			height_tween.stop_all()
		STATE_RETURN:
			height_tween.stop_all()

func _on_SeekMinTimer_timeout():
	seek_min_time_elapsed = true

func _on_SeekMaxTimer_timeout():
	seek_max_time_elapsed = true

func _on_VulnerableStartTimer_timeout():
	set_shield_active(false)
	animated_sprite.play("sleep")

func _on_VulnerableEndTimer_timeout():
	vulnerable_end_time_elapsed = true

func _on_HeightTween_tween_completed(_object, _key):
	if state == STATE_RETURN:
		change_state(STATE_SEEK)

func _on_Hitbox_attacked(damage, _from_direction):
	if not shield_active:
		set_health(health - damage)
		damage_accumulated += damage

func _on_AttackArea_body_entered(body):
	# Body is player due to mask
	var kb = SIDE_KNOCKBACK
	if body.global_position.x < global_position.x:
		kb.x *= -1
	body.hit(kb, 1)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"death":
			queue_free()

# Getters and setters
func set_shield_active(value : bool):
	shield_active = value
	shield_particles_left.set_emitting(value)
	shield_particles_right.set_emitting(value)

func is_shield_active()->bool:
	return shield_active

func set_health(value : float):
	health = value
	emit_signal("health_changed", health, MAX_HEALTH)
	if (health <= 0) and (state != STATE_DEATH):
		change_state(STATE_DEATH)

func get_health()->float:
	return health
