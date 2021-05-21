extends Node

export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_1_2 = [] # because I have terrible foresight lol
export(Array, Resource) var dialogue_2 = []
export(Array, Resource) var dialogue_3 = []

var current_event = 0

const NEXT_SCENE = "res://Level/01Invasion/02Level.tscn"

func _ready():
	$AnimationPlayer.play("cutscene_1")
	DialogueManager.connect("finished", self, "_on_DialogueManager_finished")

func advance():
	current_event += 1
	match current_event:
		1:
			# cutscene_1 animation just finished, "Commander look at this"
			DialogueManager.queue_dialogue(dialogue_1)
			$AnimationPlayer.stop(false) # reset is false to keep position
		2:
			# Dialogue advanced, unpause for commander to come over
			$AnimationPlayer.play()
		3:
			# Commander came over
			DialogueManager.queue_dialogue(dialogue_1_2)
			$AnimationPlayer.stop(false)
		4:
			# Dialogue advanced, unpause
			$AnimationPlayer.play()
		5:
			# Just blacked out, commander comments on this
			DialogueManager.queue_dialogue(dialogue_2)
			$AnimationPlayer.stop(false)
		6:
			# Viruses show up on screen
			$AnimationPlayer.play()
		7:
			# Commander reacts
			DialogueManager.queue_dialogue(dialogue_3)
			$AnimationPlayer.stop(false)
		8:
			# Militia moves out
			$AnimationPlayer.play()

func play_music():
	GlobalMusic.play("invasion")

func _on_DialogueManager_finished():
	match current_event:
		1:
			advance()
		3:
			advance()
		5:
			advance()
		7:
			advance()

func end():
	SceneTransition.fade(NEXT_SCENE)
