extends Node

export(Array, Resource) var dialogue_1 = []
const NEXT_SCENE = "res://Level/02Underbelly/01Level.tscn"

func _ready():
	$AnimationPlayer.play("cutscene")

func end():
	SceneTransition.fade(NEXT_SCENE)

func scream():
	DialogueManager.queue_dialogue(dialogue_1)
