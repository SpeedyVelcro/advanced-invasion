extends Node

export(Array, Resource) var dialogue_1 = []
export(NodePath) var portal_left_path
onready var portal_left = get_node(portal_left_path)
export(NodePath) var portal_right_path
onready var portal_right = get_node(portal_right_path)
onready var creep_resource = preload("res://Entity/Creeps/VirusPawn/VirusPawn.tscn")

const NEXT_SCENE = "res://Level/01Invasion/10Cutscene.tscn"

func _ready():
	$AnimationPlayer.play("cutscene_1")
	DialogueManager.connect("finished", self, "_on_DialogueManager_finished")
	DialogueManager.connect("broadcast", self, "_on_DialogueManager_broadcast")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1)
			#GlobalMusic.stop(6.0)

func _on_DialogueManager_finished():
	$AnimationPlayer.play("cutscene_2")
	GlobalMusic.play("shock", 0.2)

func _on_DialogueManager_broadcast(message):
	match message:
		"commander":
			$AnimationPlayer.play("commander")
		"countdown":
			pass
			#GlobalMusic.stop(2.0)

func end():
	SceneTransition.fade(NEXT_SCENE)

func spawn_virus():
	var creep
	creep = creep_resource.instance()
	creep.set_global_position(portal_left.get_global_position())
	get_owner().add_child(creep)
	creep.set_direction(Vector2.LEFT)
	creep = creep_resource.instance()
	creep.set_global_position(portal_right.get_global_position())
	get_owner().add_child(creep)
	creep.set_direction(Vector2.RIGHT)
