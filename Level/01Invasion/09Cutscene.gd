extends Level

export(Array, Resource) var dialogue_1 = []
onready var animation_player = $CutsceneChaperone/AnimationPlayer
const NEXT_SCENE = "res://Level/01Invasion/10Cutscene.tscn"
const VIRUS_RESOURCE = preload("res://Entity/Creep/VirusPawn/VirusPawn.tscn")
onready var portal_left = $PortalLeft
onready var portal_right = $PortalRight

func _ready():
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")
	animation_player.play("cutscene_1")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			animation_player.play("cutscene_2")
			GlobalMusic.play("brash_fakeout")

func _on_DialogueManager_broadcast(message):
	match message:
		"commander":
			animation_player.play("commander")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")

func spawn_virus():
	var virus_left = VIRUS_RESOURCE.instance()
	var virus_right = VIRUS_RESOURCE.instance()
	add_child(virus_left)
	add_child(virus_right)
	virus_left.global_position = portal_left.global_position
	virus_right.global_position = portal_right.global_position
	virus_left.set_direction(Vector2.LEFT)
	virus_right.set_direction(Vector2.RIGHT)

func end():
	SceneTransition.fade(NEXT_SCENE)

func _on_cutscene_skip():
	DialogueManager.cancel_dialogue()
	animation_player.stop()
	end()
