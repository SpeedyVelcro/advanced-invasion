extends Area2D

func _on_LevelEnd_body_entered(body):
	if body.get_name() == "Player":
		body.hit(Vector2(0, 0), -1)
