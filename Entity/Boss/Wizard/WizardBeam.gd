extends Node2D

export var start_activated = false
export var start_charging = false
onready var beam_sprite = $FadeNode/Sprite
onready var sight_sprite = $SightSprite
onready var end_polygon = $FadeNode/EndPolygon
onready var end_particles = $EndParticles
onready var end_particles_one_shot = $EndParticlesOneShot
onready var raycast = $RayCast2D
onready var hurt_area = $HurtArea
onready var hurt_area_shape = $HurtArea/CollisionShape2D
onready var animation_player = $AnimationPlayer
onready var charge_animation_player = $ChargeAnimationPlayer
onready var end_particles_charge = $EndParticlesCharge
onready var pulse_audio_player = $PulseAudioStreamPlayer2D
onready var beam_audio_player = $BeamAudioStreamPlayer2D
onready var rng = RandomNumberGenerator.new()
var charging = false
var beam_active = false
export var knockback = Vector2(300, -250)
export var damage = 1 # Remember -1 is insta-kill
export var ignore_invincibility = false
export var knockback_ignores_invincibility = true # Not sure about this.

func _ready():
	rng.randomize()
	end_particles.set_emitting(false)
	end_particles_one_shot.set_emitting(false)
	if start_activated:
		activate(true)
	else:
		deactivate(true)
	#update() # moved to activate()
	if start_charging:
		charge(true)
	else:
		end_charge(true) # Makes charging stuff instantly invisible
	

func update():
	# This is in physics process
	raycast.force_raycast_update()
	var end_pos
	if raycast.is_colliding():
		end_pos = raycast.get_collision_point()
	else:
		# End pos is expected to be global so add position
		end_pos = raycast.get_cast_to() + raycast.get_position()
	var length = global_position.distance_to(end_pos)
	end_polygon.position.y = length
	beam_sprite.position.y = length / 2
	beam_sprite.region_rect.size.y = length
	hurt_area.position.y = length / 2
	hurt_area_shape.shape.extents.y = length / 2
	end_particles.position.y = length
	end_particles_one_shot.position.y = length
	# Charge stuff
	sight_sprite.position.y = length / 2
	sight_sprite.region_rect.size.y = length
	end_particles_charge.position.y = length
	# Audio player
	# Actually NVM decided to keep these at origin
	#beam_audio_player.position.y = length / 2
	#pulse_audio_player.position.y = length / 2

func activate(instant = false, force_animation = false, stops_charge = true):
	# TODO: force_animation currently does nothing
	beam_audio_player.play()
	pulse_audio_player.play()
	update()
	hurt_area.set_monitoring(true)
	if (not beam_active) or force_animation or instant:
		print("playing activate animation")
		animation_player.play("activate")
		animation_player.seek(0.0, true)
	beam_active = true
	if instant:
		animation_player.seek(animation_player.get_current_animation_length(), true)
	if stops_charge:
		end_charge()

func deactivate(instant = false, force_animation = false):
	# TODO: force_animation currently does nothing
	beam_audio_player.stop()
	update()
	hurt_area.set_monitoring(false)
	if beam_active or force_animation or instant:
		animation_player.play("deactivate")
		animation_player.seek(0.0, true)
	beam_active = false
	if instant:
		animation_player.seek(animation_player.get_current_animation_length(), true)

func fire():
	# This is a oneshot animation for cutscenes. No hit detection yet.
	update()
	animation_player.play("fire")
	pulse_audio_player.play()

func _on_HurtArea_body_entered(body):
	# We know it's the player due to collision mask
	# To decide which direction player knockback should go:
	# 1. take horizontal line hline aligned with player
	# 2. find point of intersection between hline and beam (this is point on beam horizontally from player)
	# 3. Compare x pos of player and intersection point and set knockback to opposite direction
	var beam_start_point = get_global_position()
	var beam_direction = end_polygon.get_global_position() - beam_start_point
	# TODO: come up with a more concrete way of getting end_point that doesn't require end_polygon to exist
	var hline_start_point = body.get_global_position()
	var hline_direction = Vector2.RIGHT
	var intersect = Geometry.line_intersects_line_2d(beam_start_point, beam_direction, hline_start_point, hline_direction)
	if not (intersect is Vector2):
		# If the function doesn't return a Vector2 beam must be horizontal
		# So instead just pick any old random direction.
		print("Beam hline intersection was not Vector2! Doing random direction instead.")
		if rng.randf() > 0.5:
			intersect = hline_start_point + Vector2.RIGHT
		else:
			intersect = hline_start_point + Vector2.LEFT
	var knock_x_dir = sign(hline_start_point.x - intersect.x)
	# Now for doing the actual attack
	var this_knockback = knockback
	this_knockback.x *= knock_x_dir
	body.hit(this_knockback, damage, ignore_invincibility, knockback_ignores_invincibility)

func charge(instant = false, force_animation = false):
	if (not charging) or force_animation or instant:
		charge_animation_player.play("charge")
	if instant:
		charge_animation_player.seek(charge_animation_player.get_current_animation_length(), true)
	charging = true

func end_charge(instant = false, force_animation = false):
	if charging or force_animation or instant:
		charge_animation_player.play("charge_end")
	if instant:
		charge_animation_player.seek(charge_animation_player.get_current_animation_length(), true)
	charging = false

# Getters and setters
func is_charging():
	return charging

func is_beam_active():
	return beam_active
