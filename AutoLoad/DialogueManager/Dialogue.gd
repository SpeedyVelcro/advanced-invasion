# Dialogue

class_name Dialogue
extends Resource

@export var character_name: String = ""
@export var character_color_id: String = ""
@export var bbcode = "" # (String, MULTILINE)
@export var ignore_input: bool = false
@export var auto_advance: bool = false
@export var pause_sec: float = 0
@export var broadcast_enabled: bool = false
@export var broadcast_message: String = ""

func _init(p_character_name = "", p_bbcode = "", p_character_color_id = "", p_ignore_input = false, p_auto_advance = false, p_pause_sec = 0):
	character_name = p_character_name
	character_color_id = p_character_color_id
	bbcode = p_bbcode
	ignore_input = p_ignore_input
	auto_advance = p_auto_advance
	pause_sec = p_pause_sec
