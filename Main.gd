extends Node

var first_scene_path = "res://GUI/MainMenu/MainMenu.tscn"

func _ready():
	Migrator.migrate_all()
	
	if OS.has_feature("web"):
		var config := OptionsConfigProvider.get_config()
		
		config.manage_resolution = false
		config.manage_window_mode = false
		config.manage_screen = false
		
		# On web we always just use the canvas size as the resolution, so no
		# need for scaling. Users who need more granular display settings are
		# advised to use the desktop version.
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	
	OptionsLifecycle.start_up()
	
	# Workaround because default UI scale doesn't calculate correctly when calculated
	# before startup. Should fix this problem upstream but this is a temporary
	# workaround for now.
	# TODO: upstream fix
	OptionsProvider.set_default_options(OptionsConfigProvider.get_config().get_default_options())
	
	if OS.has_feature("newgrounds"):
		ProjectSettings.set_setting("newgrounds.io/app_id", Secrets.NEWGROUNDS_APP_ID)
		ProjectSettings.set_setting("newgrounds.io/AES-128_key", Secrets.NEWGROUNDS_AES_128_ENCRYPTION_KEY)
		NG.init()
	
	if OS.has_feature("game_jolt"):
		GameJolt.private_key = Secrets.GAME_JOLT_PRIVATE_KEY
	
	SceneTransition.fade(first_scene_path, 0.0, 1.0)
