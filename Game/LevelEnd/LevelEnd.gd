extends Area2D

@export var level_path = ""

func _on_LevelEnd_body_entered(body):
	if body is Player:
		SceneTransition.fade(level_path)
		queue_free()
