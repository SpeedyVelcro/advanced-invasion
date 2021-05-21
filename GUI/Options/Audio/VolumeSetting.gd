extends HBoxContainer

export(NodePath) var slider_path
onready var slider = get_node(slider_path)
export(NodePath) var mute_button_path
onready var mute_button = get_node(mute_button_path)
export(NodePath) var title_label_path
onready var title_label = get_node(title_label_path)
export(NodePath) var percent_label_path
onready var percent_label = get_node(percent_label_path)
export(String) var title = "Master"
export(String) var bus_name = "Master"

onready var bus_index = AudioServer.get_bus_index(bus_name)

func _ready():
	var vol_linear = clamp(db2linear(AudioServer.get_bus_volume_db(bus_index)), 0.0, 1.0)
	var mute = AudioServer.is_bus_mute(bus_index)
	mute_button.set_pressed(mute)
	slider.set_value(vol_linear) # Sets label by signal
	# Slider does not move if loaded value is 0%, as slider was already there.
	# So function is called manually just in case signal doesn't go off
	_on_HSlider_value_changed(vol_linear)
	title_label.set_text(title)

func _on_MuteButton_toggled(button_pressed):
	AudioServer.set_bus_mute(bus_index, button_pressed)

func _on_HSlider_value_changed(value):
	var vol_linear = value / slider.get_max()
	AudioServer.set_bus_volume_db(bus_index, linear2db(vol_linear))
	percent_label.set_text(linear_to_percent_string(vol_linear))

func linear_to_percent_string(value)->String:
	return String(value * 100.0).pad_decimals(0) + "%"

# Getters and setters
func set_bus_name(value : String):
	bus_name = value
	bus_index = AudioServer.get_bus_index(bus_name)

func get_bus_name()->String:
	return bus_name
