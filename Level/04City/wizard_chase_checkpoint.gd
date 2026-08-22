class_name WizardChaseCheckpoint
extends Marker2D
## It is intended that you enable "Editable children" in order to modify the
## collision shapes, particularly around bendy bits of the level. This is not
## perfect but it's an acceptable trade-off here since this scene is only used
## in one level so any special cases you end up creating are all in one place.
##
## Therefore DO NOT use this outside of the wizard chase boss, lest you incur
## technical debt.

@export var kill_zone: KillZone
@export var next_checkpoint: WizardChaseCheckpoint

var valid := true

## Emitted when the checkpoint is passed (note respawning will usually also pass the
## checkpoint again)
signal passed
## Emitted on respawn at this checkpoint
signal respawned


func _on_checkpoint_area_2d_body_entered(_body: Node2D) -> void:
	if not valid:
		return
	
	if kill_zone.respawn_marker == self:
		respawned.emit()
	
	kill_zone.respawn_marker = self
	passed.emit()


func _on_wizard_disable_area_2d_area_entered(_area: Area2D) -> void:
	if kill_zone.respawn_marker == self:
		if next_checkpoint:
			kill_zone.respawn_marker = next_checkpoint
		else:
			kill_zone.respawn_marker = null
	
	valid = false
	queue_free()
