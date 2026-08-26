class_name TealLastStand
extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var reload_timer = $ReloadTimer
@onready var gun_audio_player = $GunAudioStreamPlayer2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var invincibility_flash_timer: Timer = $InvincibilityFlashTimer
@onready var creep_detection_raycast: RayCast2D = $CreepDetectionRayCast2D
@onready var behind_creep_detection_raycast: RayCast2D = $BehindCreepDetectionRayCast2D
@onready var creep_detection_area: Area2D = $CreepDetectionArea2D
@onready var creep_collision_area: Area2D = $CreepCollisionArea2D
var dead = false
const BULLET_SPAWN_POS = Vector2(-9, 0)
const BULLET_SPEED = 256
## Minimum reload time during the [enum State.FIRING] state. The reload time
## approaches this minimum time as viruses get closer to Teal.
const FIRING_RELOAD_MIN := 0.1
## Reload time during [enum State.FIRING] when viruses are beyond detection
## range.
const FIRING_RELOAD_MAX := 0.5
const FIRING_BOTH_WAYS_RELOAD := 0.1
const CLEARING_RELOAD := 0.1
var clearing_shots_remaining := 0
var bullet_resource = preload("res://Entity/Player/PlayerBullet/PlayerBullet.tscn")
var left_sprite: Texture2D = preload("res://Art/Character/Teal/TealLeft.png")
var right_sprite: Texture2D = preload("res://Art/Character/Teal/TealRight.png")
var gun_loaded := true
var state: State = State.DISABLED:
	set(value):
		var _previous_state = state
		_on_state_exit()
		state = value
		_on_state_enter()
	get:
		return state
var gravity := 750.0
var velocity_before_slide := Vector2(0, 0)
var facing := Vector2.LEFT:
	set(value):
		facing = value
		if not is_instance_valid(sprite):
			return # Likely just not readied yet, so fail silently
		if facing.x < 0:
			sprite.texture = left_sprite
		elif facing.x > 0:
			sprite.texture = right_sprite
var moving := false
var walk_speed := 135.0
var jump_speed := 400.0
var jump_queued := false
var bounce_speed := 340.0
var max_health: int = 3
var melee_knockback := Vector2(200, -150)
var horizontal_drag := 600.0
var health: int = max_health:
	set(value):
		var original_value := health
		health = value
		health_changed.emit(health)
		if health <= 0 or ((not StoryStatus.lives_enabled) and (health < original_value)):
			die()
var hit_invincibility := false
var original_global_position := global_position
var clearing_to: VirusPawn = null
var jumping_on: VirusPawn = null
var current_knockback_cause: VirusPawn = null
@onready var start_global_position := global_position

signal health_changed(to: int)
signal death

enum State {
	DISABLED,
	FIRING,
	FIRING_BOTH_WAYS,
	## Having just seen a shield virus ahead, rapid-firing to clear the viruses
	## ahead before jumping.
	CLEARING,
	JUMPING,
	## Returning after having jumped on a shield virus
	RETURNING,
	KNOCKBACK
	# TODO: Add an extra state for avoiding umbrella viruses while airborne.
}


# Override
func _process(_delta: float) -> void:
	match state:
		State.FIRING:
			if gun_loaded:
				creep_detection_raycast.force_raycast_update()
				var reload_time: float
				if creep_detection_raycast.is_colliding():
					var distance: float = abs(creep_detection_raycast.get_collision_point().x - global_position.x)
					var distance_ratio: float = distance / abs(creep_detection_raycast.target_position.x)
					reload_time = clampf(
							lerp(FIRING_RELOAD_MIN, FIRING_RELOAD_MAX, distance_ratio),
							FIRING_RELOAD_MIN,
							FIRING_RELOAD_MAX)
				else:
					reload_time = FIRING_RELOAD_MAX
				fire_gun()
				reload_timer.start(reload_time)
		State.CLEARING:
			if not is_instance_valid(clearing_to):
				state = State.FIRING
			else:
				if gun_loaded:
					fire_gun()
					reload_timer.start(CLEARING_RELOAD)
					clearing_shots_remaining -= 1
				if clearing_shots_remaining <= 0:
					jump_on(clearing_to)


