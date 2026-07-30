class_name CreditsAboutEntry
extends SVAboutEntry


# Override
func get_title() -> String:
	return tr("Credits", "about_title")


# Override
func get_description() -> String:
	var file := FileAccess.open("res://About/Credits.txt", FileAccess.READ)
	if not file:
		push_error("Error opening credits file: %d" % FileAccess.get_open_error())
	
	var credits_text := file.get_as_text()
	
	file.close()
	
	return credits_text
