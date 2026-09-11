extends Node

@export var gui_path: NodePath
@onready var gui = get_node(gui_path)
@export var color_rect_path: NodePath
@onready var color_rect = get_node(color_rect_path)
@onready var resume_button: Button = $CanvasLayer/SubViewportContainer/UIScalingSubViewport/PauseMenuGUI/CenterContainer/MainPanelContainer/VBoxContainer/Resume
@export var restart_button_path: NodePath
@onready var restart_button = get_node(restart_button_path)
@export var skip_cutscene_button_path: NodePath
@onready var skip_cutscene_button = get_node(skip_cutscene_button_path)
@onready var options_button: Button = $CanvasLayer/SubViewportContainer/UIScalingSubViewport/PauseMenuGUI/CenterContainer/MainPanelContainer/VBoxContainer/HBoxContainer2/Options
@onready var achievements_button: Button = $CanvasLayer/SubViewportContainer/UIScalingSubViewport/PauseMenuGUI/CenterContainer/MainPanelContainer/VBoxContainer/HBoxContainer2/Achievements
@export var options_path: NodePath
@onready var options = get_node(options_path)
@export var achievements_menu: Control

var in_a_deeper_menu = false
var pause_enabled = true

const MAIN_MENU = "res://GUI/MainMenu/MainMenu.tscn"

signal restart
signal skip_cutscene


# Override
func _ready() -> void:
	set_process_input(true)


# Override
func _input(event: InputEvent) -> void:
	if in_a_deeper_menu:
		return
	
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()


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
	UIFocusService.enter_focusable_ui(resume_button)

func unpause():
	print("Game unpaused")
	get_tree().set_pause(false)
	gui.set_visible(false)
	color_rect.set_visible(false)
	UIFocusService.leave_focusable_ui()

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
	UIFocusService.leave_focusable_ui()
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
	UIFocusService.enter_focusable_ui(options_button)

# Getters and setters
func set_pause_enabled(value):
	pause_enabled = value

func is_pause_enabled():
	return pause_enabled


func _on_Achievements_pressed() -> void:
	in_a_deeper_menu = true
	gui.set_visible(false)
	UIFocusService.leave_focusable_ui()
	achievements_menu.show()


func _on_achievements_menu_back() -> void:
	in_a_deeper_menu = false
	gui.set_visible(true)
	achievements_menu.hide()
	UIFocusService.enter_focusable_ui(achievements_button)
