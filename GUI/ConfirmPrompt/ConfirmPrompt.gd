extends Control

export(NodePath) var time_label_path
onready var time_label = get_node(time_label_path)
export var time_limit = 10.0

signal yes
signal no

func _ready():
	set_process(false)

func show():
	visible = true
	$Timer.start(time_limit)
	set_process(true)

func hide():
	visible = false
	set_process(false)
	$Timer.stop()

func _process(_delta):
	var time = $Timer.get_time_left()
	var time_string = String(ceil(time)).pad_decimals(0)
	time_label.set_text(time_string)

func _on_YesButton_pressed():
	emit_signal("yes")
	hide()

func _on_NoButton_pressed():
	emit_signal("no")
	hide()

func _on_Timer_timeout():
	emit_signal("no")
	hide()
