extends CanvasLayer

# This node keeps track of achievements and achievement progress
# It also displays unlock popups
# To unlock achievements you should call this singleton's methods from other
# scripts e.g. directly from relevant objects, or if you don't want to tie
# achievements to game logic, from a separate achievement watchdog singleton
# you make yourself that keeps an eye on the game state.

export(NodePath) var popup_node_path
onready var popup_node = get_node(popup_node_path)
export(NodePath) var icon_texture_rect_path
onready var icon_texture_rect = get_node(icon_texture_rect_path)
export(NodePath) var title_label_path
onready var title_label = get_node(title_label_path)
export(NodePath) var description_label_path
onready var description_label = get_node(description_label_path)

const SAVE_FILE_PATH = "user://achievements.json"
const ACHIEVEMENT_FOLDER_PATH = "res://AutoLoad/AchievementManager/Achievements"
const DEFAULT_ICON_PATH = "res://Art/Achievement/Secret.png"
const POPUP_SHOW_TIME_SEC = 3.0
var achievements = {}
var achievement_progress = {}
var achievement_unlocked = {}
var popup_showing = false
var popup_queue = [] # Stores achievement ids

signal achievement_synced(achievement_id)

func _ready():
	popup_node.set_visible(false)
	# Load achievement data
	var dir = Directory.new()
	# IMPORTANT NOTE:
	# Directory.dir_exists() DOES NOT WORK ON HTML5 (I should probably make a minimal project at some point and submit this as a bug)
	#if not dir.dir_exists(ACHIEVEMENT_FOLDER_PATH):
	#	push_error("Achievement manager: has invalid ACHIEVEMENT_FOLDER_PATH set. No achievements loaded.")
	if not dir.open(ACHIEVEMENT_FOLDER_PATH) == OK:
		push_error("Achivement manager: error occured while opening folder")
	else:
		dir.list_dir_begin()
		var file = dir.get_next()
		var path
		var loaded_file
		while file != "":
			if not dir.current_is_dir():
				if file.ends_with(".tres"):
					path = ACHIEVEMENT_FOLDER_PATH + "/" + file
					loaded_file = load(path)
					# We check just in case I accidentally threw some other
					# resource in there
					if loaded_file is Achievement:
						achievements[loaded_file.get_id()] = loaded_file
			# Increment
			file = dir.get_next()
	# Load achievement progress from user directory
	load_achievements()

# Save and load
func save_file_exists():
	var file = File.new()
	return file.file_exists(SAVE_FILE_PATH)

func make_save_string():
	var dict = {
		"achievement_unlocked" : achievement_unlocked,
		"achievement_progress" : achievement_progress
	}
	return to_json(dict)

func load_save_string(value):
	# Returns true if successful
	var dict = parse_json(value)
	if typeof(dict) != TYPE_DICTIONARY:
		push_error("Corrupt save data: not recognised as dictionary")
		return false
	safe_set("achievement_unlocked", dict, "achievement_unlocked", TYPE_DICTIONARY)
	safe_set("achievement_progress", dict, "achievement_progress", TYPE_DICTIONARY)
	return true

func save():
	var file = File.new()
	file.open(SAVE_FILE_PATH, File.WRITE)
	file.store_string(make_save_string())
	file.close()

func load_achievements():
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

# Useful functions
func unlock(achievement_id : String):
	set_achievement_unlocked(achievement_id, true)

func add_progress(achievement_id : String, value : float):
	var current = get_achievement_progress(achievement_id)
	set_achievement_progress(achievement_id, current + value)

func sync_achievement(achievement_id : String):
	print("AchievementManager is attempting to sync achievement " + String(achievement_id))
	emit_signal("achievement_synced", achievement_id)

func _queue_popup(achievement_id : String):
	if not popup_showing:
		_show_popup(achievement_id)
	else:
		popup_queue.push_back(achievement_id)

func _show_popup(achievement_id : String, force = false):
	if popup_showing and not force:
		push_error("Achievement manager: Tried to show popup while a popup was already showing")
		return
	# Fill in popup with achievement details
	icon_texture_rect.set_texture(get_achievement_icon(achievement_id))
	title_label.set_text(get_achievement_title(achievement_id))
	description_label.set_text(get_achievement_description(achievement_id))
	# Show popup
	popup_showing = true
	$AnimationPlayer.play("show")

