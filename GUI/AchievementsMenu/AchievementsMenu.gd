extends Control

@onready var achievement_list_ui: Control = $CenterContainer/Panel/VBoxContainer/ScrollContainer/AchievementListUI

signal back

@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true
	UIFocusService.enter_focusable_ui(achievement_list_ui.get_first_achievement_control())

@warning_ignore("native_method_override") # TODO: rename
func hide():
	visible = false
	UIFocusService.leave_focusable_ui()

func _on_BackButton_pressed():
	go_back()


func go_back() -> void:
	emit_signal("back")


# Override
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action("ui_cancel"):
		go_back()
		get_viewport().set_input_as_handled()
