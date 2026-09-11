extends Control

@onready var yes_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/YesButton

signal back

@warning_ignore("native_method_override") # TODO: rename
func show():
	set_visible(true)
	UIFocusService.enter_focusable_ui(yes_button)

@warning_ignore("native_method_override") # TODO: rename
func hide():
	set_visible(false)
	UIFocusService.leave_focusable_ui()

func _on_YesButton_pressed():
	NewgroundsIntegration.set_integration_enabled(true)
	go_back()

func _on_NoButton_pressed():
	NewgroundsIntegration.set_integration_enabled(false)
	go_back()


func go_back() -> void:
	emit_signal("back")


# Override
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action("ui_cancel"):
		go_back()
