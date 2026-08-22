extends Level

@onready var animation_player = $AnimationPlayer
@onready var camera_player = $Player/CameraPlayer
@onready var button_blocker = $ButtonBlocker
var button_freed = false
@export var dialogue_1: Array[Dialogue] = []
@export var dialogue_2: Array[Dialogue] = []

func _ready():
	super()
	
	DialogueManager.end_broadcast_signal.connect(_on_DialogueManager_end_broadcast)
	DialogueManager.connect("broadcast", Callable(self, "_on_DialogueManager_broadcast"))
	DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
	animation_player.play("cutscene_reset")

func cutscene_proceed():
	DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			pass # Actually doing this in cutscene_proceed()
			#DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			animation_player.play("cutscene_1")
		"dialogue_2":
			end_cutscene()

func button_click():
	# This function queue_free()s a static body so the player lands on a button
	if not button_freed:
		button_blocker.queue_free()
		button_freed = true

func _on_cutscene_skip():
	animation_player.play("cutscene_1")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	DialogueManager.cancel_dialogue()
	button_click()
	end_cutscene()

func end_cutscene():
	GlobalMusic.play("petra")
	player.set_input_locked(false)
	camera_player.set_position(Vector2(0, 0))
	camera_player.input_enabled = true
	set_cutscene_active(false)
