# DialogueColors.gd

class_name DialogueColors
extends Resource

# There appears to be an issue in Godot with dynamic fonts where white text exclusively
# is displayed without antialiasing, and with thicker lines than normal. So instead of
# white for default, the lightest grey possible is used.
export(Color) var default_color = Color(1.0, 1.0, 1.0, 1.0)
export(Dictionary) var color

# Setters and getters
func set_color(key, val):
	color[key] = val


func get_color(key):
	if color.has(key):
		return color[key]
	else:
		return get_default_color()

func set_default_color(val : Color):
	default_color = val

func get_default_color():
	return default_color
