class_name JukeboxEntry
extends Resource

@export var music_id: String
@export var title: String
@export var artist: String
@export var commentary # (String, MULTILINE)

# Getters and setters
func get_music_id()->String:
	return music_id

func set_music_id(value : String):
	music_id = value

func get_title()->String:
	return title

func set_title(value : String):
	title = value

func get_artist()->String:
	return artist

func set_artist(value : String):
	artist = value

func get_commentary()->String:
	return commentary

func set_commentary(value : String):
	commentary = value
