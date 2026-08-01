extends Node

var first_scene_path = "res://GUI/MainMenu/MainMenu.tscn"

func _ready():
	Migrator.migrate_all()
	
	OptionsLifecycle.start_up()
	
	SceneTransition.fade(first_scene_path, 0.0, 1.0)
