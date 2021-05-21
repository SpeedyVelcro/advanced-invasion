extends Level

export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []
onready var activate_area = $ActivateArea
onready var wizard = $WizardFight
onready var player = $Player
onready var camera_player = $Player/CameraPlayer
#onready var camera_original_margin_top = camera_player.drag_margin_top
#onready var camera_original_margin_bottom = camera_player.drag_margin_bottom
onready var animation_player = $AnimationPlayer
onready var barrier_left = $BarrierLeft
onready var barrier_right = $BarrierRight
onready var button_left = $RedButtonLeft
onready var button_right = $RedButtonRight
onready var beam_polygon = $BeamPolygon
onready var cannon_animation_player = $CannonAnimationPlayer
onready var left_pulse_audio_player = $LeftPulseAudioStreamPlayer2D
onready var right_pulse_audio_player = $RightPulseAudioStreamPlayer2D
var dialogue_stage = 0
const TALK_CAMERA_Y = -155

func _ready():
	DialogueManager.connect("finished", self, "_on_DialogueManager_finished")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")
	beam_polygon.set_visible(false)

func _on_ActivateArea_body_entered(_body):
	# Guaranteed player due to collision mask
	activate_area.set_deferred("monitoring", false)
	wizard.fly_in()
	player.set_input_locked(true)
	DialogueManager.queue_dialogue(dialogue_1)
	camera_player.zoom_in()
	# TODO: play swoosh sound as the wizard flies in.

func _on_DialogueManager_finished():
	match dialogue_stage:
		0:
			wizard.start()
			GlobalMusic.play("brash")
			player.set_input_locked(false)
			animation_player.play("start")
			button_left.set_depressed(false)
			button_right.set_depressed(false)
			barrier_left.enable()
			barrier_right.enable()
			$LevelHUD.show_boss_health()
			dialogue_stage = 1
			camera_player.zoom_out()
			camera_player.position = Vector2(0, 0)
		1:
			camera_player.drag_margin_v_enabled = true
			camera_player.position = Vector2(0, 0)
			player.set_input_locked(false)
			wizard.escape()
			barrier_right.disable()

func _on_DialogueManager_broadcast(message):
	match message:
		"virus_speak":
			camera_player.global_position = wizard.global_position

func _on_RedButtonLeft_pressed():
	button_right.set_depressed(false)
	left_pulse_audio_player.play()
	fire_cannon()

func _on_RedButtonRight_pressed():
	button_left.set_depressed(false)
	right_pulse_audio_player.play()
	fire_cannon()

func fire_cannon():
	cannon_animation_player.play("fire")
	wizard.hit()

func _on_WizardFight_death():
	GlobalMusic.stop()
	button_left.set_depressed(true)
	button_right.set_depressed(true)
	player.set_input_locked(true)
	camera_player.drag_margin_v_enabled = false
	camera_player.global_position.x = wizard.global_position.x
	camera_player.position.y = TALK_CAMERA_Y
	$LevelHUD.hide_boss_health()
	$MovingPlatformInnerLeft.stopping_at_start = true
	$MovingPlatformInnerRight.stopping_at_start = true
	$MovingPlatformOuterLeft.stopping_at_start = true
	$MovingPlatformOuterRight.stopping_at_start = true
	$MovingPlatformMidLeft.stopping_at_start = true
	$MovingPlatformMidRight.stopping_at_start = true
	for creep in get_tree().get_nodes_in_group("creep"):
		creep.die()

func _on_WizardFight_death_animation_ended():
	DialogueManager.queue_dialogue(dialogue_2)
