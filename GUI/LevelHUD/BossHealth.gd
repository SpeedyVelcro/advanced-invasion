extends Control

onready var animation_player = $AnimationPlayer
onready var progress_bar = $ProgressBar
var currently_showing = false

func _ready():
	visible = false

func update_health(health : float, max_health : float):
	var val = health / max_health
	progress_bar.set_value(val)

func show(instant = false):
	var previous_value = progress_bar.get_value()
	animation_player.play("show")
	if instant or currently_showing:
		animation_player.seek(animation_player.get_current_animation_length(), true)
	if currently_showing:
		# Preserve previous value
		progress_bar.set_value(previous_value)
	currently_showing = true

func hide(instant = false):
	animation_player.play("hide")
	if instant or not currently_showing:
		animation_player.seek(animation_player.get_current_animation_length(), true)
	currently_showing = false
