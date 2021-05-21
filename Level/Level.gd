class_name Level
extends Node2D

export var checkpoint = true
export var cutscene_active = false

export var play_music_on_start = false
export var music_id = ""
onready var hud = get_node("LevelHUD")

func _ready():
	if checkpoint:
		StoryStatus.set_current_level(filename)
		StoryStatus.save()
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		connect_player(player)
	$LevelHUD.set_lives_enabled(StoryStatus.get_lives_enabled())
	$PauseMenu.set_cutscene_mode(cutscene_active)
	if cutscene_active:
		$LevelHUD.hide(true)
	else:
		$LevelHUD.show(true)
	# Play music on start
	if play_music_on_start:
		if music_id == "":
			GlobalMusic.stop()
		else:
			GlobalMusic.play(music_id)

func connect_player(player_node):
	player_node.connect("death", self, "_on_Player_death")
	player_node.connect("health_changed", hud, "_on_Player_health_changed")

func restart():
	StoryStatus.load_game()

func _on_Player_death():
	restart()

func _on_PauseMenu_restart():
	restart()

func _on_PauseMenu_skip_cutscene():
	_on_cutscene_skip()

func _on_cutscene_skip():
	pass # OVERRIDE ME

# Getters and setters
func set_cutscene_active(value):
	cutscene_active = value
	$PauseMenu.set_cutscene_mode(cutscene_active)
	if cutscene_active:
		$LevelHUD.hide()
	else:
		$LevelHUD.show()

func is_cutscene_active():
	return cutscene_active
