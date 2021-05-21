extends Control

export(NodePath) var rich_label_path
onready var rich_label = get_node(rich_label_path)
var credits_file = "res://About/Credits.txt"
var ofl11_file = "res://About/OFL11.txt"
var hack_file = "res://About/Hack.txt"
var apache20_file = "res://About/Apache20.txt"
var mit_file = "res://About/MIT.txt"

signal back

func _ready():
	display_text_file(credits_file)

func _on_CreditsButton_pressed():
	display_text_file(credits_file)

func _on_OFL11Button_pressed():
	display_text_file(ofl11_file)

func _on_HackButton_pressed():
	display_text_file(hack_file)

func _on_Apache20Button_pressed():
	display_text_file(apache20_file)

func _on_MITButton_pressed():
	display_text_file(mit_file)

func display_text_file(file_path):
	var file = File.new()
	file.open(file_path, File.READ)
	var credits_text = ""
	while true:
		credits_text += file.get_line()
		if file.eof_reached():
			break
		else:
			credits_text += "\n"
	file.close()
	rich_label.set_bbcode(credits_text)
	rich_label.get_v_scroll().set_value(0.0)

func show():
	visible = true
	display_text_file(credits_file)

func hide():
	visible = false

func _on_BackButton_pressed():
	emit_signal("back")
