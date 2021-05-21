extends Level

onready var animation_player = $AnimationPlayer

const NEXT_SCENE = "res://Level/03Base/10Cutscene.tscn"

func _ready():
	animation_player.play("cutscene_1")

func end():
	SceneTransition.fade(NEXT_SCENE)

func _on_cutscene_skip():
	animation_player.stop()
	end()
