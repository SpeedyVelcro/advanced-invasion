extends RigidBody2D

onready var bounce_audio_player = $BounceAudioStreamPlayer

func _physics_process(_delta):
	pass

func _on_Flashbang_body_entered(_body):
	if linear_velocity.length() > 20.0:
		bounce_audio_player.play()
