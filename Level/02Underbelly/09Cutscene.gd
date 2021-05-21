extends Level

onready var animation_player = $AnimationPlayer
onready var timer = $Timer
export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []
export(Array, Resource) var dialogue_3 = []

const NEXT_SCENE = "res://Level/02Underbelly/10Boss.tscn"
var stage = 0

func _ready():
	DialogueManager.connect("finished", self, "_on_DialogueManager_finished")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")
	animation_player.play("cutscene_1")

func _on_DialogueManager_finished():
	match stage:
		0:
			# Play yellow jumps down animation
			animation_player.play("cutscene_2")
			stage = 1
		1:
			GlobalMusic.stop(5.0)
			animation_player.play("cutscene_pause")
			stage = 2
		2:
			# Run out
			animation_player.play("cutscene_3")

func _on_DialogueManager_broadcast(message):
	match message:
		"light_fire":
			pass
		"max_what":
			animation_player.play("max_what")
		"max_come_on":
			animation_player.play("max_come_on")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1)
		"cutscene_2":
			#GlobalMusic.play("sanctuary")
			DialogueManager.queue_dialogue(dialogue_2)
			animation_player.play("light_fire")
			GlobalMusic.play("sanctuary", 0.0, 47.5)
		"cutscene_pause":
			DialogueManager.queue_dialogue(dialogue_3)
			GlobalMusic.play("invasion")

func _on_Timer_timeout():
	DialogueManager.queue_dialogue(dialogue_3)
	GlobalMusic.play("invasion")

func end():
	SceneTransition.fade(NEXT_SCENE)

func _on_cutscene_skip():
	animation_player.stop()
	DialogueManager.cancel_dialogue()
	end()
