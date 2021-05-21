extends Level

export(Array, Resource) var dialogue_1 = []

onready var boss_start_area = $BossStartArea
onready var player = $Player
onready var player_camera = $Player/CameraPlayer
onready var breaker_audio_stream_player = $BreakerAudioStreamPlayer
onready var boss_start_timer = $BossStartTimer
const BOSS_START_DELAY = 2.0
onready var wizard_chase = $Path2D/WizardChase
onready var background_layer_1 = $ParallaxBackground/ParallaxLayer
onready var background_layer_2 = $ParallaxBackground/ParallaxLayer2
onready var blocking_barrier = $RedBarrier
onready var animation_player = $AnimationPlayer

func _ready():
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")

func _on_BossStartArea_body_entered(_body):
	# Guaranteed this is player due to collision mask
	boss_start_area.set_deferred("monitoring", false)
	player.set_input_locked(true)
	# Breaker goes off and background disappears
	breaker_audio_stream_player.play()
	background_layer_1.set_visible(false)
	background_layer_2.set_visible(false)
	GlobalMusic.stop(0.1)
	boss_start_timer.start(BOSS_START_DELAY)
	
func _on_BossStartTimer_timeout():
	player_camera.global_position = wizard_chase.global_position
	GlobalMusic.play("brash_intro")
	wizard_chase.appear()

func _on_WizardChase_appeared():
	DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			player.set_input_locked(false)
			player_camera.set_position(Vector2(0, 0))
			wizard_chase.start()
			GlobalMusic.play("brash_no_intro")

func _on_RedButton_pressed():
	blocking_barrier.enable()
	GlobalMusic.stop()
	wizard_chase.end()
	player_camera.set_global_position(wizard_chase.global_position)
	player.set_input_locked(true)

func _on_WizardChase_ended():
	player_camera.set_position(Vector2(0, 0))
	player.set_input_locked(false)
	animation_player.play("background_fade_in")
