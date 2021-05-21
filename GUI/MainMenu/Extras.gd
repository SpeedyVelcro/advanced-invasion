extends Control

signal back
signal jukebox
signal achievements

func show():
	visible = true

func hide():
	visible = false

func _on_JukeboxButton_pressed():
	emit_signal("jukebox")

func _on_AchievementsButton_pressed():
	emit_signal("achievements")

func _on_BackButton_pressed():
	emit_signal("back")
