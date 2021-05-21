extends Node

onready var newgrounds_api = $NewGroundsAPI
onready var newgrounds_secret = $NewgroundsSecret
const YIELD_ENABLED = true
const NEWGROUNDS_MEDAL_ID = {
	"defeat_giant" : 62836,
	"defeat_square" : 62837,
	"defeat_wizard" : 62838,
	"complete_casual" : 62839,
	"complete_normal" : 62840
}

var integration_enabled = false setget set_integration_enabled, is_integration_enabled

signal enabled
signal disabled

func _ready():
	newgrounds_api.applicationId = newgrounds_secret.APP_ID
	AchievementManager.connect("achievement_synced", self, "_on_AchievementManager_achievement_synced")

func _on_AchievementManager_achievement_synced(achievement_id):
	if integration_enabled:
		newgrounds_api.Medal.unlock(NEWGROUNDS_MEDAL_ID[achievement_id])
		if YIELD_ENABLED:
			var result = yield(newgrounds_api, 'ng_request_complete')
			if not newgrounds_api.is_ok(result):
				push_error("Unlocking newgrounds achievement went wrong. Achievement id: " + achievement_id)
				push_error(result.error)

# Getters and setters
func set_integration_enabled(value : bool):
	integration_enabled = value
	if value:
		emit_signal("enabled")
	else:
		emit_signal("disabled")

func is_integration_enabled():
	return integration_enabled
