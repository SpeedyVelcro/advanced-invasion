extends Node
## Service for managing UI focus state
##
## Tracks the current "start" control (the control that you start on if you
## start navigating using the keyboard or a controller) and automatically
## focuses it when controller/keyboard input is detected.

const _FOCUSING_ACTIONS: Array[String] = [
	"ui_accept",
	"ui_select",
	"ui_cancel",
	"ui_focus_next",
	"ui_focus_prev",
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down"
]

const _MOUSE_SPEED_THRESHOLD := 16.0

## Releasing focus does not seem to get rid of the focus stylebox overlay (last
## checked in Godot 4.7.2). This control can be used as a workaround by grabbing
## focus to this invisible node first, before releasing focus.
var _focus_stealer: Control

var _using_button_navigation := false:
	set(value):
		_using_button_navigation = value
		_update_focus()
	get:
		return _using_button_navigation

var _start_control: Control = null:
	set(value):
		_start_control = value
		_update_focus()
	get:
		return _start_control

# Override
func _ready() -> void:
	_focus_stealer = Control.new()
	add_child(_focus_stealer)
	_focus_stealer.visible = false
	_focus_stealer.focus_mode = Control.FOCUS_ALL
	# UIs may be unpaused (as in the main menu) or paused (as in the pause menu)
	# so we need to handle both:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Start monitoring for whether focus should be grabbed for the given start
## control. This replaces any previous start control.
func enter_focusable_ui(start_control: Control) -> void:
	_start_control = start_control


## Stop monitoring to see if focus should be grabbed.
func leave_focusable_ui() -> void:
	_start_control = null


func _update_focus() -> void:
	# TODO
	if is_instance_valid(_start_control) and _using_button_navigation:
		if is_instance_valid(get_viewport().gui_get_focus_owner()):
			return # Already focused
		_start_control.grab_focus()
	else:
		_focus_stealer.grab_focus()
		get_viewport().gui_release_focus()


# Override
func _input(event: InputEvent) -> void:
	if not is_instance_valid(_start_control):
		# We only determine navigation if there is a focusable UI displayed,
		# because buttons being pressed during normal gameplay doesn't necessarily
		# mean the player wants to use buttons to navigate the UI.
		return
	
	if _using_button_navigation:
		if event is InputEventMouseButton:
			_using_button_navigation = false
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseMotion:
			if event.screen_velocity.length() >= _MOUSE_SPEED_THRESHOLD:
				_using_button_navigation = false
				# Don't think there's any need to handle a mouse motion.
	else:
		if _is_ui_input_event_pressed(event):
			_using_button_navigation = true
			get_viewport().set_input_as_handled()
			return


func _is_ui_input_event_pressed(event: InputEvent) -> bool:
	const EXACT_MATCH := false
	for action in _FOCUSING_ACTIONS:
		if event.is_action_pressed(action, EXACT_MATCH):
			return true
	return false
