class_name Migrator
extends Node
## Static class for running save file migrations
##
## Runs migrations between different versions of the game for all saved data,
## maintaining backwards compatibility. To be called immediately in main.gd,
## before any save data gets used.


## Runs all migrations in order.
static func migrate_all() -> void:
	# Options migrations
	migrate_options_to_sv_options() #v1.0.0 to next version
	# No need to manually load changes because we have auto-start off, so the first load won't have happened yet.
	
	# Music unlock migrations
	migrate_music_unlocks_to_sv_jukebox() #v1.0.0 to next version
	SVJukebox.load_unlocks()
	
	# Achievement migrations
	migrate_achievements_to_sv_achievements() #v1.0.0 to next version
	AchievementService.load_progress()
	
	# Story status migration
	migrate_player_status_to_v1_1_0()


static func migrate_options_to_sv_options() -> void:
	const OLD_FILENAME := "user://options.json"
	const NEW_FILENAME := "user://user-settings.json"
	
	if FileAccess.file_exists(NEW_FILENAME):
		# Already migrated
		if FileAccess.file_exists(OLD_FILENAME):
			DirAccess.remove_absolute(OLD_FILENAME)
		
		return
	
	var old_file := FileAccess.open(OLD_FILENAME, FileAccess.READ)
	
	if not old_file:
		var file_error := FileAccess.get_open_error()
		
		if file_error == ERR_FILE_NOT_FOUND:
			return # Nothing to migrate
		
		push_error("Cannot migrate options file to SV Options due to file access error %d" % file_error)
		return
	
	var text := old_file.get_as_text()
	old_file.close()
	
	var json := JSON.new()
	var json_error := json.parse(text)
	
	if json_error != OK:
		push_error("Failed to migrate options file due to JSON parse error %d" % json_error)
		return
	
	var data_received = json.data
	
	if data_received is not Dictionary:
		push_error("Failed to migrate options file due to parsed JSON not being a dictionary")
		return
	
	var mute_master := _get_bool_from_json_dict(data_received, ["audio", "mute_master"], false)
	var mute_music := _get_bool_from_json_dict(data_received, ["audio", "mute_music"], false)
	var mute_effects := _get_bool_from_json_dict(data_received, ["audio", "mute_effects"], false)
	var mute_ui := _get_bool_from_json_dict(data_received, ["audio", "mute_ui"], false)
	
	# NB: Even though volumes were stored under a "db" key, they were actually linear.
	var volume_linear_master := _get_float_from_json_dict(data_received, ["audio", "volume_db_master"], 1.0)
	var volume_linear_music := _get_float_from_json_dict(data_received, ["audio", "volume_db_music"], 1.0)
	var volume_linear_effects := _get_float_from_json_dict(data_received, ["audio", "volume_db_effects"], 1.0)
	var volume_linear_ui := _get_float_from_json_dict(data_received, ["audio", "volume_db_ui"], 1.0)
	
	var fullscreen := _get_bool_from_json_dict(data_received, ["video", "fullscreen"], false)
	var resolution := Vector2i(
		_get_int_from_json_dict(data_received, ["video", "resolution_x"], -1),
		_get_int_from_json_dict(data_received, ["video", "resolution_y"], -1)
	)
	resolution = Vector2i(1280, 720) if resolution.x <= 0 or resolution.y <= 0 else resolution
	var vsync_enabled := _get_bool_from_json_dict(data_received, ["video", "vsync"], false)
	
	var new_dict: Dictionary = { # TODO: complete
		"audio": {
			"Master": {
				"level": volume_linear_master,
				"mute": mute_master
			},
			"Music": {
				"level": volume_linear_music,
				"mute": mute_music
			},
			"Effects": {
				"level": volume_linear_effects,
				"mute": mute_effects
			},
			"UI": {
				"level": volume_linear_ui,
				"mute": mute_ui
			}
		},
		"display": {
			"resolution": {
				"x": resolution.x,
				"y": resolution.y
			},
			"vsync": DisplayServer.VSyncMode.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSyncMode.VSYNC_DISABLED,
			"window_mode": DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
		}
	}
	
	var json_string = JSON.stringify(new_dict, "\t")
	
	var new_file := FileAccess.open(NEW_FILENAME, FileAccess.WRITE)
	
	if not new_file:
		push_error("Failed to save migrated options due to error %d" % FileAccess.get_open_error())
		return
	
	new_file.store_string(json_string)
	new_file.close()
	
	DirAccess.remove_absolute(OLD_FILENAME)


