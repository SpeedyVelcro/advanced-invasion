extends Node2D

const BEAM_LENGTH_BUFFER = 6 # Reduce visible length of beam by this much

enum ConditionType {
	NONE,
	CREEP_ALL,
	CREEP_SELECT,
	BUTTON_ALL_RED,
	BUTTON_ALL_BLUE
}
export(ConditionType) var condition
export(Array, NodePath) var creep_paths
export var start_enabled = true
onready var enabled = start_enabled
var creep_count = 0
var button_count = 0
onready var start_sprite = $StartAnimatedSprite
onready var end_sprite = $EndAnimatedSprite
onready var beam_fade_node = $BeamFadeNode
onready var beam_sprite = $BeamFadeNode/BeamSprite
onready var raycast = $RayCast2D
onready var static_body = $StaticBody2D
onready var collision_shape = $StaticBody2D/CollisionShape2D
onready var start_particles = $StartAnimatedSprite/CPUParticles2D
onready var end_particles = $EndAnimatedSprite/CPUParticles2D2
onready var disengage_audio_player = $DisengageAudioStreamPlayer
onready var mechanical_audio_player = $MechanicalAudioStreamPlayer

func _ready():
	raycast.force_raycast_update()
	var end_pos = raycast.get_collision_point()
	var length = global_position.distance_to(end_pos)
	end_sprite.position.y = -length
	beam_sprite.position.y = -length / 2
	beam_sprite.region_rect.size.y = length - BEAM_LENGTH_BUFFER
	static_body.position.y = -length / 2
	collision_shape.shape.extents.y = length / 2
	collision_shape.set_deferred("disabled", false)
	# Enable/disable with instant and force to ensure visuals are correct
	if enabled:
		enable(true, true)
	else:
		disable(true, true)
	# Set up conditions
	match condition:
		ConditionType.CREEP_ALL:
			var creeps = get_tree().get_nodes_in_group("creep")
			for creep in creeps:
				creep.connect("death", self, "_on_creep_death")
				creep_count += 1
		ConditionType.CREEP_SELECT:
			for creep_path in creep_paths:
				get_node(creep_path).connect("death", self, "_on_creep_death")
				creep_count += 1
		ConditionType.BUTTON_ALL_BLUE:
			var buttons = get_tree().get_nodes_in_group("push_button_blue")
			for button in buttons:
				button.connect("pressed", self, "_on_button_pressed")
				button_count += 1
		ConditionType.BUTTON_ALL_RED:
			var buttons = get_tree().get_nodes_in_group("push_button_red")
			for button in buttons:
				button.connect("pressed", self, "_on_button_pressed")
				button_count += 1

func _on_creep_death():
	creep_count -= 1
	if enabled and creep_count <= 0:
		disable()

func _on_button_pressed():
	button_count -= 1
	if enabled and button_count <= 0:
		disable()

func enable(instant = false, force = false):
	if (not enabled) or force:
		enabled = true
		$AnimationPlayer.play("enable")
		collision_shape.set_deferred("disabled", false)
		if instant:
			$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)
		else:
			mechanical_audio_player.play()

func disable(instant = false, force = false):
	if enabled or force:
		enabled = false
		$AnimationPlayer.play("disable")
		collision_shape.set_deferred("disabled", true)
		if instant:
			$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)
		else:
			mechanical_audio_player.play()
			disengage_audio_player.play()
