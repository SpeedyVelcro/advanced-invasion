extends Level

@export var dialogue_1: Array[Dialogue] = []
@export var dialogue_2: Array[Dialogue] = []
@onready var player_camera = $Player/CameraPlayer
@onready var animation_player = $AnimationPlayer
@onready var yellow_cutscene = $YellowCutscene

func _ready():
	super()
	player.set_visible(false)
	DialogueManager.connect("end_broadcast_signal", Callable(self, "_on_DialogueManager_end_broadcast"))
	DialogueManager.connect("broadcast", Callable(self, "_on_DialogueManager_broadcast"))
	animation_player.play("cutscene_1")
	player_camera.input_enabled = false
	

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			animation_player.play("cutscene_2")
		"dialogue_2":
			end_cutscene()

func _on_DialogueManager_broadcast(message):
	match message:
		"":
			pass


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
		"cutscene_2":
			DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")

func end_cutscene():
	player.set_visible(true)
	yellow_cutscene.set_visible(false)
	player.set_input_locked(false)
	set_cutscene_active(false)
	player_camera.input_enabled = true

func _on_cutscene_skip():
	animation_player.play("cutscene_2")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	DialogueManager.cancel_dialogue()
	end_cutscene()
