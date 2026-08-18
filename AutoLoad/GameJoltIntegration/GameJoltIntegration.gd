extends Node

@onready var ping_timer = $PingTimer

var integration_enabled = false: get = is_integration_enabled, set = set_integration_enabled

signal session_open
signal session_open_fail
signal session_closed

func _ready():
	GameJolt.sessions_open_completed.connect(_on_game_jolt_sessions_open_completed)
	GameJolt.sessions_ping_completed.connect(_on_game_jolt_sessions_ping_completed)
	GameJolt.sessions_close_completed.connect(_on_game_jolt_sessions_close_completed)
	GameJolt.users_auth_completed.connect(_on_game_jolt_users_auth_completed)

func login(username : String, token : String):
	GameJolt.set_user_name(username)
	GameJolt.set_user_token(token)
	GameJolt.users_auth()
	# TODO: move to signal connection
	GameJolt.sessions_open()


func login_auto():
	if not OS.has_feature("web"):
		push_error("Cannot auto-login to Game Jolt because this is not the web version of the game.")
	
	# Not sure this is actually documented anywhere, but you can check by watching the
	# network calls when playing an HTML5 Game Jolt game.
	var param_name = JavaScriptBridge.eval("new URL(window.location.href).searchParams.get('gjapi_username')")
	var param_token = JavaScriptBridge.eval("new URL(window.location.href).searchParams.get('gjapi_token')")
	
	var param_name_string := str(param_name)
	var param_token_string := str(param_token)
	
	login(param_name_string, param_token_string)

func logout():
	GameJolt.sessions_close()


# Signal Connection
func _on_game_jolt_sessions_open_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if not success:
		var message := _get_message(response)
		push_error("Failed to open Game Jolt session. Message: %s" % message)
		session_open_fail.emit()
		return
	
	set_integration_enabled(true)
	session_open.emit()
	ping_timer.start(30.0)


# Signal Connection
func _on_game_jolt_sessions_ping_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if not success:
		var message := _get_message(response)
		push_error("Session is now closed beccause pinging Game Jolt failed. Message: %s" % message)
		return
	
	set_integration_enabled(false)
	session_closed.emit()
	ping_timer.stop()


# Signal Connection
func _on_game_jolt_sessions_close_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if not success:
		var message := _get_message(response)
		push_error("Failed to close Game Jolt session. Message: %s" % message)
		return
	
	set_integration_enabled(false)
	session_closed.emit()
	ping_timer.stop()


# Signal Connection
func _on_game_jolt_users_auth_completed(response: Dictionary) -> void:
	var success := _is_success(response)
	
	if not success:
		var message := _get_message(response)
		push_error("Failed to authenticate Game Jolt user. Message: %s" % message)
		session_open_fail.emit()
		return
	
	GameJolt.sessions_open()


func _is_success(response: Dictionary) -> bool:
	return response.has("success") and (response["success"] == "true" or response["success"] == true)


func _get_message(response: Dictionary) -> String:
	return str(response["message"]) if response.has["message"] else ""


# Signal Connection
func _on_ping_timer_timeout() -> void:
	GameJolt.sessions_ping()


# Getters and setters
func set_integration_enabled(value : bool):
	integration_enabled = value
	AchievementService.sync_enabled = integration_enabled


func is_integration_enabled():
	return integration_enabled
