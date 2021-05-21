extends Area2D

export var level_path = ""

func _on_LevelEnd_body_entered(body):
	if body.get_name() == "Player":
		SceneTransition.fade(level_path)
		queue_free()
