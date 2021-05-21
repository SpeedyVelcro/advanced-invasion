extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer
onready var left_raycast = $LeftRayCast
onready var right_raycast = $RightRayCast
onready var state_timer = $StateTimer # State timer is only ever used by the current state and should be use to control state timing/progression
onready var middle_beam = $MiddleBeam
onready var portal = $Portal
onready var left_beam = $LeftBeam
onready var right_beam = $RightBeam
onready var portal_animation_player = $PortalAnimationPlayer
onready var creep_resource = preload("res://Entity/Creep/VirusPawn/Variants/VirusUmbrellaPawn.tscn")
onready var bullet_resource = preload("res://Entity/Boss/Wizard/WizardBullet.tscn")
onready var rng = RandomNumberGenerator.new()
onready var woosh_audio_player = $WooshAudioStreamPlayer2D

# Basic idea: States do not control patrolling. This happens during all states
# if the wizard is alive. Patrol left/right animations don't happen in certain states.
enum {
	STATE_SLEEP,
	STATE_IDLE, # Patrolling while doing nothing
	STATE_HURT,
	STATE_ATTACK_SPIN,
	STATE_ATTACK_LASER,
	STATE_ATTACK_DUAL, # Two laser beams, rotate closer together so player has to get under. <33% health
	STATE_ATTACK_SPAWNER, # Drop viruses
	STATE_DEATH,
	STATE_ESCAPE # Escape animation that plays after death
}
var state = STATE_SLEEP
var patrol_enabled = false
var patrol_graphics_enabled = false
var patrol_hurt_graphics_enabled = false
var next_attack_state = STATE_ATTACK_SPIN
var patrol_x_direction = -1
const PATROL_SPEED = 80
const HURT_TIME = 1.0 # seconds STATE_HURT lasts
const ATTACK_SPIN_NUMBER = 3 # number of times to attack spin
const ATTACK_SPIN_TIME = 1.0 # seconds to complete one attack spin
const IDLE_TIME = 1.0 # Time between attacks
const MAX_HEALTH = 70.0
const ATTACK_LASER_CHARGE_TIME = 3.0
const ATTACK_LASER_TIME = 6.0
const ATTACK_SPAWN_TIME = 1.5
const ATTACK_SPAWN_NUMBER = 3 # Number of viruses to spawn
var health = MAX_HEALTH setget set_health, get_health
var attack_spins_left = 0 # set on STATE_ATTACK_SPIN enter
var attack_spawns_left = 0 # set on STATE_ATTACK_SPAWNER enter
var attack_spin_fire_direction = 0
const ATTACK_SPIN_FIRE_NUMBER = 8
const ATTACK_SPIN_FIRE_ROTATION = (PI / ATTACK_SPIN_FIRE_NUMBER) * 0.5
const ATTACK_SPIN_FIRE_DISTANCE = 52.0
const ATTACK_SPIN_BULLET_SPEED = 140.0
const ATTACK_PATTERN = [
	[STATE_ATTACK_SPIN, STATE_ATTACK_LASER],
	[STATE_ATTACK_SPAWNER, STATE_ATTACK_LASER, STATE_ATTACK_SPIN],
	[STATE_ATTACK_DUAL, STATE_ATTACK_SPAWNER, STATE_ATTACK_SPIN]
]
const PHASE_THRESHOLD = [ # Represents health threshold to move from phase i to phase i+1
	50.0, # Phase 0 to phase 1
	30.0 # Phase 1 to phase 2
]
var phase = 0
var attack_pattern_index = 0

signal health_changed(health, max_health)
signal death
signal death_animation_ended

func _ready():
	rng.randomize()
	animated_sprite.set_visible(false)
	animated_sprite.play("default")
	portal.set_visible(false)

func fly_in():
	animation_player.play("fly_in")

func start():
	animation_player.play("start") # Changes to STATE_IDLE on finish

