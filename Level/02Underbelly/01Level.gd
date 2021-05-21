extends Level

export(Array, Resource) var dialogue_start = []
export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []

onready var player = $Player
onready var player_camera = $Player/CameraPlayer
onready var teal_character = $Teal
onready var umbrella_camera_position = $UmbrellaCameraPosition
onready var teal_position = $TealPosition
onready var timer = $Timer
onready var tutorialise_area = $TutorialiseArea
onready var animation_player = $AnimationPlayer
onready var oof_area = $OofArea

func _ready():
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")
	animation_player.play("reset")

func _on_OofArea_body_entered(body):
	# Mask ensures this is player
	DialogueManager.queue_dialogue(dialogue_start, "dialogue_start")
	oof_area.set_deferred("monitoring", false)

func _on_TutorialiseArea_body_entered(body):
	# Mask ensures this is player
	player.set_input_locked(true)
	DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
	player_camera.global_position = teal_position.global_position
	tutorialise_area.set_deferred("monitoring", false)
	animation_player.play("dialogue_1")
	GlobalMusic.stop(4.0)

func _on_DialogueManager_broadcast(message):
	match message:
		"camera_teal":
			player_camera.global_position = teal_position.global_position
		"camera_player":
			player_camera.position = Vector2(0, 0)
		"camera_umbrella":
			player_camera.global_position = umbrella_camera_position.global_position
		"gesture_barrier":
			animation_player.play("gesture_barrier")
		"ungesture_barrier":
			animation_player.play("ungesture_barrier")
			player_camera.global_position = teal_character.global_position
		"teal_face_left":
			animation_player.play("teal_face_left")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			player_camera.position = Vector2(0, 0)
			player.set_input_locked(false)
		"dialogue_2":
			GlobalMusic.play("anxiety")
			timer.start(0.5)
			animation_player.play("teal_run")
		"dialogue_start":
			GlobalMusic.play("firefly")
			player.set_input_locked(false)

func _on_VirusPawn_death():
	player.set_input_locked(true)
	DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
	player_camera.global_position = teal_character.global_position
	animation_player.play("dialogue_2")

func _on_Timer_timeout():
	player.set_input_locked(false)
	player_camera.position = Vector2(0, 0)
