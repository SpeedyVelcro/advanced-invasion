extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var world
var next_level_path = "res://Level/Test/Test.tscn"
var current_level
var current_level_path
const PLAYER_PATH = "res://Entity/Player/Player.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and !get_tree().is_paused():
		# Pause (unpausing is handled by the pause menu)
		# If the World node exists, the game is running
		if has_node("World"):
			if $World.is_pause_allowed():
				var pause_menu_resource = load("res://GUI/PauseMenu/PauseMenu.tscn")
				var pause_menu = pause_menu_resource.instance()
				add_child(pause_menu)
				pause_menu.connect("restart", self, "_on_PauseMenu_restart")
				get_tree().set_pause(true)

func change_level(resource_string):
	if !$LevelChangeAnimation.is_playing():
		next_level_path = resource_string
		$LevelChangeAnimation.play("next_level")

func restart_level():
	if !$LevelChangeAnimation.is_playing():
		$LevelChangeAnimation.play("restart_level")

func _on_LevelEnd_reached(next_level_path):
	change_level(next_level_path)

func _on_Player_death():
	restart_level()

func _on_level_change_blackout():
	current_level.queue_free()
	current_level_path = next_level_path
	var level_resource = load(current_level_path)
	var level = level_resource.instance()
	current_level = level
	$World.add_child(level)

func _on_new_game_blackout():
	# Create game world
	var world_resource = load("res://Game/World/World.tscn")
	world = world_resource.instance()
	self.add_child(world)
	# Create player
	var player_resource = load(PLAYER_PATH)
	var player = player_resource.instance()
	world.add_child(player)
	player.connect("death", self, "_on_Player_death")
	# Create first level
	current_level_path = "res://Level/Test/Test.tscn"
	var first_level_resource = load(current_level_path)
	var first_level = first_level_resource.instance()
	current_level = first_level
	world.add_child(first_level)
	# Get rid of main menu
	if has_node("MainMenu"):
		$MainMenu.queue_free()

func _on_restart_level_blackout():
	call_deferred("_deferred_on_restart_level_blackout")

func _deferred_on_restart_level_blackout():
	# Swap player
	get_node("/root/Main/World/Player").free()
	var player_resource = load(PLAYER_PATH)
	var player = player_resource.instance()
	$World.add_child(player)
	player.connect("death", self, "_on_Player_death")
	# TODO: Update lives if life-saving is on?
	# Swap level
	current_level.free()
	var level_resource = load(current_level_path)
	current_level = level_resource.instance()
	$World.add_child(current_level)
	# Get rid of pause menu
	if has_node("PauseMenu"):
		$PauseMenu.free()	

func _on_MainMenu_new_game():
	if !$LevelChangeAnimation.is_playing():
		$LevelChangeAnimation.play("new_game")

func _on_MainMenu_load_game():
	pass # Replace with function body.

func _on_PauseMenu_restart():
	restart_level()