func change_state(p_state):
	_on_state_exit()
	state = p_state
	_on_state_enter()

func _on_state_enter(p_state = state):
	match(p_state):
		STATE_SLEEP:
			pass
		STATE_IDLE:
			patrol_enabled = true
			patrol_graphics_enabled = true
			if patrol_x_direction > 0:
				animated_sprite.play("right")
			else:
				animated_sprite.play("left")
			state_timer.start(IDLE_TIME)
		STATE_HURT:
			patrol_enabled = true
			patrol_hurt_graphics_enabled = true
			if patrol_x_direction > 0:
				animated_sprite.play("hurt_right")
			else:
				animated_sprite.play("hurt_left")
			state_timer.start(HURT_TIME)
		STATE_ATTACK_SPIN:
			patrol_enabled = true
			# Other state exits will have disable patrol graphics
			attack_spins_left = ATTACK_SPIN_NUMBER
			attack_spin_fire_direction = 0
			attack_spin()
		STATE_ATTACK_LASER:
			patrol_enabled = true
			patrol_graphics_enabled = true
			middle_beam.charge()
			state_timer.start(ATTACK_LASER_CHARGE_TIME)
		STATE_ATTACK_SPAWNER:
			patrol_enabled = true
			patrol_graphics_enabled = true
			portal_animation_player.play("show")
			attack_spawns_left = ATTACK_SPAWN_NUMBER
		STATE_ATTACK_DUAL:
			patrol_enabled = true
			patrol_graphics_enabled = true
			animation_player.play("double_beam")
			left_beam.activate()
			right_beam.activate()
		STATE_DEATH:
			animation_player.play("death")
			var players = get_tree().get_nodes_in_group("player")
			if not players.empty():
				var player_pos = players[0].get_global_position()
				# Now patrol x direction is just used for facing of sprite
				patrol_x_direction = sign(player_pos.x - global_position.x)
			if patrol_x_direction > 0:
				animated_sprite.play("hurt_right")
			else:
				animated_sprite.play("hurt_left")
			emit_signal("death")
		STATE_ESCAPE:
			animation_player.play("escape")
			animated_sprite.play("default")

func _physics_process(_delta):
	if patrol_enabled:
		move_and_slide(Vector2.RIGHT * patrol_x_direction * PATROL_SPEED)
		left_raycast.force_raycast_update()
		right_raycast.force_raycast_update()
		if left_raycast.is_colliding():
			patrol_x_direction = 1
			if patrol_graphics_enabled:
				animated_sprite.play("right")
			elif patrol_hurt_graphics_enabled:
				animated_sprite.play("hurt_right")
		elif right_raycast.is_colliding():
			patrol_x_direction = -1
			if patrol_graphics_enabled:
				animated_sprite.play("left")
			elif patrol_hurt_graphics_enabled:
				animated_sprite.play("hurt_left")
	match state:
		STATE_ATTACK_LASER:
			middle_beam.update()
		STATE_ATTACK_DUAL:
			left_beam.update()
			right_beam.update()

func _on_state_exit(p_state = state):
	match(p_state):
		STATE_SLEEP:
			pass
		STATE_IDLE:
			patrol_enabled = false
			patrol_graphics_enabled = false
			state_timer.stop()
		STATE_HURT:
			patrol_enabled = false
			patrol_hurt_graphics_enabled = false
			state_timer.stop()
		STATE_ATTACK_SPIN:
			patrol_enabled = false
			state_timer.stop()
			animated_sprite.set_rotation_degrees(0.0)
		STATE_ATTACK_LASER:
			patrol_enabled = false
			patrol_graphics_enabled = false
			middle_beam.end_charge()
			middle_beam.deactivate()
		STATE_ATTACK_SPAWNER:
			patrol_enabled = false
			patrol_graphics_enabled = false
			# TODO: if partway through show animation start appropriately partway through hide
			portal_animation_player.play("hide")
			state_timer.stop()
		STATE_ATTACK_DUAL:
			patrol_enabled = false
			patrol_graphics_enabled = false
			animation_player.stop()
			left_beam.deactivate()
			right_beam.deactivate()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"start":
			change_state(STATE_IDLE)
		"double_beam":
			if state == STATE_ATTACK_DUAL:
				change_state(STATE_IDLE)
		"death":
			if state == STATE_DEATH:
				if patrol_x_direction > 0:
					animated_sprite.play("right")
				else:
					animated_sprite.play("left")
				emit_signal("death_animation_ended")
		"escape":
			if state == STATE_ESCAPE:
				queue_free()

