class_name KillZone
extends Area2D
## Area that kills the player when entered. Optionally, you may set a respawn
## marker. If a respawn marker is set, then, only on Standard difficulty and
## with multiple lives remaining, the player will only lose a single life and
## be teleported to that market.

@export var respawn_marker: Marker2D

func _on_LevelEnd_body_entered(body):
	if body.get_name() != "Player":
		return
	
	if respawn_marker and StoryStatus.lives_enabled and body.health > 1:
		body.hit(Vector2(0,0), 1)
		body.global_position = respawn_marker.global_position
	else:
		body.hit(Vector2(0, 0), -1)
