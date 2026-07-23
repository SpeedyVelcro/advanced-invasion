extends Control

@export var active := false

func _ready():
	if hidden:
		hide_prompt()
	else:
		show_prompt()

func hide_prompt():
	active = true
	$AnimationPlayer.play("hide")

func show_prompt():
	active = false
	$Timer.start(1.5)

func _on_Timer_timeout():
	if not active:
		$AnimationPlayer.play("pulse")