# Override
func _physics_process(delta: float) -> void:
	if state == State.DISABLED:
		return
	
	if jump_queued and is_on_floor():
		velocity.y -= jump_speed
		jump_queued = false
	else:
		velocity.y += gravity * delta # Rate of change; apply delta.
	
	if state == State.KNOCKBACK:
		velocity.x -= horizontal_drag * sign(velocity.x) * delta
		if abs(velocity.x) <= 6:
			state = State.FIRING
	else:
		velocity.x = 0
	if moving:
		velocity.x += sign(facing.x) * walk_speed
	
	move_and_slide()
	var floor_was_creep := false # We'll fill this in if we detect bouncing on
	# a creep. For use with is_on_floor() checks to make sure it's actually
	# floor.
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is not VirusPawn:
			continue
		if collision.get_travel().y > 0 and global_position.y <= collider.global_position.y - 16:
			position.y -= 1 # Hopefully avoids colliding again next frame
			floor_was_creep = true
			if not collider.shield_active[collider.SHIELD_TOP]:
				collider.die()
				bounce()
				state = State.RETURNING
	
	var creep_collisions = creep_collision_area.get_overlapping_bodies()
	if creep_collisions.size() > 0:
		for creep in creep_collisions:
			if creep == current_knockback_cause:
				continue # No double knockback from the same creep in back-to-back frames
			if creep is VirusPawn:
				if global_position.y <= creep.global_position.y - 16:
					if creep.is_shield_active(creep.SHIELD_TOP):
						hit_up()
				else:
					if global_position.x >= creep.global_position.x:
						hit_right()
						creep.reverse_direction()
					else:
						hit_left()
						creep.reverse_direction()
	
	match state:
		State.FIRING:
			var creeps: Array[Node2D] = creep_detection_area.get_overlapping_bodies()
			for creep in creeps:
				if creep is not VirusPawn:
					continue
				if creep.is_shield_active(creep.SHIELD_FRONT):
					clearing_to = creep
					state = State.CLEARING
			if state == State.FIRING: # Only if we haven't changed state
				if behind_creep_detection_raycast.is_colliding():
					var creep = behind_creep_detection_raycast.get_collider()
					if creep is VirusPawn:
						# We start clearing house once they're extra close behind (halfway),
						# and only stop when the full raycast is clear.
						if behind_creep_detection_raycast.get_collision_point().x < global_position.x + (behind_creep_detection_raycast.target_position.x) / 2:
							if creep.is_shield_active(creep.SHIELD_FRONT):
								# Not much teal can do if a shield virus sneaks up behind,
								# so just jump on it to stay above the chaos and leave it to
								# the player to clean up.
								jump_on(creep)
							else:
								state = State.FIRING_BOTH_WAYS
		State.FIRING_BOTH_WAYS:
			if not behind_creep_detection_raycast.is_colliding():
				state = State.FIRING
			else:
				var creep = behind_creep_detection_raycast.get_collider()
				if creep is VirusPawn:
					if creep.is_shield_active(creep.SHIELD_FRONT):
						# We must have cleared our way to a shield virus. See
						# reasoning under State.FIRING physics process.
						jump_on(creep)
				if state == State.FIRING_BOTH_WAYS: # Only if state hasn't changed
					if gun_loaded:
						facing.x *= -1
						fire_gun()
						reload_timer.start(FIRING_BOTH_WAYS_RELOAD)
		State.JUMPING:
			if not is_instance_valid(jumping_on):
				state = State.RETURNING
			var distance: float = abs(global_position.x - jumping_on.global_position.x)
			if moving and (distance <= 6):
				moving = false
			elif not moving and (distance > 10):
				moving = true
				if global_position.x > jumping_on.global_position.x:
					facing = Vector2.LEFT
				else:
					facing = Vector2.RIGHT
		State.RETURNING:
			var distance: float = abs(global_position.x - original_global_position.x)
			if moving and (distance <= 6):
				moving = false
			elif not moving and (distance > 10):
				moving = true
				if global_position.x > original_global_position.x:
					facing = Vector2.LEFT
				else:
					facing = Vector2.RIGHT
			if is_on_floor() and (not floor_was_creep) and (distance <= 8):
				state = State.FIRING


