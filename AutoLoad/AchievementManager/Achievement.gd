class_name Achievement
extends Resource

export(String) var icon_path
export(String) var id
export(String) var title
export(String, MULTILINE) var description
export(bool) var target_enabled
export(float) var target
export(bool) var secret
export(int) var target_decimal_places

# Getters and setters
func get_id()->String:
	return id

func set_id(value : String):
	id = value

func get_icon_path()->String:
	return icon_path

func set_icon_path(value : String):
	icon_path = value

func get_title()->String:
	return title

func set_title(value : String):
	title = value

func get_description()->String:
	return description

func set_description(value : String):
	description = value

func is_target_enabled()->bool:
	return target_enabled

func set_target_enabled(value : bool):
	target_enabled = value

func get_target()->float:
	return target

func set_target(value : float):
	target = value

func is_secret()->bool:
	return secret

func set_secret(value : bool):
	secret = value

func get_target_decimal_places()->int:
	return target_decimal_places

func set_target_decimal_places(value : int):
	target_decimal_places = value
