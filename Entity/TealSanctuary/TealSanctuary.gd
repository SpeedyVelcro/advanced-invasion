class_name TealSanctuary
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var reload_timer: Timer = $ReloadTimer
@onready var gun_audio_player: AudioStreamPlayer2D = $GunAudioStreamPlayer2D
## Timer used for state-specific tasks.
@onready var state_timer: Timer = $StateTimer
## Detects walls in a vertical line just in front of, and below,
## Teal. Can be used to determine whether there is a pit in front of Teal to jump.
@onready var pit_wall_ray_cast: RayCast2D = $PitWallRayCast2D
## As [member pit_wall_ray_cast] but for harm blocks.
@onready var pit_harm_ray_cast: RayCast2D = $PitHarmRayCast2D
## Detects wall blocks a short distance in front of, and level with, Teal. Can
## be used to detect obstacles to jump over.
@onready var wall_ray_cast: RayCast2D = $WallRayCast2D
## Detects creeps in front of Teal for firing bullets at.
@onready var creep_ray_cast: RayCast2D = $CreepRayCast2D
const BULLET_SPAWN_POS = Vector2(-9, 0)
const BULLET_SPEED = 256
## Distance player can lag behind before Teal starts waiting.
const PLAYER_WAIT_DISTANCE := 160.0
## How close player can get while waiting before Teal starts leading again.
const PLAYER_LEAD_DISTANCE := 64.0
const RELOAD_TIME := 0.25
var bullet_resource = preload("res://Entity/Player/PlayerBullet/PlayerBullet.tscn")
var left_sprite: Texture2D = preload("res://Art/Character/Teal/TealLeft.png")
var right_sprite: Texture2D = preload("res://Art/Character/Teal/TealRight.png")
var gun_loaded := true
var state: State = State.NONE:
	set(value):
		var _previous_state = state
		_on_state_exit()
		state = value
		_on_state_enter()
	get:
		return state
var gravity := 750.0
var facing := Vector2.RIGHT:
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
var last_fired_at: VirusPawn = null

enum State {
	NONE,
	LEADING,
	WAITING
}


# Override
func _physics_process(delta: float) -> void:
	
	if jump_queued and is_on_floor():
		velocity.y = -jump_speed
		jump_queued = false
	else:
		velocity.y += gravity * delta # Rate of change; apply delta.
	
	velocity.x = 0
	if moving:
		velocity.x += sign(facing.x) * walk_speed
	
	move_and_slide()
	
	match state:
		State.LEADING:
			if is_on_floor() and velocity.y >= 0:
				if creep_ray_cast.is_colliding():
					var creep := creep_ray_cast.get_collider()
					if creep is VirusPawn:
						if last_fired_at != creep and gun_loaded:
							last_fired_at = creep
							fire_gun()
							reload_timer.start(RELOAD_TIME)
				if state_timer.is_stopped() and _get_distance_to_player() > PLAYER_WAIT_DISTANCE: # State timer is used for a short period in which we ignore distance
					change_state(State.WAITING)
				elif wall_ray_cast.is_colliding():
					jump()
				elif pit_harm_ray_cast.is_colliding():
					# Need to make sure there isn't a wall in the way
					if (not pit_wall_ray_cast.is_colliding()) or (pit_harm_ray_cast.get_collision_point().y <= pit_wall_ray_cast.get_collision_point().y):
						jump()
				elif not pit_wall_ray_cast.is_colliding():
					jump()
		State.WAITING:
			if creep_ray_cast.is_colliding():
				# We don't care too much about multi-firing here since we're just trying to keep Teal safe while waiting, rather than looking flashy.
				var creep := creep_ray_cast.get_collider()
				if creep is VirusPawn:
					if last_fired_at != creep and gun_loaded:
						facing = Vector2.RIGHT
						last_fired_at = creep
						fire_gun()
						reload_timer.start(RELOAD_TIME)
			if _get_distance_to_player() <= PLAYER_LEAD_DISTANCE:
				change_state(State.LEADING)


func fire_gun(direction: Vector2 = facing):
	var sanitized_direction := Vector2(sign(direction.x) if direction.x != 0 else -1, 0)
	gun_audio_player.play()
	var bullet = bullet_resource.instantiate()
	get_parent().add_child(bullet)
	bullet.set_global_position(global_position + BULLET_SPAWN_POS)
	bullet.reset_physics_interpolation()
	bullet.set_linear_velocity(BULLET_SPEED * sanitized_direction)
	gun_loaded = false


func jump() -> void:
	jump_queued = true


func change_state(to: State) -> void:
	state = to


func _get_player() -> Player:
	var player = get_tree().get_first_node_in_group("player")
	if player is Player:
		return player
	else:
		push_error("TealSanctuary cannot find Player in tree.")
		assert(false, "TealSanctuary cannot find Player in tree. (Assertion)")
		return null


func _get_distance_to_player() -> float:
	var player := _get_player()
	if player:
		return abs(global_position.x - player.global_position.x)
	else:
		push_error("Player not found. Giving distance as a ludicrously high number.")
		# There is no float max so we just give the maximum int since it's high enough.
		# Of course we could use INF but I'm not sure of the consequences of using
		# that so this is safer.
		return INT32_MAX


func _on_state_enter() -> void:
	match state:
		State.NONE:
			moving = false
		State.LEADING:
			moving = true
			facing = Vector2.RIGHT
			# We set a timer to keep moving regardless of distance for a second, because we just
			# entered the state so we obviously want to move at least a bit
			state_timer.one_shot = true
			state_timer.start(1.0)
		State.WAITING:
			# If we've somehow switched here while a jump is queued, we don't want
			# to jump while waiting because that would look stupid.
			jump_queued = false
			# We will wait for a split second, then move slightly to the left to simulate the way a player would turn around
			moving = false
			state_timer.one_shot = true
			state_timer.start(0.2)


func _on_state_exit() -> void:
	state_timer.stop()
	state_timer.one_shot = false


# Signal connection
func _on_reload_timer_timeout():
	gun_loaded = true


# Signal connection
func _on_state_timer_timeout() -> void:
	match state:
		State.WAITING:
			if not moving:
				moving = true
				facing = Vector2.LEFT
				state_timer.one_shot = true
				state_timer.start(0.05)
			else:
				moving = false
