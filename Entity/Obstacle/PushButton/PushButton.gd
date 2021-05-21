extends Area2D

export(Texture) var normal_texture
export(Texture) var depressed_texture
onready var sprite = $Sprite
onready var audio_stream_player = $AudioStreamPlayer2D
var depressed = false setget set_depressed, is_depressed
export var start_depressed = false # Must be seperate from depressed, otherwise setget tries to set texture before ready

signal pressed

func _ready():
	# Ensure everything is in order by calling set function
	set_depressed(start_depressed)

func set_depressed(value : bool, play_sound = false):
	# Does NOT emit signal. Signal is only emitted if pressed by player.
	# This is important to allow scripts to activate/deactivate the button
	# without wreaking havoc on everything else.
	if value:
		sprite.set_texture(depressed_texture)
		if play_sound:
			audio_stream_player.play()
	else:
		sprite.set_texture(normal_texture)
	set_deferred("monitoring", not value)
	depressed = value

func is_depressed()->bool:
	return depressed

func _on_PushButton_body_entered(_body):
	# Guaranteed to be player due to mask
	if not depressed:
		set_depressed(true, true)
		emit_signal("pressed")
		# TODO: play sound