static func migrate_music_unlocks_to_sv_jukebox() -> void:
	const GAME_STATUS_FILENAME := "user://game-status.json"
	const NEW_FILENAME := "user://music-unlocks.json"
	
	if FileAccess.file_exists(NEW_FILENAME):
		# Already migrated
		
		# No need to delete old file, as the game status file still contains other info.
		return
	
	var game_status_file := FileAccess.open(GAME_STATUS_FILENAME, FileAccess.READ_WRITE)
	
	if not game_status_file:
		var file_error := FileAccess.get_open_error()
		
		if file_error == ERR_FILE_NOT_FOUND:
			return # Nothing to migrate
		
		push_error("Unable to migrate music unlocks as cannot open game status file due to error %d" % file_error)
		return
	
	var text := game_status_file.get_as_text()
	# We will keep the game status file open as we still need to delete the soundtrack_unlocked
	# section once migrated.
	
	var json := JSON.new()
	var json_error := json.parse(text)
	
	if json_error != OK:
		push_error("Failed to migrate music unlocks due to JSON parse error %d" % json_error)
		game_status_file.close()
		return
	
	var data_received = json.data
	
	if data_received is not Dictionary:
		push_error("Failed to migrate music unlocks due to parsed JSON not being a dictionary")
		game_status_file.close()
		return
	
	if not data_received.has("soundtrack_unlocked"):
		game_status_file.close()
		return # No unlocks to migrate.
	
	var unlocks_dict = data_received["soundtrack_unlocked"]
	
	if unlocks_dict is not Dictionary:
		push_error("Failed to migrate music unlocks due to soundtrack_unlocked section not being a dictionary")
		game_status_file.close()
		return
	
	var new_dict: Dictionary = {
		"unlocked_ids": unlocks_dict.keys()
				.filter(func(key: String) -> bool: return unlocks_dict[key] is bool and unlocks_dict[key])
				.map(func(key: String) -> String: return key)
	}
	
	var json_string = JSON.stringify(new_dict, "\t")
	
	var new_file := FileAccess.open(NEW_FILENAME, FileAccess.WRITE)
	
	if not new_file:
		push_error("Failed to save migrated music unlocks due to error %d" % FileAccess.get_open_error())
		game_status_file.close()
		return
	
	new_file.store_string(json_string)
	new_file.close()
	
	# Now that it's migrated we can safely delete the soundtrack_unlocked section.
	data_received.erase("soundtrack_unlocked")
	
	var game_status_new_json_string = JSON.stringify(data_received, "\t")
	game_status_file.seek(0)
	game_status_file.store_string(game_status_new_json_string)
	var err := game_status_file.resize(game_status_file.get_position()) # Truncate manually, because we're open in READ_WRITE not just WRITE
	if err != OK:
		push_error("Error when truncating game status file during music unlocks migration: %d" % err)
		# Not much we can do here so just continue and close the file and hope for the best.
	game_status_file.close()


static func migrate_achievements_to_sv_achievements() -> void:
	const FILENAME := "user://achievements.json" # In-file migration
	
	var file := FileAccess.open(FILENAME, FileAccess.READ_WRITE)
	
	if not file:
		var file_error := FileAccess.get_open_error()
		
		if file_error == ERR_FILE_NOT_FOUND:
			return # Nothing to migrate
		
		push_error("Cannot migrate achievements file to SV Achievements due to file access error %d" % file_error)
		return
	
	var text := file.get_as_text()
	
	var json := JSON.new()
	var json_error := json.parse(text)
	
	if json_error != OK:
		push_error("Failed to migrate achievements file due to JSON parse error %d" % json_error)
		file.close()
		return
	
	var data_received = json.data
	
	if data_received is not Dictionary:
		push_error("Failed to migrate achievements file due to parsed JSON not being a dictionary")
		file.close()
		return
	
	# Due to my poor foresight these files don't have version numbers built in so I guess we just
	# have to go by the structure of the file.
	var needs_migration: bool = data_received.has("achievement_progress") or data_received.has("achievement_unlocked")
	
	if not needs_migration:
		file.close()
		return # Already migrated
	
	var unlocks = data_received.get("achievement_unlocked")
	
	if unlocks is not Dictionary:
		file.close()
		push_error("Cannot migrate achievements to SV Achievements as there is an incorrect type in the JSON.")
		return
	
	var defeat_giant: bool = unlocks["defeat_giant"] if unlocks["defeat_giant"] is bool else false
	var defeat_square: bool = unlocks["defeat_square"] if unlocks["defeat_square"] is bool else false
	var defeat_wizard: bool = unlocks["defeat_wizard"] if unlocks["defeat_wizard"] is bool else false
	var complete_casual: bool = unlocks["complete_casual"] if unlocks["complete_casual"] is bool else false
	var complete_normal: bool = unlocks["complete_normal"] if unlocks["complete_normal"] is bool else false
	
	var new_dict: Dictionary = {
		"defeat_giant": {
			"unlocked": defeat_giant
		},
		"defeat_square": {
			"unlocked": defeat_square
		},
		"defeat_wizard": {
			"unlocked": defeat_wizard
		},
		"complete_casual": {
			"unlocked": complete_casual
		},
		"complete_normal": {
			"unlocked": complete_normal
		}
	}
	
	var new_json_string = JSON.stringify(new_dict, "\t")
	file.seek(0)
	file.store_string(new_json_string)
	var err := file.resize(file.get_position()) # Truncate manually, because we're open in READ_WRITE not just WRITE
	if err != OK:
		push_error("Error when truncating achievements file during achievement unlocks migration: %d" % err)
		# Not much we can do here so just continue and close the file and hope for the best.
	file.close()


