extends Level

export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []
onready var player = $Player
onready var animation_player = $AnimationPlayer
onready var yellow_cutscene = $YellowCutscene

func _ready():
	player.set_visible(false)
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")
	animation_player.play("cutscene_1")

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

func _on_cutscene_skip():
	animation_player.play("cutscene_2")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	DialogueManager.cancel_dialogue()
	end_cutscene()
