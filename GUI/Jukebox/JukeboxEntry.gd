class_name JukeboxEntry
extends Resource

export(String) var music_id
export(String) var title
export(String) var artist
export(String, MULTILINE) var commentary

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
