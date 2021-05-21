extends Node

onready var viewport = get_tree().get_root()
var previously_fullscreen = OS.is_window_fullscreen()

const SAVE_FILE_PATH = "user://options.json"

func _ready():
	var result = load_options()
	if not result:
		print("Options didn't load. This is probably fine if game is being launched for the first time.")

func set_display(resolution : Vector2, fullscreen : bool, vsync : bool):
	# Canvas has fixed size on browser so only allow resolution change in fullscreen
	if OS.get_name() == "HTML5":
		if not fullscreen:
			resolution = Vector2(1280, 720)
	# Why it's done like this: set_window_size resizes viewport back to what it
	# was previously on the next frame if stretch mode is set to viewport
	# (This might be a bug in Godot?)
	if OS.get_name() != "HTML5":
		get_tree().set_screen_stretch(get_tree().STRETCH_MODE_DISABLED, get_tree().STRETCH_ASPECT_KEEP, resolution)
		viewport.set_size(resolution)
		OS.set_window_size(resolution)
		OS.center_window()
		get_tree().set_screen_stretch(get_tree().STRETCH_MODE_VIEWPORT, get_tree().STRETCH_ASPECT_KEEP, resolution)
		OS.set_window_fullscreen(fullscreen)
		OS.set_use_vsync(vsync)
	else:
		get_tree().set_screen_stretch(get_tree().STRETCH_MODE_DISABLED, get_tree().STRETCH_ASPECT_KEEP, resolution)
		OS.set_window_fullscreen(fullscreen)
		viewport.set_size(resolution)
		get_tree().set_screen_stretch(get_tree().STRETCH_MODE_VIEWPORT, get_tree().STRETCH_ASPECT_KEEP, resolution)

func _process(_delta):
	# On browser, if we've gone back to windowed mode resolution needs to be reverted to 720p
	# If there's a signal to check this, that would be better
	if OS.get_name() == "HTML5":
		if previously_fullscreen:
			if not OS.is_window_fullscreen():
				set_display(Vector2(1280, 720), false, OS.is_vsync_enabled())
		previously_fullscreen = OS.is_window_fullscreen()

# Save and load
func save_file_exists():
	var file = File.new()
	return file.file_exists(SAVE_FILE_PATH)

func make_save_string():
	var bus_master_index = AudioServer.get_bus_index("Master")
	var bus_music_index = AudioServer.get_bus_index("Music")
	var bus_effects_index = AudioServer.get_bus_index("Effects")
	var bus_ui_index = AudioServer.get_bus_index("UI")
	var dict = {
		"video" :
			{
				# Display
				"resolution_x" : viewport.get_size().x,
				"resolution_y" : viewport.get_size().y,
				"fullscreen" : OS.is_window_fullscreen(),
				"vsync" : OS.is_vsync_enabled()
			},
		"audio" :
			{
				# Volume
				# Must be linear, as db can be -infinity, which can cause errors with JSON file
				"volume_db_master" : db2linear(AudioServer.get_bus_volume_db(bus_master_index)),
				"volume_db_music" : db2linear(AudioServer.get_bus_volume_db(bus_music_index)),
				"volume_db_effects" : db2linear(AudioServer.get_bus_volume_db(bus_effects_index)),
				"volume_db_ui" : db2linear(AudioServer.get_bus_volume_db(bus_ui_index)),
				# Mute
				"mute_master" : AudioServer.is_bus_mute(bus_master_index),
				"mute_music" : AudioServer.is_bus_mute(bus_music_index),
				"mute_effects" : AudioServer.is_bus_mute(bus_effects_index),
				"mute_ui" : AudioServer.is_bus_mute(bus_ui_index)
			}
	}
	return JSON.print(dict, "\t")

func load_save_string(value):
	# Returns true if successful
	var json_result = JSON.parse(value)
	if json_result.error != OK:
		push_error("Options file: failed to parse JSON with error " + json_result.error_string + " on line " + String(json_result.error_line))
		return false
	var dict = json_result.result
	if typeof(dict) != TYPE_DICTIONARY:
		push_error("Corrupt options save data: not recognised as dictionary")
		return false
	
	# Video settings
	if dict_check(dict, "video", TYPE_DICTIONARY):
		var dict_video = dict["video"]
		# Display settings
		if OS.get_name() != "HTML5":
			var res = viewport.get_size()
			var fullscreen = OS.is_window_fullscreen()
			var vsync = OS.is_vsync_enabled()
			if dict_check(dict_video, "resolution_x", TYPE_INT) and dict_check(dict_video, "resolution_y", TYPE_INT):
				res = Vector2(dict_video["resolution_x"], dict_video["resolution_y"])
			if dict_check(dict_video, "fullscreen", TYPE_BOOL):
				fullscreen = dict_video["fullscreen"]
			if dict_check(dict_video, "vsync", TYPE_BOOL):
				vsync = dict_video["vsync"]
			set_display(res, fullscreen, vsync)
	
	# Audio settings
	var bus_master_index = AudioServer.get_bus_index("Master")
	var bus_music_index = AudioServer.get_bus_index("Music")
	var bus_effects_index = AudioServer.get_bus_index("Effects")
	var bus_ui_index = AudioServer.get_bus_index("UI")
	if dict_check(dict, "audio", TYPE_DICTIONARY):
		var dict_audio = dict["audio"]
		# Volume
		if dict_check(dict_audio, "volume_db_master", TYPE_REAL):
			AudioServer.set_bus_volume_db(bus_master_index, linear2db(dict_audio["volume_db_master"]))
		if dict_check(dict_audio, "volume_db_music", TYPE_REAL):
			AudioServer.set_bus_volume_db(bus_music_index, linear2db(dict_audio["volume_db_music"]))
		if dict_check(dict_audio, "volume_db_effects", TYPE_REAL):
			AudioServer.set_bus_volume_db(bus_effects_index, linear2db(dict_audio["volume_db_effects"]))
		if dict_check(dict_audio, "volume_db_ui", TYPE_REAL):
			AudioServer.set_bus_volume_db(bus_ui_index, linear2db(dict_audio["volume_db_ui"]))
		# Mute
		if dict_check(dict_audio, "mute_master", TYPE_BOOL):
			AudioServer.set_bus_mute(bus_master_index, dict_audio["mute_master"])
		if dict_check(dict_audio, "mute_music", TYPE_BOOL):
			AudioServer.set_bus_mute(bus_music_index, dict_audio["mute_music"])
		if dict_check(dict_audio, "mute_effects", TYPE_BOOL):
			AudioServer.set_bus_mute(bus_effects_index, dict_audio["mute_effects"])
		if dict_check(dict_audio, "mute_ui", TYPE_BOOL):
			AudioServer.set_bus_mute(bus_ui_index, dict_audio["mute_ui"])
	
	return true

func save():
	var file = File.new()
	file.open(SAVE_FILE_PATH, File.WRITE)
	file.store_string(make_save_string())
	file.close()

func load_options():
	var file = File.new()
	if not file.file_exists(SAVE_FILE_PATH):
		return false
	file.open(SAVE_FILE_PATH, File.READ)
	var result = load_save_string(file.get_as_text())
	if not result:
		push_error("Failed to load options data")
	else:
		return true

func dict_check(dict : Dictionary, key : String, type : int, exact_type = false)->bool:
	if dict.has(key):
		var value_type = typeof(dict[key])
		if (not exact_type) and (type == TYPE_INT or type == TYPE_REAL):
			return value_type == TYPE_INT or value_type == TYPE_REAL
		else:
			return value_type == type
	else:
		return false

func _on_OptionsManager_tree_exiting():
	save()
