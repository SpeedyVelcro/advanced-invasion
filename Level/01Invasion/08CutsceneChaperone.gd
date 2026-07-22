extends Node

@export var dialogue_1 = [] # (Array, Resource)

const NEXT_SCENE = "res://Level/01Invasion/09Cutscene.tscn"

func _ready():
	$AnimationPlayer.play("cutscene_1")
	DialogueManager.connect("finished", Callable(self, "_on_DialogueManager_finished"))

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1)

func _on_DialogueManager_finished():
	$AnimationPlayer.play("cutscene_2")

func end():
	DialogueManager.cancel_dialogue()
	SceneTransition.fade(NEXT_SCENE)
