extends Node

export(NodePath) var gui_path
onready var gui = get_node(gui_path)
export(NodePath) var color_rect_path
onready var color_rect = get_node(color_rect_path)
export(NodePath) var restart_button_path
onready var restart_button = get_node(restart_button_path)
export(NodePath) var skip_cutscene_button_path
onready var skip_cutscene_button = get_node(skip_cutscene_button_path)
export(NodePath) var options_path
onready var options = get_node(options_path)

var in_a_deeper_menu = false
var pause_enabled = true

const MAIN_MENU = "res://GUI/MainMenu/MainMenu.tscn"

signal restart
signal skip_cutscene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not in_a_deeper_menu:
		toggle_pause()

func toggle_pause():
	if get_tree().is_paused():
		unpause()
	elif pause_enabled:
		pause()

func pause():
	print("Game paused")
	get_tree().set_pause(true)
	gui.set_visible(true)
	color_rect.set_visible(true)

func unpause():
	print("Game unpaused")
	get_tree().set_pause(false)
	gui.set_visible(false)
	color_rect.set_visible(false)

func _on_Resume_pressed():
	unpause()

func _on_Restart_pressed():
	unpause()
	emit_signal("restart")

func _on_SkipCutscene_pressed():
	unpause()
	emit_signal("skip_cutscene")

func _on_Options_pressed():
	in_a_deeper_menu = true
	gui.set_visible(false)
	options.show()

func _on_Quit_pressed():
	unpause()
	GlobalMusic.stop(0.5)
	SceneTransition.fade(MAIN_MENU)

func set_cutscene_mode(value):
	restart_button.set_visible(not value)
	skip_cutscene_button.set_visible(value)

func _on_Options_back():
	in_a_deeper_menu = false
	gui.set_visible(true)
	options.hide()

# Getters and setters
func set_pause_enabled(value):
	pause_enabled = value

func is_pause_enabled():
	return pause_enabled
