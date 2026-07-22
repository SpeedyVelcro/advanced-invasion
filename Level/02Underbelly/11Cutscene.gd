extends Level

@onready var animation_player = $AnimationPlayer
@export var dialogue_1 = [] # (Array, Resource)
@export var dialogue_2 = [] # (Array, Resource)
@export var dialogue_3 = [] # (Array, Resource)
@export var dialogue_4 = [] # (Array, Resource)
const NEXT_SCENE = "res://Level/03Base/ApproachLevel.tscn"

func _ready():
	DialogueManager.connect("end_broadcast", Callable(self, "_on_DialogueManager_end_broadcast"))
	DialogueManager.connect("broadcast", Callable(self, "_on_DialogueManager_broadcast"))
	animation_player.play("cutscene_1")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			animation_player.play("cutscene_2")
			GlobalMusic.stop(2.0)
		"dialogue_2":
			animation_player.play("cutscene_3")
		"dialogue_3":
			animation_player.play("cutscene_4")
		"dialogue_4":
			animation_player.play("cutscene_5")

func _on_DialogueManager_broadcast(message):
	match message:
		"green_thanks":
			animation_player.play("green_thanks")

func end():
	SceneTransition.fade(NEXT_SCENE)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
		"cutscene_2":
			DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
		"cutscene_3":
			DialogueManager.queue_dialogue(dialogue_3, "dialogue_3")
		"cutscene_4":
			DialogueManager.queue_dialogue(dialogue_4, "dialogue_4")

func _on_cutscene_skip():
	DialogueManager.cancel_dialogue()
	animation_player.stop()
	end()
