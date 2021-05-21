extends HBoxContainer

const PREFIX = "Disc "
onready var label = $Label

func set_disc_number(number : int):
	label.set_text(PREFIX + String(number))
