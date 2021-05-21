# DialogueLabel.gd

extends RichTextLabel

var speed_multiplier = 1.0

func _ready():
	var effect = RichTextSpeed.new(self)
	install_effect(effect)

func set_visible_characters(value):
	.set_visible_characters(value)
	# This ensures custom fx will re-run every time a new character is drawn,
	# so that the speed multiplier is always up-to-date for the last character.
	speed_multiplier = 1.0
	update()

# Getters and setters
func get_speed_multiplier():
	return speed_multiplier

func set_speed_multiplier(value):
	speed_multiplier = value

# Custom effects
class RichTextSpeed extends RichTextEffect:
	# Format: [speed mult=2.0]Vroooom![/speed]
	var bbcode = "speed"
	var label = null
		
	func _init(p_label):
		label = p_label
	
	func _process_custom_fx(char_fx)->bool:
		if label == null:
			return true # No label assigned to control the speed of
		
		if char_fx.absolute_index == label.get_visible_characters() - 1:
			var spd = char_fx.env.get("mult", 1.0)
			label.set_speed_multiplier(spd)
			# print(char_fx.env)
			return true
		
		return true
	
	func set_label(value):
		label = value
