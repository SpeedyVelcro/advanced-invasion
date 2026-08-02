extends Control

signal back

@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true
	# TODO: some way to go back to album liner notes without returning to menu. Might want an upstream SVJukebox change for a button to do this.
	$SVJukeboxUIController.deselect_track() # To show main album liner notes

@warning_ignore("native_method_override") # TODO: rename
func hide():
	visible = false

func _on_BackButton_pressed():
	emit_signal("back")
