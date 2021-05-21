extends Control

signal back

func show():
	set_visible(true)

func hide():
	set_visible(false)

func _on_YesButton_pressed():
	NewgroundsIntegration.set_integration_enabled(true)
	emit_signal("back")

func _on_NoButton_pressed():
	NewgroundsIntegration.set_integration_enabled(false)
	emit_signal("back")
