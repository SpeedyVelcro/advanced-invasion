extends Level

onready var first_guardian = $FirstGuardian
onready var guardian_off_sprite = $GuardianLeftOffSprite
onready var guardian_eyes_sprite = $GuardianLeftEyesSprite
onready var camera_player = $Player/CameraPlayer
onready var animation_player = $AnimationPlayer
onready var player = $Player
onready var robot_audio_stream = $RobotAudioStreamPlayer2D

export(Array, Resource) var dialogue_1 = []

func _ready():
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")
	first_guardian.set_process(false)
	first_guardian.set_physics_process(false)
	first_guardian.set_visible(false)
	animation_player.play("cutscene_1")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
			robot_audio_stream.play()

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			first_guardian.set_process(true)
			first_guardian.set_physics_process(true)
			first_guardian.set_visible(true)
			camera_player.set_position(Vector2(0, 0))
			player.set_input_locked(false)
			guardian_off_sprite.set_visible(false)
			guardian_eyes_sprite.set_visible(false)
