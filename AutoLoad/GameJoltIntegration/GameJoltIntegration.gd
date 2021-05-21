extends Node

onready var game_jolt_api = $GameJoltAPI
onready var ping_timer = $PingTimer
onready var secret = $GameJoltSecret
const YIELD_ENABLED = true
const GAME_JOLT_TROPHY_ID = {
	"defeat_giant" : 139868,
	"defeat_square" : 139869,
	"defeat_wizard" : 139870,
	"complete_casual" : 139871,
	"complete_normal" : 139872
}

var integration_enabled = false setget set_integration_enabled, is_integration_enabled

signal session_open
signal session_open_fail
signal session_closed

func _ready():
	game_jolt_api.init(secret.PRIVATE_KEY, secret.GAME_ID)
	AchievementManager.connect("achievement_synced", self, "_on_AchievementManager_achievement_synced")

func login(username : String, token : String):
	game_jolt_api.auth_user(username, token)
	if YIELD_ENABLED:
			yield(game_jolt_api, 'gamejolt_request_completed')
	game_jolt_api.open_session()

func login_auto():
	game_jolt_api.auto_auth()
	if YIELD_ENABLED:
			yield(game_jolt_api, 'gamejolt_request_completed')
	game_jolt_api.open_session()

func logout():
	set_integration_enabled(false)
	game_jolt_api.close_session()
	# Just in case closing session doesn't work we also just straight up stop pinging
	ping_timer.stop()

func _on_AchievementManager_achievement_synced(achievement_id):
	if integration_enabled:
		game_jolt_api.set_trophy_achieved(GAME_JOLT_TROPHY_ID[achievement_id])
		if YIELD_ENABLED:
			yield(game_jolt_api, 'gamejolt_request_completed')
			# Could handle errors with var result = yield(...)
			# May not really be necessary though if GameJoltAPI is on verbose.

func _on_GameJoltAPI_gamejolt_request_completed(type, message, finished):
	match type:
		"/sessions/open/":
			if message["success"]:
				ping_timer.start()
				emit_signal("session_open")
				set_integration_enabled(true)
			else:
				emit_signal("session_open_fail")
		"/sessions/close/":
			#ping_timer.stop() # Ping timer is actually stopped before response just in case
			emit_signal("session_closed")

func _on_PingTimer_timeout():
	game_jolt_api.ping_session()

func _on_GameJoltAPI_tree_exiting():
	if integration_enabled:
		game_jolt_api.close_session()

# Getters and setters
func set_integration_enabled(value : bool):
	integration_enabled = value
	if not value:
		game_jolt_api.close_session()

func is_integration_enabled():
	return integration_enabled
