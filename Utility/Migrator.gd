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
	migrate_options_to_sv_options()


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
	
	new_file.store_string(json_string)
	new_file.close()
	
	DirAccess.remove_absolute(OLD_FILENAME)


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
