extends Control

onready var textures = [
	get_node("Panel/HBoxContainer/TextureRect"),
	get_node("Panel/HBoxContainer/TextureRect2"),
	get_node("Panel/HBoxContainer/TextureRect3")
]
var currently_showing = true

func update_lives(value):
	for i in range(textures.size()):
		textures[i].set_visible(i < value)

func show(instant = false):
	$AnimationPlayer.play("show")
	if instant or currently_showing:
		$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)
	currently_showing = true

func hide(instant = false):
	$AnimationPlayer.play("hide")
	if instant or not currently_showing:
		$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)
	currently_showing = false
