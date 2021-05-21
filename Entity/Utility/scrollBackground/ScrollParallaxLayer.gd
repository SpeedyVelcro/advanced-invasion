extends ParallaxLayer

export var scroll_speed : Vector2

func _process(delta):
	motion_offset += scroll_speed * delta
