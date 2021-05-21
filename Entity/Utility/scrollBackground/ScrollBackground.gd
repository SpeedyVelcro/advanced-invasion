# ScrollBackground.gd

extends Sprite

export var scroll_speed = Vector2(0, 0)

func _process(delta):
	var sprite_size = texture.get_size()
	offset += scroll_speed * delta
	offset.x = fposmod(offset.x, sprite_size.x)
	offset.y = fposmod(offset.y, sprite_size.y)
	
