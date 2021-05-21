extends Control

export var hidden = false

func _ready():
	if hidden:
		hide()
	else:
		show()

func hide():
	hidden = true
	$AnimationPlayer.play("hide")

func show():
	hidden = false
	$Timer.start(1.5)

func _on_Timer_timeout():
	if not hidden:
		$AnimationPlayer.play("pulse")
