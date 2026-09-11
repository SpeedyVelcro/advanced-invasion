extends Control

signal back
signal jukebox
signal achievements

@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true
	UIFocusService.enter_focusable_ui($CenterContainer/Panel/VBoxContainer/GridContainer/JukeboxButton)

@warning_ignore("native_method_override") # TODO: rename
func hide():
	visible = false
	UIFocusService.leave_focusable_ui()

func _on_JukeboxButton_pressed():
	emit_signal("jukebox")

func _on_AchievementsButton_pressed():
	emit_signal("achievements")

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
