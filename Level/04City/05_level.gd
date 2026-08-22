extends Level

@export var kill_zone: KillZone
@export var moving_platform: MovingPlatform
@export var respawn_marker: Marker2D
@export var respawn_marker_2: Marker2D
@export var respawn_marker_3: Marker2D
@export var respawn_marker_4: Marker2D
@export var respawn_marker_5: Marker2D
@export var platform_reset_marker: Marker2D
@export var platform_reset_marker_2: Marker2D
@export var platform_reset_marker_3: Marker2D
@export var platform_reset_marker_4: Marker2D

var current_platform_reset_marker: Marker2D = null


func _on_checkpoint_area_2d_body_entered(_body: Node2D) -> void:
	kill_zone.respawn_marker = respawn_marker_2
	current_platform_reset_marker = platform_reset_marker


func _on_checkpoint_area_2d_2_body_entered(_body: Node2D) -> void:
	kill_zone.respawn_marker = respawn_marker_3
	current_platform_reset_marker = platform_reset_marker_2


func _on_checkpoint_area_2d_3_body_entered(_body: Node2D) -> void:
	kill_zone.respawn_marker = respawn_marker_4
	current_platform_reset_marker = platform_reset_marker_3


func _on_checkpoint_area_2d_4_body_entered(_body: Node2D) -> void:
	kill_zone.respawn_marker = respawn_marker_5
	current_platform_reset_marker = platform_reset_marker_4


func _on_kill_zone_body_entered(_body: Node2D) -> void:
	if current_platform_reset_marker:
		# Check prevents a time-skip by jumping off ledge to teleport platform forward
		# We give a 128-pixel berth so that the platform doesn't immediately start
		# running away on respawn. This does still give a small time-skip, but it's
		# only useful for speedrunners to gain a small edge which is fine (it's only
		# regular gameplay where we don't want to encourage unintuitive mechanics)
		if (not moving_platform.is_moving_forward()) or moving_platform.global_position.x >= current_platform_reset_marker.global_position.x - 128:
			moving_platform.reset_to_global_position(current_platform_reset_marker.global_position)
	else:
		moving_platform.reset()
