extends Node

var first_scene_path = "res://GUI/MainMenu/MainMenu.tscn"

func _ready():
	Migrator.migrate_all()
	
	OptionsLifecycle.start_up()
	
	# Workaround because default UI scale doesn't calculate correctly when calculated
	# before startup. Should fix this problem upstream but this is a temporary
	# workaround for now.
	# TODO: upstream fix
	OptionsProvider.set_default_options(OptionsConfigProvider.get_config().get_default_options())
	
	SceneTransition.fade(first_scene_path, 0.0, 1.0)
