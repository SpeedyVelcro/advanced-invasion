extends Control

signal back
signal jukebox
signal achievements

@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true

@warning_ignore("native_method_override") # TODO: rename
func hide():
	visible = false

func _on_JukeboxButton_pressed():
	emit_signal("jukebox")

func _on_AchievementsButton_pressed():
	emit_signal("achievements")

func _on_BackButton_pressed():
	emit_signal("back")