func start():
	state = State.FIRING


func fire_gun(direction: Vector2 = facing):
	var sanitized_direction := Vector2(sign(direction.x) if direction.x != 0 else -1, 0)
	gun_audio_player.play()
	var bullet = bullet_resource.instantiate()
	get_parent().add_child(bullet)
	bullet.set_global_position(global_position + BULLET_SPAWN_POS)
	bullet.reset_physics_interpolation()
	bullet.set_linear_velocity(BULLET_SPEED * sanitized_direction)
	gun_loaded = false


func jump_on(creep: VirusPawn) -> void:
	jumping_on = creep
	state = State.JUMPING


func bounce() -> void:
	velocity.y = -1 * bounce_speed


func hit_up() -> void:
	if not hit_invincibility:
		health -= 1
	velocity.y = -1 * bounce_speed
	apply_invincibility()


func hit_left() -> void:
	if not hit_invincibility:
		health -= 1
	position.x -= 1
	var kb = melee_knockback
	kb.x *= sign(Vector2.LEFT.x)
	knockback(kb)
	apply_invincibility()


func hit_right() -> void:
	if not hit_invincibility:
		health -= 1
	position.x += 1
	var kb = melee_knockback
	kb.x *= sign(Vector2.RIGHT.x)
	knockback(kb)
	apply_invincibility()


func knockback(by: Vector2) -> void:
	velocity = by
	state = State.KNOCKBACK
	facing = Vector2.LEFT if by.x < 0 else Vector2.RIGHT


func apply_invincibility() -> void:
	hit_invincibility = true
	visible = false
	invincibility_flash_timer.start(0.1)
	invincibility_timer.start(0.5)


func _on_state_enter() -> void:
	match state:
		State.DISABLED:
			process_mode = Node.PROCESS_MODE_DISABLED
			sprite.visible = false
		State.FIRING:
			if (not reload_timer.is_stopped()) and reload_timer.time_left > FIRING_RELOAD_MIN:
				reload_timer.start(FIRING_RELOAD_MIN)
			moving = false
			facing = Vector2.LEFT
		State.FIRING_BOTH_WAYS:
			if (not reload_timer.is_stopped()) and reload_timer.time_left > FIRING_BOTH_WAYS_RELOAD:
				reload_timer.start(FIRING_BOTH_WAYS_RELOAD)
			moving = false
		State.CLEARING:
			if (not reload_timer.is_stopped()) and reload_timer.time_left > CLEARING_RELOAD:
				reload_timer.start(CLEARING_RELOAD)
			moving = false
			facing = Vector2.LEFT
			clearing_shots_remaining = 0
			if is_instance_valid(clearing_to):
				var collisions: Array[Node2D] = creep_detection_area.get_overlapping_bodies()
				for creep in collisions:
					if creep is VirusPawn:
						if creep.global_position.x > clearing_to.global_position.x:
							clearing_shots_remaining += 1
		State.JUMPING:
			moving = true
			if jumping_on:
				facing = Vector2.RIGHT * sign(jumping_on.global_position.x - global_position.x)
			jump_queued = true
		State.RETURNING:
			moving = true
			facing = Vector2.RIGHT
		State.KNOCKBACK:
			moving = false


func _on_state_exit() -> void:
	match state:
		State.DISABLED:
			process_mode = Node.PROCESS_MODE_INHERIT
			sprite.visible = true
			visible = true
			original_global_position = global_position
		State.JUMPING:
			moving = false
			jump_queued = false
		State.RETURNING:
			moving = false
		State.KNOCKBACK:
			current_knockback_cause = null


func die():
	if not dead:
		dead = true
		emit_signal("death")
		reload_timer.stop()

# Signal connection
func _on_reload_timer_timeout():
	gun_loaded = true


func _on_invincibility_flash_timer_timeout() -> void:
	visible = not visible


func _on_invincibility_timer_timeout() -> void:
	hit_invincibility = false
	visible = true
	invincibility_flash_timer.stop()
