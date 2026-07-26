extends Level

@export var dialogue_1: Array[Dialogue] = [] # (Array, Resource)
@export var dialogue_2: Array[Dialogue] = [] # (Array, Resource)
@export var dialogue_3: Array[Dialogue] = [] # (Array, Resource)
@export var dialogue_4: Array[Dialogue] = [] # (Array, Resource)
@onready var animation_player = $AnimationPlayer
const NEXT_SCENE = "res://Level/01Invasion/02Level.tscn"

func _ready():
	super()
	
	GlobalMusic.play("invasion")
	DialogueManager.end_broadcast_signal.connect(_on_DialogueManager_end_broadcast)
	DialogueManager.connect("broadcast", Callable(self, "_on_DialogueManager_broadcast"))
	DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
	animation_player.play("reset")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			animation_player.play("cutscene_1")
		"dialogue_2":
			animation_player.play("cutscene_2")
		"dialogue_3":
			animation_player.play("cutscene_3")
		"dialogue_4":
			end()

func _on_DialogueManager_broadcast(message):
	match message:
		"return_from_feed":
			animation_player.play("return_from_feed")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
		"cutscene_2":
			DialogueManager.queue_dialogue(dialogue_3, "dialogue_3")
		"cutscene_3":
			DialogueManager.queue_dialogue(dialogue_4, "dialogue_4")

func end():
	SceneTransition.fade(NEXT_SCENE)

func _on_cutscene_skip():
	end()
