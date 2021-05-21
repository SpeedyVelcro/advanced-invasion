# Dialogue

class_name Dialogue
extends Resource

export(String) var character_name = ""
export(String) var character_color_id = ""
export(String, MULTILINE) var bbcode = ""
export(bool) var ignore_input = false
export(bool) var auto_advance = false
export(float) var pause_sec = 0
export(bool) var broadcast_enabled = false
export(String) var broadcast_message = ""

func _init(p_character_name = "", p_bbcode = "", p_character_color_id = "", p_ignore_input = true, p_auto_advance = false, p_pause_sec = -1):
	character_name = p_character_name
	character_color_id = p_character_color_id
	bbcode = p_bbcode
	ignore_input = p_ignore_input
	auto_advance = p_auto_advance
	pause_sec = p_pause_sec
