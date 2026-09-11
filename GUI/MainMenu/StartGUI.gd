extends Control

@onready var load_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Load
@onready var new_game_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/NewGame

var locked = false

signal new_game
signal load_game
signal achievements
signal jukebox
signal options
signal about
signal quit

func _ready():
	load_button.set_disabled(not StoryStatus.save_file_exists())
	set_process_input(true)

func _on_NewGame_pressed():
	if not locked:
		emit_signal("new_game")

func _on_Load_pressed():
	if not locked:
		emit_signal("load_game")

func _on_Options_pressed():
	if not locked:
		emit_signal("options")

func _on_About_pressed():
	if not locked:
		emit_signal("about")

func _on_Quit_pressed():
	if not locked:
		emit_signal("quit")

@warning_ignore("native_method_override") # TODO: rename
func show(animate = false):
	if animate:
		$AnimationPlayer.play("show")
	else:
		visible = true
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		locked = false
	
	UIFocusService.enter_focusable_ui(new_game_button if load_button.disabled else load_button)

@warning_ignore("native_method_override") # TODO: rename
func hide(animate = false):
	locked = true
	if animate:
		$AnimationPlayer.play("hide")
	else:
		visible = false
		modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	UIFocusService.leave_focusable_ui()


func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"show":
			locked = false


# Getters and setters
func set_locked(value : bool):
	locked = value

func is_locked():
	return locked


func _on_achievements_pressed() -> void:
	achievements.emit()


func _on_jukebox_pressed() -> void:
	jukebox.emit()


func _on_website_button_pressed() -> void:
	OS.shell_open("https://speedyvelcro.com")


func _on_x_button_pressed() -> void:
	OS.shell_open("https://x.com/SpeedyVelcro")


func _on_blue_sky_button_pressed() -> void:
	OS.shell_open("https://bsky.app/profile/speedyvelcro.bsky.social")


func _on_mastodon_button_pressed() -> void:
	OS.shell_open("https://mastodon.social/@SpeedyVelcro")


func _on_instagram_button_pressed() -> void:
	OS.shell_open("https://www.instagram.com/speedyvelcro")


func _on_threads_button_pressed() -> void:
	OS.shell_open("https://www.threads.com/@speedyvelcro")


func _on_tumblr_button_pressed() -> void:
	OS.shell_open("https://www.tumblr.com/speedyvelcro")


func _on_youtube_button_pressed() -> void:
	OS.shell_open("https://www.youtube.com/channel/UCYLhMt9H_Y7x1b0BGkkXJiA")
