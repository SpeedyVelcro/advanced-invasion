# PlayerStatus.gd

extends Node

var current_level = ""
var lives_enabled = false
var difficulty_id = 1 # 0 is casual, 1 is normal
var lowest_difficulty_id = 1
const SAVE_FILE_PATH = "user://player-status.json"

func _ready():
	$CanvasLayer/ColorRect.set_visible(false)

func reset():
	current_level = ""
	lives_enabled = false
	difficulty_id = 1 # Normal
	lowest_difficulty_id = 1

# Save and load
func save_file_exists():
	var file = File.new()
	return file.file_exists(SAVE_FILE_PATH)

func make_save_string():
	var dict = {
		"lives_enabled" : lives_enabled,
		"current_level" : current_level,
		"difficulty_id" : difficulty_id
	}
	return to_json(dict)

func load_save_string(value):
	# Returns true if successful
	var dict = parse_json(value)
	if typeof(dict) != TYPE_DICTIONARY:
		push_error("Corrupt save data: not recognised as dictionary")
		return false
	reset()
	safe_set("lives_enabled", dict, "lives_enabled", TYPE_BOOL)
	safe_set("current_level", dict, "current_level", TYPE_STRING)
	safe_set("difficulty_id", dict, "difficulty_id", TYPE_REAL)
	return true

func save():
	var file = File.new()
	file.open(SAVE_FILE_PATH, File.WRITE)
	file.store_string(make_save_string())
	file.close()

func load_game():
	$AnimationPlayer.play("fade_out_load")

func _load_black_out():
	var file = File.new()
	if not file.file_exists(SAVE_FILE_PATH):
		return false
	file.open(SAVE_FILE_PATH, File.READ)
	var result = load_save_string(file.get_as_text())
	if result:
		SceneTransition.fade(current_level, 0.0, 0.5)

func save_exists():
	var file = File.new()
	return file.file_exists(SAVE_FILE_PATH)

func safe_set(property : String, dictionary : Dictionary, key : String, type : int):
	# Tries to set property to a value from a dictionary, checking for type.
	# Silently fails if key isn't in dictionary or type is wrong.
	# Set type to one of Variant.Type enum constants
	if key in dictionary:
		var value = dictionary[key]
		# Cast real to int if that's the type given
		# (because parsing json seems to always gives reals not ints)
		if type == TYPE_INT and typeof(value) == TYPE_REAL:
			value = int(value)
		if typeof(value) == type:
			set(property, dictionary[key])
		else:
			print("Failed to safely set " + property + " due to incorrect type")
	else:
		print("Failed to safely set " + property + " as " + key + " is missing from dictionary")

func change_difficulty(id : int, override_lowest = false):
	if id < 0 or id > 1:
		print("Tried changing to invalid difficulty " + String(id) + ". Changing to default of 1 instead.")
		change_difficulty(1, override_lowest)
		return
	difficulty_id = id
	if (difficulty_id < lowest_difficulty_id or override_lowest):
		lowest_difficulty_id = difficulty_id
	match(id):
		0: # Casual
			lives_enabled = true
		1: # Normal
			lives_enabled = false

# Getters and setters
func get_lives_enabled():
	return lives_enabled

func set_lives_enabled(value):
	lives_enabled = value

func get_current_level():
	return current_level

func set_current_level(value):
	current_level = value

func get_difficulty_id():
	return difficulty_id

func get_lowest_difficulty_id():
	return lowest_difficulty_id
