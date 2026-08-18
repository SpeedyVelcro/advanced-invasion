extends Node

var integration_enabled = false: get = is_integration_enabled, set = set_integration_enabled

signal enabled
signal disabled


# Getters and setters
func set_integration_enabled(value : bool):
	integration_enabled = value
	if value:
		AchievementService.sync_enabled = true
		emit_signal("enabled")
	else:
		AchievementService.sync_enabled = false
		emit_signal("disabled")

func is_integration_enabled():
	return integration_enabled
