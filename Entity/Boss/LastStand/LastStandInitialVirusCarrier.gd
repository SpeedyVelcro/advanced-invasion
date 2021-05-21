extends Node2D

# Node that carries the cutscene viruses
# This is so we can easily do the following simultaneously:
# --Hide a bunch of sprites
# --Spawn viruses at those sprites
onready var virus_resource = preload("res://Entity/Creep/VirusPawn/VirusPawn.tscn")
export(int, "Left", "Right") var start_direction

func start_viruses():
	# Returns number of viruses spawned
	var viruses_spawned = 0
	for child in get_children():
		if child is Sprite:
			call_deferred("replace_sprite_with_virus", child)
			viruses_spawned += 1
	return viruses_spawned

func replace_sprite_with_virus(sprite):
	# Call deferred
	var virus = virus_resource.instance()
	get_parent().add_child(virus)
	virus.global_position = sprite.global_position
	sprite.free()
	match start_direction:
		0:
			virus.set_direction(Vector2.LEFT)
		1:
			virus.set_direction(Vector2.RIGHT)
