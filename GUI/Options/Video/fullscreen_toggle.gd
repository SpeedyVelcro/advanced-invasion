extends HBoxContainer
## This toggle is only available on web, so its window mode logic is simplified
## and does not save the setting.


func _on_button_pressed() -> void:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_WINDOWED, \
		DisplayServer.WINDOW_MODE_MINIMIZED, \
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
