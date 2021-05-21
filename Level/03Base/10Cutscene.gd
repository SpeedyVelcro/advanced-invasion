extends Level

onready var animation_player = $AnimationPlayer
export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []
export(Array, Resource) var dialogue_3 = []
export(Array, Resource) var dialogue_4 = []
export(Array, Resource) var dialogue_5 = []
# You must flee...
# Find another computer...
# *drops dead*
# COMMANDER!!
# *Max walks in and green probably* Commander?
# Commander!
# What happened!
# Mini: ...
# Mini: ...!
# Mini: *Turning around* The computer's gonna explode!
# Mini: There's no time to explain, we've gotta get out of here!
# Then someone explains the ancient city passageway
# Later on at ancient city, after the "wow" and being generally dumbfounded
# someone says something like come on, we've got to keep moving or hurry or something
const NEXT_SCENE = "res://Level/03Base/11Level.tscn"

func _ready():
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")
	animation_player.play("cutscene_1")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1)
			DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
			# Dialogue 1 and 2 are effectively pushed as 1 dialogue since at some
			# point I changed my mind and decided they should be continuous.
		"cutscene_2":
			pass
			# CHANGED: cutscene 2 now plays simultaneously with dialogue 2
			#DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
		"bombshell_pause":
			DialogueManager.queue_dialogue(dialogue_3, "dialogue_3")
			GlobalMusic.play("invasion")
			animation_player.play("what")
		"cutscene_3":
			DialogueManager.queue_dialogue(dialogue_4, "dialogue_4")
		"cutscene_4":
			DialogueManager.queue_dialogue(dialogue_5, "dialogue_5")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			pass
			# LEGACY: This never triggers
			#animation_player.play("cutscene_2")
			#DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
			#GlobalMusic.play("deathbed")
		"dialogue_2":
			animation_player.play("bombshell_pause")
			GlobalMusic.stop(2.5) # Slightly shorter than bombhsell pause
			# Gives some extra time for "deathbed" to end naturally if at all possible
		"dialogue_3":
			animation_player.play("cutscene_3")
		"dialogue_4":
			animation_player.play("cutscene_4")
		"dialogue_5":
			animation_player.play("cutscene_5")

func _on_DialogueManager_broadcast(message):
	match message:
		"run_over":
			animation_player.play("cutscene_2")
			GlobalMusic.play("deathbed")
		"commander_explains":
			pass # TODO: play tragedy-version of militia that I'm gonna write
		"commander_bombshell":
			pass
			# Now done during bombshell pause, after this dialogue
			#GlobalMusic.stop()
		"what":
			pass # This stuff is actually just done after bombshell_pause
		"unwhat":
			animation_player.play("unwhat")
		"commander_collapse":
			animation_player.play("commander_collapse")
		"green_to_commander":
			animation_player.play("green_to_commander")
		"no_time_to_explain":
			animation_player.play("no_time_to_explain")
		"green_what":
			animation_player.play("green_what")

func end():
	SceneTransition.fade(NEXT_SCENE)

func _on_cutscene_skip():
	DialogueManager.cancel_dialogue()
	animation_player.stop()
	end()
