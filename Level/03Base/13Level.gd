extends Level

func _on_StopMusicArea_body_entered(body):
	GlobalMusic.stop(5.0)
