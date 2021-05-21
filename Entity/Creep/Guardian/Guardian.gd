# VirusPawn.gd
# EXPLANATION:
# This entire script is mostly copied from the virus pawn
# This is REALLY BAD PRACTICE in object oriented programming, but I want to
# actually finish the game so this hacky solution shall work for now.
# I think I'll definitely refactor for Advanced Invasion 2

extends KinematicBody2D

export(int, "Left", "Right") var start_direction
onready var ignore_player_timer = $IgnorePlayerTimer
onready var gun_audio_player = $GunAudioStreamPlayer2D
onready var death_audio_player = $DeathAudioStreamPlayer2D
onready var death_scream_audio_player = $DeathScreamAudioStreamPlayer2D2
var gravity = 850
var walk_speed = 80
var direction = Vector2(1, 0)
var velocity = Vector2()
var up_direction = Vector2(0, -1)
var snap_vector = Vector2(0, 2)
var melee_knockback = Vector2(200, -150)
var melee_damage = 1
var ignore_player_contact = false
const MIN_WEAK_HEIGHT = -16 # Player must be higher than this relative y-position to damage
		# Remember player origin is in middle and so is the virus'
onready var corpse_bottom_resource = preload("res://Entity/Creep/Guardian/Corpse/GuardianCorpseBottom.tscn")
onready var corpse_top_resource = preload("res://Entity/Creep/Guardian/Corpse/GuardianCorpseTop.tscn")
var rng = RandomNumberGenerator.new()
const ENABLE_GUN = true # If true guardian will fire bullets
var gun_ready = true
const GUN_TIME_SEC = 2.0
var dead = false
onready var bullet_resource = preload("res://Entity/Creep/Guardian/GuardianBullet.tscn")
const BULLET_SPAWN_POSITION = Vector2(18, 0)
const BULLET_VELOCITY = Vector2(160.0, 0.0)

signal death

enum {SHIELD_BACK, SHIELD_FRONT, SHIELD_TOP}
onready var shield_node = {
	SHIELD_BACK : get_node("ShieldBack"),
	SHIELD_FRONT : get_node("ShieldFront"),
	SHIELD_TOP : get_node("ShieldTop")
}
onready var shield_particles = {
	SHIELD_BACK : get_node("ShieldBack/CPUParticles2D"),
	SHIELD_FRONT : get_node("ShieldFront/CPUParticles2D"),
	SHIELD_TOP : get_node("ShieldTop/CPUParticles2D")
}
onready var shield_static_body = {
	SHIELD_BACK : get_node("ShieldBack/StaticBody2D"),
	SHIELD_FRONT : get_node("ShieldFront/StaticBody2D"),
	SHIELD_TOP : null
}
export var back_shield_active_on_ready = false
export var front_shield_active_on_ready = false
export var top_shield_active_on_ready = false
onready var shield_active = {
	SHIELD_BACK : back_shield_active_on_ready,
	SHIELD_FRONT : front_shield_active_on_ready,
	SHIELD_TOP : top_shield_active_on_ready
}

