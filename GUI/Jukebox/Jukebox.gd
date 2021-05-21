extends Control

onready var entry_container = $CenterContainer/Panel/VBoxContainer/HBoxContainer/ScrollContainer/EntryContainer
onready var commentary_label = $CenterContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer/CommentaryLabel

export(String, MULTILINE) var default_commentary
var entries = [ [
		# DISC 1
		preload("res://GUI/Jukebox/Entries/Download.tres"),
		preload("res://GUI/Jukebox/Entries/Invasion.tres"),
		preload("res://GUI/Jukebox/Entries/Meager.tres"),
		preload("res://GUI/Jukebox/Entries/Firefly.tres"),
		preload("res://GUI/Jukebox/Entries/Anxiety.tres"),
		preload("res://GUI/Jukebox/Entries/Sanctuary.tres"),
		preload("res://GUI/Jukebox/Entries/Brash.tres"),
		preload("res://GUI/Jukebox/Entries/Militia.tres"),
		preload("res://GUI/Jukebox/Entries/Deathbed.tres"),
		preload("res://GUI/Jukebox/Entries/Petra.tres"),
		preload("res://GUI/Jukebox/Entries/Dynamite.tres"),
		preload("res://GUI/Jukebox/Entries/Favour.tres")
	], [
		# DISC 2
		preload("res://GUI/Jukebox/Entries/BrashFakeout.tres"),
		preload("res://GUI/Jukebox/Entries/BrashIntro.tres"),
		preload("res://GUI/Jukebox/Entries/BrashNoIntro.tres")
	]
]
var entry_button_resource = preload("res://GUI/Jukebox/JukeboxEntryButton.tscn")
var disc_header_resource = preload("res://GUI/Jukebox/DiscHeader.tscn")
var entry_buttons = []

signal back

func _ready():
	var text
	for disc in range(entries.size()):
		
		# Create disc header
		if entries.size() > 1:
			var header = disc_header_resource.instance()
			entry_container.add_child(header)
			header.set_disc_number(disc + 1)
		
		# Add all the entries below this
		entry_buttons.append([])
		for entry in entries[disc].size():
			entry_buttons[disc].append(entry_button_resource.instance())
			entry_container.add_child(entry_buttons[disc][entry])
			text = String(entry + 1)
			text += ". "
			if GameStatus.is_soundtrack_unlocked(entries[disc][entry].get_music_id()):
				text += entries[disc][entry].get_title()
			else:
				text += "???"
				entry_buttons[disc][entry].set_disabled(true)
			entry_buttons[disc][entry].set_text(text)
			entry_buttons[disc][entry].connect("pressed", self, "_on_JukeboxEntryButton_pressed", [disc, entry])
	commentary_label.set_bbcode(default_commentary)

func _on_JukeboxEntryButton_pressed(disc : int, entry : int):
	if GlobalMusic.get_current_music_id() != entries[disc][entry].get_music_id():
		GlobalMusic.play(entries[disc][entry].get_music_id())
	var text = "[b]"
	if entries.size() > 1:
		text += "Disc "
		text += String(disc + 1)
		text += " -- "
	text += String(entry + 1)
	text += ". "
	text += entries[disc][entry].get_title()
	text += "[/b]\n\n"
	# Kinda stupid to show artist credits when it's a one-man show so commenting
	# out for now:
	# text += "by "
	# text += entries[disc][entry].get_artist()
	# text += "\n\n"
	text += entries[disc][entry].get_commentary()
	commentary_label.set_bbcode(text)

func show():
	visible = true

func hide():
	visible = false

func _on_BackButton_pressed():
	emit_signal("back")

func _on_DownloadButton_pressed():
	pass # Replace with function body.
