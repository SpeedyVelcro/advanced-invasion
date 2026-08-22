extends Level

@export var respawn_marker: Marker2D
@export var pit_area: Area2D


func _on_player_hit_taken(killing_blow: bool) -> void:
	if killing_blow:
		return
	
	if pit_area.overlaps_body(player):
		player.global_position = respawn_marker.global_position
		player.reset_physics_interpolation()
