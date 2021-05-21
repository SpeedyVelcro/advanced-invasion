extends Control

onready var animation_player = $AnimationPlayer
onready var newgrounds_menu = $NewgroundsMenu
onready var game_jolt_menu = $GameJoltMenu

signal back

func _ready():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	set_visible(false)

func show(instant = true):
	# Visual stuff
	set_visible(true)
	animation_player.play("fade_in")
	if not instant:
		animation_player.seek(0.0, true)
	else:
		animation_player.seek(animation_player.get_current_animation_length(), true)
	
	# Chose which integration menu to show
	if OS.has_feature("newgrounds"):
		newgrounds_menu.show()
	elif OS.has_feature("gamejolt"):
		game_jolt_menu.show()
	else:
		push_error("Tried to show integration menu when OS has no integration features.")

func hide(instant = true):
	if instant:
		set_visible(false)
	else:
		animation_player.play("fade_out")

func _on_NewgroundsMenu_back():
	newgrounds_menu.hide()
	emit_signal("back")

func _on_GameJoltMenu_back():
	game_jolt_menu.hide()
	emit_signal("back")
