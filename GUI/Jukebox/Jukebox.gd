extends Control

@onready var play_all_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/PlayAllButton

signal back

@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true
	# TODO: some way to go back to album liner notes without returning to menu. Might want an upstream SVJukebox change for a button to do this.
	$SVJukeboxUIController.deselect_track() # To show main album liner notes
	UIFocusService.enter_focusable_ui(play_all_button)
	

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