func hit():
	change_state(STATE_HURT)
	set_health(get_health() - 10.0)

func _on_StateTimer_timeout():
	match(state):
		STATE_HURT:
			change_state(STATE_IDLE)
		STATE_IDLE:
			var next_state = ATTACK_PATTERN[phase][attack_pattern_index]
			attack_pattern_index = posmod(attack_pattern_index + 1, ATTACK_PATTERN[phase].size())
			change_state(next_state)
		STATE_ATTACK_SPIN:
			if attack_spins_left <= 0:
				change_state(STATE_IDLE)
			else:
				attack_spin()
		STATE_ATTACK_LASER:
			if middle_beam.is_charging():
				middle_beam.activate()
				state_timer.start(ATTACK_LASER_TIME)
			else:
				change_state(STATE_IDLE)
		STATE_ATTACK_SPAWNER:
			if attack_spawns_left >= 1:
				var new_creep = creep_resource.instance()
				get_parent().add_child(new_creep)
				new_creep.set_global_position(portal.get_global_position())
				if rng.randf() > 0.5:
					new_creep.set_direction(Vector2.RIGHT)
				else:
					new_creep.set_direction(Vector2.LEFT)
				attack_spawns_left -= 1
				state_timer.start(ATTACK_SPAWN_TIME)
			else:
				change_state(STATE_IDLE)

func attack_spin():
	woosh_audio_player.play()
	animation_player.play("attack_spin")
	attack_spins_left -= 1
	state_timer.start(ATTACK_SPIN_TIME)
	# Fire bullets in a circle
	var bullet_spacing = (PI * 2) / ATTACK_SPIN_FIRE_NUMBER
	for i in range(ATTACK_SPIN_FIRE_NUMBER):
		# Calculate values
		var dir = attack_spin_fire_direction + (i * bullet_spacing)
		var dir_vector = Vector2(cos(dir), sin(dir))
		var start_pos = global_position + (dir_vector * ATTACK_SPIN_FIRE_DISTANCE)
		var spd = ATTACK_SPIN_BULLET_SPEED * dir_vector
		# We add the patrol movement so momentum looks conserved
		spd.x += PATROL_SPEED * patrol_x_direction
		# Create the bullet
		var new_bullet = bullet_resource.instance()
		get_parent().add_child(new_bullet)
		new_bullet.set_global_position(start_pos)
		new_bullet.apply_central_impulse(spd)
	# Update bullet direction for next spin
	attack_spin_fire_direction += ATTACK_SPIN_FIRE_ROTATION

func escape():
	change_state(STATE_ESCAPE)

func _on_PortalAnimationPlayer_animation_finished(anim_name):
	if anim_name == "show" and state == STATE_ATTACK_SPAWNER:
		state_timer.start(ATTACK_SPAWN_TIME)

func set_health(value : float):
	health = value
	emit_signal("health_changed", health, MAX_HEALTH)
	if phase < PHASE_THRESHOLD.size(): # see comment for PHASE_THRESHOLD
		if health <= PHASE_THRESHOLD[phase]:
			phase += 1
			attack_pattern_index = 0
	if (health <= 0) and (state != STATE_DEATH) and (state != STATE_ESCAPE):
		change_state(STATE_DEATH)

func get_health()->float:
	return health
