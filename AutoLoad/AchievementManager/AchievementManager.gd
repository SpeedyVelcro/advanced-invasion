extends CanvasLayer
## This node keeps track of achievements and achievement progress
## It also displays unlock popups
## To unlock achievements you should call this singleton's methods from other
## scripts e.g. directly from relevant objects, or if you don't want to tie
## achievements to game logic, from a separate achievement watchdog singleton
## you make yourself that keeps an eye on the game state.
##
## @deprecated: Use SV Achievements instead.

@export var popup_node_path: NodePath
@onready var popup_node = get_node(popup_node_path)
@export var icon_texture_rect_path: NodePath
@onready var icon_texture_rect = get_node(icon_texture_rect_path)
@export var title_label_path: NodePath
@onready var title_label = get_node(title_label_path)
@export var description_label_path: NodePath
@onready var description_label = get_node(description_label_path)

## Old signal
##
## @deprecated: No longer emitted as this class is no longer used for achievement syncing. See SV Jukebox.
signal achievement_synced(achievement_id)

func load_save_string(value):
	# Returns true if successful
	var test_json_conv = JSON.new()
	test_json_conv.parse(value)
	var dict = test_json_conv.get_data()
	if typeof(dict) != TYPE_DICTIONARY:
		push_error("Corrupt save data: not recognised as dictionary")
		return false
	safe_set("achievement_unlocked", dict, "achievement_unlocked", TYPE_DICTIONARY)
	safe_set("achievement_progress", dict, "achievement_progress", TYPE_DICTIONARY)
	return true

## Old save method
##
## @deprecated: Use SV Achievements instead.
func save():
	AchievementService.save_progress()

## Old load method
##
## @deprecated: Use SV Achievements instead.
func load_achievements():
	AchievementService.load_progress()

## Old safe get method
##
## @deprecated: Do not use this class.
func safe_set(property : String, dictionary : Dictionary, key : String, type : int):
	# Tries to set property to a value from a dictionary, checking for type.
	# Silently fails if key isn't in dictionary or type is wrong.
	# Set type to one of Variant.Type enum constants
	if key in dictionary:
		var value = dictionary[key]
		# Cast real to int if that's the type given
		# (because parsing json seems to always gives reals not ints)
		if type == TYPE_INT and typeof(value) == TYPE_FLOAT:
			value = int(value)
		if typeof(value) == type:
			set(property, dictionary[key])
		else:
			print("Failed to safely set " + property + " due to incorrect type")
	else:
		print("Failed to safely set " + property + " as " + key + " is missing from dictionary")

## Old unlock method
##
## @deprecated: Use SV Achievements instead.
func unlock(achievement_id : String):
	AchievementService.unlock(achievement_id)

## Old method to add progress to an achievement
##
## @deprecated: Method now does nothing. Use SV Achievements instead.
func add_progress(achievement_id : String, value : float):
	pass # Do nothing. None of the old achievements supported progress anyway.

## Old method to sync an achievement.
##
## @deprecated: Use SV achievements instead.
func sync_achievement(achievement_id : String):
	AchievementService.sync_achievement(achievement_id)

func _on_Timer_timeout():
	$AnimationPlayer.play("hide")


# Getters and setters
## Old achievement title getter
##
## @deprecated: Use SV Achievements instead.
func get_achievement_title(achievement_id : String)->String:
	var achievement := AchievementService.get_achievement(achievement_id)
	return achievement.name if achievement else "Undefined"

## Old achievement description getter
##
## @deprecated: Use SV Achievements instead.
func get_achievement_description(achievement_id : String)->String:
	var achievement := AchievementService.get_achievement(achievement_id)
	return achievement.description if achievement else "Achievement not found."

## Old achievement icon path getter
##
## @deprecated: Use SV Achievements instead.
func get_achievement_icon_path(achievement_id : String)->String:
	var icon := get_achievement_icon(achievement_id)
	return icon.resource_path if icon else "res://Art/Achievement/Secret.png"

## Old achievement icon getter
##
## @deprecated: Use SV Achievements instead.
func get_achievement_icon(achievement_id : String)->Resource:
	var achievement := AchievementService.get_achievement(achievement_id)
	return achievement.icon if achievement else load("res://Art/Achievement/Secret.png")

## Old achievement target enabled getter
##
## @deprecated: Now always returns false as this was never used anyway. Use SV Achievements instead.
func is_achievement_target_enabled(achievement_id : String)->bool:
	return false

## Old achievement target getter
##
## @deprecated: Now always returns 0.0 as this was never used anyway. Use SV Achievements instead.
func get_achievement_target(achievement_id : String)->float:
	return 0.0

## Old achievement unlock status checker
##
## @deprecated: Use SV Achievements instead
func is_achievement_unlocked(achievement_id : String)->bool:
	var achievement := AchievementService.get_achievement(achievement_id)
	return achievement.is_unlocked() if achievement else false

## Old achievement unlock status setter
##
## @deprecated: Use SV Achievements instead.
func set_achievement_unlocked(achievement_id : String, value : bool):
	var achievement := AchievementService.get_achievement(achievement_id)
	if not achievement:
		return
	if value:
		achievement.unlock()
	else:
		achievement.reset_completion()
	AchievementService.save_progress()

## Old achievement progress getter
##
## @deprecated: Now always returns 0.0 as this was never used anyway. Use SV Achievements instead.
func get_achievement_progress(achievement_id : String)-> float:
	return 0.0

## Old achievement progress setter
##
## @deprecated: Now does nothing as this was never used anyway. Use SV Achievements instead.
func set_achievement_progress(achievement_id : String, value : float):
	pass

## Old method to check if an achievement is secret
##
## @deprecated: Use SV Achievements instead
func is_achievement_secret(achievement_id : String)->bool:
	var achievement := AchievementService.get_achievement(achievement_id)
	return (achievement.secret_name or achievement.secret_icon or achievement.secret_description) if achievement else false

## Old method
##
## @deprecated: No idea what this method does, but it was never used because it was to do with progress. Now does just returns 0.
func get_achievement_target_dp(achievement_id : String)->int:
	return 0

## Old achievement list getter
##
## @deprecated: Use SV Achievements
func get_achievement_list():
	return AchievementService.achievements.map(func(a: Achievement): return a.achievement_id)
