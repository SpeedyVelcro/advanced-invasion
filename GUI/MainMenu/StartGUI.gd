extends Control

export(NodePath) var load_button_path
onready var load_button = get_node(load_button_path)

var locked = false

signal new_game
signal load_game
signal extras
signal options
signal about
signal quit

func _ready():
	load_button.set_disabled(not StoryStatus.save_file_exists())

func _on_NewGame_pressed():
	if not locked:
		emit_signal("new_game")

func _on_Load_pressed():
	if not locked:
		emit_signal("load_game")

func _on_Extras_pressed():
	if not locked:
		emit_signal("extras")

func _on_Options_pressed():
	if not locked:
		emit_signal("options")

func _on_About_pressed():
	if not locked:
		emit_signal("about")

func _on_Quit_pressed():
	if not locked:
		emit_signal("quit")

func show(animate = false):
	if animate:
		$AnimationPlayer.play("show")
	else:
		visible = true
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		locked = false

func hide(animate = false):
	locked = true
	if animate:
		$AnimationPlayer.play("hide")
	else:
		visible = false
		modulate = Color(1.0, 1.0, 1.0, 0.0)


func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"show":
			locked = false

# Getters and setters
func set_locked(value : bool):
	locked = value

func is_locked():
	return locked