func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"show":
			$Timer.start(POPUP_SHOW_TIME_SEC)
		"hide":
			popup_showing = false
			var next_id = popup_queue.pop_front()
			if next_id != null:
				_show_popup(next_id)

func _on_Timer_timeout():
	$AnimationPlayer.play("hide")

func load_icon(achievement_id : String)->Texture:
	# THIS FUNCTION IS BROKEN
	# DO NOT USE IT
	# USE get_achievement_icon() INSTEAD
	var icon_path = achievements[achievement_id].get_icon_path()
	var load_fail = false
	var icon
	var dir = Directory.new()
	# This is the particular part that's broken.
	# file_exists() always returns false on exported projects
	# MIGHT be due to not exporting *.png but I didn't test this extensively
	# enough to confirm
	if dir.file_exists(icon_path):
		icon = load(icon_path)
	else:
		push_error("Achievement manager: Tried to load non-existent icon " + icon_path)
	if not icon is Texture:
		icon = load(DEFAULT_ICON_PATH)
		push_error("Achievement manager: Resource is not an icon at path " + icon_path)
	return icon

# Getters and setters
func get_achievement_title(achievement_id : String)->String:
	if achievements.has(achievement_id):
		return achievements[achievement_id].get_title()
	else:
		push_error("No such achievement with id " + achievement_id)
		return "Undefined"

func get_achievement_description(achievement_id : String)->String:
	if achievements.has(achievement_id):
		return achievements[achievement_id].get_description()
	else:
		push_error("No such achievement with id " + achievement_id)
		return "Achievement not found."

func get_achievement_icon_path(achievement_id : String)->String:
	if achievements.has(achievement_id):
		return achievements[achievement_id].get_icon_path()
	else:
		push_error("No such achievement with id " + achievement_id)
		return DEFAULT_ICON_PATH

func get_achievement_icon(achievement_id : String)->Resource:
	if achievements.has(achievement_id):
		var tex = load(achievements[achievement_id].get_icon_path())
		if tex is Texture:
			return tex
		else:
			push_error("When loading achievement icon with id " + achievement_id + ", a non-texture was returned.")
			return load(DEFAULT_ICON_PATH)
	else:
		push_error("No such achievement with id " + achievement_id)
		return load(DEFAULT_ICON_PATH)

func is_achievement_target_enabled(achievement_id : String)->bool:
	if achievements.has(achievement_id):
		return achievements[achievement_id].is_target_enabled()
	else:
		push_error("No such achievement with id " + achievement_id)
		return false

func get_achievement_target(achievement_id : String)->float:
	if achievements.has(achievement_id):
		return achievements[achievement_id].get_target()
	else:
		push_error("No such achievement with id " + achievement_id)
		return 0.0

func is_achievement_unlocked(achievement_id : String)->bool:
	if achievement_unlocked.has(achievement_id):
		return achievement_unlocked[achievement_id]
	else:
		return false

func set_achievement_unlocked(achievement_id : String, value : bool):
	var newly_unlocked = value and not is_achievement_unlocked(achievement_id)
	achievement_unlocked[achievement_id] = value
	if newly_unlocked:
		_queue_popup(achievement_id)
		save()
	if value:
		sync_achievement(achievement_id)

func get_achievement_progress(achievement_id : String)-> float:
	if achievement_progress.has(achievement_id):
		return float(achievement_progress[achievement_id])
	else:
		return 0.0

func set_achievement_progress(achievement_id : String, value : float):
	achievement_progress[achievement_id] = value
	if is_achievement_target_enabled(achievement_id):
		if value >= get_achievement_target(achievement_id):
			achievement_progress[achievement_id] = get_achievement_target(achievement_id)
			unlock(achievement_id)
		else:
			# TODO: come up with better solution, probably not great to be
			# saving constantly like this
			save()

func is_achievement_secret(achievement_id : String)->bool:
	if achievements.has(achievement_id):
		return achievements[achievement_id].is_secret()
	else:
		push_error("No such achievement with id " + achievement_id)
		return false

func get_achievement_target_dp(achievement_id : String)->int:
	# decimal places
	if achievements.has(achievement_id):
		return achievements[achievement_id].get_target_decimal_places()
	else:
		push_error("No such achievement with id " + achievement_id)
		return 0

func get_achievement_list():
	return achievements.keys()