static func migrate_player_status_to_v1_1_0() -> void:
	const FILENAME := "user://player-status.json"
	
	var file := FileAccess.open(FILENAME, FileAccess.READ_WRITE)
	
	if not file:
		var file_error := FileAccess.get_open_error()
		
		if file_error == ERR_FILE_NOT_FOUND:
			return # Nothing to migrate
		
		push_error("Cannot migrate player status file to v1.1.0 due to file access error %d" % file_error)
		return
	
	var text := file.get_as_text()
	
	var json := JSON.new()
	var json_error := json.parse(text)
	
	if json_error != OK:
		push_error("Failed to migrate player status file to v1.1.0 due to JSON parse error %d" % json_error)
		file.close()
		return
	
	var data_received = json.data
	
	if data_received is not Dictionary:
		push_error("Failed to migrate player status file to v1.0.0 due to parsed JSON not being a dictionary")
		file.close()
		return
	
	if data_received.has("current_level"):
		if data_received["current_level"] == "res://Level/02Underbelly/09Cutscene.tscn":
			data_received["current_level"] = "res://Level/02Underbelly/09Level.tscn"
	
	var new_json_string = JSON.stringify(data_received, "\t")
	file.seek(0)
	file.store_string(new_json_string)
	var err := file.resize(file.get_position()) # Truncate manually, because we're open in READ_WRITE not just WRITE
	if err != OK:
		push_error("Error when truncating player status file during v1.1.0 migration: %d" % err)
		# Not much we can do here so just continue and close the file and hope for the best.
	file.close()


static func _get_bool_from_json_dict(dict: Dictionary, path_keys: Array[String], default := false) -> bool:
	var value = _get_variant_from_json_dict(dict, path_keys)
	
	if value is not bool:
		var path := _convert_keys_to_path(path_keys)
		push_error("Could not get value at path \"%s\" from JSON dictionary. If no other errors are displayed, it may be the wrong type." % path)
		return default
	
	return value


static func _get_int_from_json_dict(dict: Dictionary, path_keys: Array[String], default: int = 0) -> int:
	var value = _get_variant_from_json_dict(dict, path_keys)
	
	if (value is not int) and (value is not float):
		var path := _convert_keys_to_path(path_keys)
		push_error("Could not get value at path \"%s\" from JSON dictionary. If no other errors are displayed, it may be the wrong type." % path)
		return default
	
	return value if value is int else int(value)


static func _get_float_from_json_dict(dict: Dictionary, path_keys: Array[String], default: float = 0.0) -> float:
	var value = _get_variant_from_json_dict(dict, path_keys)
	
	if (value is not float) and (value is not int):
		var path := _convert_keys_to_path(path_keys)
		push_error("Could not get value at path \"%s\" from JSON dictionary. If no other errors are displayed, it may be the wrong type." % path)
		return default
	
	return value if value is float else float(value)


static func _get_string_from_json_dict(dict: Dictionary, path_keys: Array[String], default := "") -> String:
	var value = _get_variant_from_json_dict(dict, path_keys)
	
	# Support several conversions
	if (value is not String) and (value is not int) and (value is not float) and (value is not bool):
		var path := _convert_keys_to_path(path_keys)
		push_error("Could not get value at path \"%s\" from JSON dictionary. If no other errors are displayed, it may be the wrong type." % path)
		return default
	
	return value if value is String else str(value)
	


static func _get_variant_from_json_dict(dict: Dictionary, path_keys: Array[String]) -> Variant:
	var tail = func(arr: Array[String]) -> Array[String]: return \
			arr.slice(1, arr.size()) \
					if arr.size() > 1 \
					else []
	var head = func(arr: Array[String]) -> String: return arr[0]
	
	if path_keys.size() == 0:
		return dict
	
	var key = head.callv([path_keys])
	if not dict.has(key):
		push_error("Key \"%s\" missing from JSON dictionary" % key)
		return null
	
	if path_keys.size() == 1:
		return dict[key]
	
	var value = dict[key]
	if value is not Dictionary:
		push_error("Value at key \"%s\" is not a dictionary, so cannot traverse JSON dictionary further." % key)
		return null
	
	return _get_variant_from_json_dict(value, tail.callv([path_keys]))


static func _convert_keys_to_path(keys: Array[String]) -> String:
	return keys.reduce(
			func(accum: String, el: String) -> String:
					return el if accum.is_empty() else accum + "/" + el,
			""
			)