func _ready():
	rng.randomize()
	# Make sure particles match active shields in case particles haven't been
	# set to emitting in the editor
	for shield in [SHIELD_BACK, SHIELD_FRONT, SHIELD_TOP]:
		update_shield(shield)
	match start_direction:
		0:
			set_direction(Vector2.LEFT)
		1:
			set_direction(Vector2.RIGHT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		pass
	else:
		# Choose facing
		if direction.x > 0:
			$AnimatedSprite.set_animation("right")
		elif direction.x < 0:
			$AnimatedSprite.set_animation("left")

func _physics_process(delta):
	if dead:
		pass
	else:
		# Walking into another body
		#if $BackRayCast.is_colliding():
			# Back
			# Attack player
			#if $BackRayCast.get_collider().get_name() == "Player":
			#	var kb = Vector2(melee_knockback.x * sign(direction.x) * -1, melee_knockback.y)
			#	$BackRayCast.get_collider().hit(kb, melee_damage)
		if $FrontRayCast.is_colliding():
			# Front
			# Attack player
			#if $FrontRayCast.get_collider().get_name() == "Player":
			#	var kb = Vector2(melee_knockback.x * sign(direction.x), melee_knockback.y)
			#	$FrontRayCast.get_collider().hit(kb, melee_damage)
			# Walking into something so reverse direction
			# This must be done after so knockback is calcualted from prev. direction
			reverse_direction()
		
		# Gun
		if gun_ready:
			if $PlayerDetectionRaycast.is_colliding():
				$GunTimer.start(GUN_TIME_SEC)
				gun_ready = false
				call_deferred("fire_gun")
		
		# Movement
		velocity.y += gravity * delta
		velocity.x = 0
		velocity += direction * walk_speed
		velocity = move_and_slide_with_snap(velocity, snap_vector, up_direction)
		
		# Detect collisions following move and slide
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				player_contact(collider)

func player_contact(player):
	# TODO: Potentially have virus bounce if it falls on top of player
	# ignore_player_contact used to prevent double player contact occuring.
	if ignore_player_contact:
		return
	ignore_player_contact = true
	ignore_player_timer.start(0.1)
	# Check conditions
	var position_condition = player.get_global_position().y < global_position.y + MIN_WEAK_HEIGHT # TODO: I think this - is wrong and should be +. Experiment later.
	var velocity_condition = player.get_previous_velocity().y >= 0
	if position_condition and velocity_condition:
		# Jumping onto head. Check shield.
		if is_shield_active(SHIELD_TOP):
			# Jump attack fail
			player.attack_bounce(false)
		else:
			# Jump attack success
			player.attack_bounce(true)
			die()
	else:
		# Hit side.
		var x_dir_to_player = sign(player.get_global_position().x - global_position.x)
		var kb = melee_knockback
		kb.x *= x_dir_to_player
		player.hit(kb, melee_damage)
		if sign(get_direction().x) == sign(x_dir_to_player):
			reverse_direction()

func _on_IgnorePlayerTimer_timeout():
	ignore_player_contact = false

func die():
	death_audio_player.play()
	death_scream_audio_player.play()
	emit_signal("death")
	#$AnimatedSprite.set_animation("death")
	# I keep the old animation player from VirusPawn.gd as it's a useful timer
	# to not delete self before the shields fully disappear.
	dead = true
	$AnimationPlayer.play("death")
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Hitbox/CollisionShape2D.call_deferred("set_disabled", true)
	set_shield_active(SHIELD_BACK, false)
	set_shield_active(SHIELD_FRONT, false)
	set_shield_active(SHIELD_TOP, false)
	call_deferred("spawn_corpse")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"death":
			queue_free()

func spawn_corpse():
	var torque_range = 5.0
	var velocity_range = 50.0
	# Top corpse
	var corpse_top = corpse_top_resource.instance()
	get_parent().add_child(corpse_top)
	corpse_top.global_position = global_position
	corpse_top.set_angular_velocity(rng.randf_range(-torque_range, torque_range))
	corpse_top.linear_velocity.x = rng.randf_range(-velocity_range, velocity_range)
	# Bottom corpse
	var corpse_bottom = corpse_bottom_resource.instance()
	get_parent().add_child(corpse_bottom)
	corpse_bottom.global_position = global_position
	corpse_bottom.set_angular_velocity(rng.randf_range(-torque_range, torque_range))
	corpse_bottom.linear_velocity.x = rng.randf_range(-velocity_range, velocity_range)

func _on_Hitbox_attacked(damage, from_direction):
	# Hitbox may block it but we check just in case player got exactly the right
	# angle
	var success = false
	var relevant_shield
	if sign(from_direction.x) == sign(direction.x):
		relevant_shield = SHIELD_BACK
	else:
		relevant_shield = SHIELD_FRONT
	success =  not is_shield_active(relevant_shield)
	if success:
		die()

func reverse_direction():
	var dir = get_direction()
	dir.x *= -1
	set_direction(dir)

func update_shield(shield):
	shield_particles[shield].set_emitting(is_shield_active(shield))
	if shield_static_body[shield] != null:
		shield_static_body[shield].set_collision_layer_bit(6, is_shield_active(shield)) # bullet stopper
		shield_static_body[shield].set_collision_mask_bit(4, is_shield_active(shield)) # bullet

func _on_GunTimer_timeout():
	gun_ready = true

func fire_gun(bullet_x_dir = 0):
	# If bullet_x_dir = 0, bullet will fire in the direction the guardian is moving
	
	gun_audio_player.play()
	
	# Get direction
	if bullet_x_dir == 0:
		bullet_x_dir = sign(direction.x)
	else:
		bullet_x_dir = sign(bullet_x_dir)
	
	# Fire the actual bullet
	var bullet = bullet_resource.instance()
	get_parent().add_child(bullet)
	# Set bullet position
	var relative_position = BULLET_SPAWN_POSITION
	relative_position.x *= bullet_x_dir
	bullet.set_global_position(global_position + relative_position)
	# Set bullet velocity
	var vel = BULLET_VELOCITY
	vel.x *= bullet_x_dir
	bullet.apply_central_impulse(vel)

# Getters and setters
func set_direction(dir : Vector2):
	# argument should be Vector2.LEFT or Vector2.RIGHT
	assert(dir.x != 0) # Vector needs to actually have an x direction
	dir.y = 0
	dir.x = sign(dir.x)
	direction = dir
	# Update raycasts
	var front_vec = $FrontRayCast.get_cast_to()
	var back_vec = $BackRayCast.get_cast_to()
	front_vec.x = abs(front_vec.x) * direction.x
	back_vec.x = abs(back_vec.x) * direction.x * -1
	$FrontRayCast.set_cast_to(front_vec)
	$BackRayCast.set_cast_to(back_vec)
	var player_detect_vec = $PlayerDetectionRaycast.get_cast_to()
	player_detect_vec.x = abs(player_detect_vec.x) * direction.x
	$PlayerDetectionRaycast.set_cast_to(player_detect_vec)
	# Update shields (flipping visuals)
	var new_scale = Vector2()
	for node in shield_node.values():
		new_scale.x = abs(node.get_scale().x) * direction.x
		new_scale.y = node.get_scale().y
		node.set_scale(new_scale)
	# Also set start_direction just in-case this fires off before _ready()
	if dir.x > 0:
		start_direction = 1
	else:
		start_direction = 0

func get_direction():
	return direction

func set_shield_active(shield, value : bool):
	shield_active[shield] = value
	update_shield(shield)

func is_shield_active(shield):
	return shield_active[shield]
