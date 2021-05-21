extends Node

var soundtrack_unlocked = {
	"militia" : true
}
var story_completion = false setget set_story_completion, is_story_complete
var story_normal_completion = false setget set_story_normal_completion, is_story_normal_complete
var main_menu_visited = false setget set_main_menu_visited, is_main_menu_visited
const SAVE_FILE_PATH = "user://game-status.json"

signal story_complete
signal story_normal_complete

func _ready():
	var result = load_game()
	if not result:
		print("Game status didn't load. This is probably fine if game is being launched for the first time.")

# Save and load
func save_file_exists():
	var file = File.new()
	return file.file_exists(SAVE_FILE_PATH)

func make_save_string():
	var dict = {
		"story_completion" : story_completion,
		"story_normal_completion" : story_normal_completion,
		"soundtrack_unlocked" : soundtrack_unlocked
	}
	return to_json(dict)

func load_save_string(value):
	# Returns true if successful
	var dict = parse_json(value)
	if typeof(dict) != TYPE_DICTIONARY:
		push_error("Corrupt save data: not recognised as dictionary")
		return false
	safe_set("soundtrack_unlocked", dict, "soundtrack_unlocked", TYPE_DICTIONARY)
	safe_set("story_completion", dict, "story_completion", TYPE_BOOL)
	safe_set("story_normal_completion", dict, "story_normal_completion", TYPE_BOOL)
	return true

func save():
	var file = File.new()
	file.open(SAVE_FILE_PATH, File.WRITE)
	file.store_string(make_save_string())
	file.close()

func load_game():
	var file = File.new()
	if not file.file_exists(SAVE_FILE_PATH):
		return false
	file.open(SAVE_FILE_PATH, File.READ)
	var result = load_save_string(file.get_as_text())
	if not result:
		push_error("Failed to load game data")
	else:
		return true

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

# Getters and setters:

func set_soundtrack_unlocked(name : String, value : bool):
	soundtrack_unlocked[name] = value

func is_soundtrack_unlocked(name : String):
	if soundtrack_unlocked.has(name):
		return soundtrack_unlocked[name]
	else:
		return false

func set_story_completion(value : bool):
	story_completion = value
	if value:
		emit_signal("story_complete")

func is_story_complete():
	return story_completion

func set_story_normal_completion(value : bool):
	story_normal_completion = value
	if value:
		emit_signal("story_normal_complete")

func is_story_normal_complete():
	return story_normal_completion

func set_main_menu_visited(value : bool):
	main_menu_visited = value

func is_main_menu_visited()->bool:
	return main_menu_visited
