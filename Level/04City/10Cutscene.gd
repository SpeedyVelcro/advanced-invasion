extends Level

export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []
export(Array, Resource) var dialogue_3 = []

onready var animation_player = $AnimationPlayer
onready var camera = $CameraPlayer
onready var pin_audio_player = $PinAudioStreamPlayer
onready var flashbang = $Flashbang
const FLASHBANG_VELOCITY = Vector2(-140, -50)
const NEXT_SCENE = "res://GUI/EndCredits/EndCredits.tscn"

func _ready():
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")
	animation_player.play("cutscene_1")
	flashbang.set_visible(false)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
		"cutscene_2":
			DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
		"cutscene_3":
			DialogueManager.queue_dialogue(dialogue_3, "dialogue_3")
		"cutscene_4":
			end()

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			animation_player.play("cutscene_2")
		"dialogue_2":
			flashbang.set_visible(true)
			flashbang.set_mode(flashbang.MODE_RIGID)
			flashbang.set_linear_velocity(FLASHBANG_VELOCITY)
			animation_player.play("cutscene_3")
		"dialogue_3":
			animation_player.play("cutscene_4")

func _on_DialogueManager_broadcast(message):
	match message:
		"teal_now":
			camera.zoom_out()
		"teal_wait":
			GlobalMusic.stop()
			pin_audio_player.play()
		"teal_step_forward":
			animation_player.play("teal_step_forward")
		"scareye_back":
			animation_player.play("scareye_back")
		"scareye_forward":
			animation_player.play("scareye_forward")
		"teal_turn":
			animation_player.play("teal_turn")
		"teal_unturn":
			animation_player.play("teal_unturn")

func play_dynamite():
	GlobalMusic.play("dynamite")

func play_favour():
	GlobalMusic.play("favour")

func mark_story_finished():
	GameStatus.set_story_completion(true)
	if StoryStatus.get_difficulty_id() == 1:
		GameStatus.set_story_normal_completion(true)
	GameStatus.save()

func end():
	mark_story_finished()
	SceneTransition.instant(NEXT_SCENE)

func _on_cutscene_skip():
	animation_player.stop()
	DialogueManager.cancel_dialogue()
	end()
