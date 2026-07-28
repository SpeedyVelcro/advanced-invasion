extends Control

signal back


@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true

@warning_ignore("native_method_override") # TODO: rename
func hide():
	visible = false

func _on_BackButton_pressed():
	emit_signal("back")
