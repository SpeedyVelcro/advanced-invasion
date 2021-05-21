extends Node

export(NodePath) var start_prompt_path
onready var start_prompt = get_node(start_prompt_path)
export(NodePath) var integration_menu_path
onready var integration_menu = get_node(integration_menu_path)
export(NodePath) var start_gui_path
onready var start_gui = get_node(start_gui_path)
export(NodePath) var story_setup_path
onready var story_setup = get_node(story_setup_path)
export(NodePath) var extras_path
onready var extras = get_node(extras_path)
export(NodePath) var jukebox_path
onready var jukebox = get_node(jukebox_path)
export(NodePath) var credits_path
onready var credits = get_node(credits_path)
export(NodePath) var achievements_path
onready var achievements = get_node(achievements_path)
export(NodePath) var options_path
onready var options = get_node(options_path)

const MUSIC_ID = "militia"
var any_key_grace = false
var fade_start_menu = false

enum {
	STATE_PROMPT,
	STATE_INTEGRATION,
	STATE_START,
	STATE_STORY_SETUP,
	STATE_EXTRAS,
	STATE_JUKEBOX,
	STATE_ACHIEVEMENTS,
	STATE_CREDITS,
	STATE_OPTIONS
}
var state = STATE_PROMPT

signal new_game
signal load_game

func _ready():
	start_prompt.hide()
	start_gui.hide()
	credits.hide()
	if GameStatus.main_menu_visited:
		state = STATE_START
	GameStatus.set_main_menu_visited(true)
	_on_state_enter()
	GlobalMusic.play(MUSIC_ID)
	#$WorldAnimationPlayer.play("background")
	#$WorldAnimationPlayer.seek(1.0, true)

func _input(event):
	match(state):
		STATE_PROMPT:
			# Advance any key prompt
			var event_condition = false
			if (event is InputEventKey) or (event is InputEventMouseButton) or (event is InputEventJoypadButton):
				event_condition = event.pressed
				# Strictly speaking pressed is defined at the child level, but
				# it's the same for these three types of input events.
			if event_condition and not any_key_grace:
				fade_start_menu = true
				if OS.has_feature("newgrounds") or OS.has_feature("gamejolt"):
					change_state(STATE_INTEGRATION)
				else:
					change_state(STATE_START)

func change_state(p_state):
	_on_state_exit()
	state = p_state
	_on_state_enter()

func _on_state_enter(p_state = state):
	match(p_state):
		STATE_PROMPT:
			start_prompt.show()
			$StartPromptGrace.start(0.1)
			any_key_grace = true
		STATE_START:
			start_gui.show(fade_start_menu)
			fade_start_menu = false
		STATE_INTEGRATION:
			integration_menu.show(not fade_start_menu)
			fade_start_menu = false
		STATE_STORY_SETUP:
			story_setup.show()
		STATE_EXTRAS:
			extras.show()
		STATE_JUKEBOX:
			jukebox.show()
			# Only want to stop menu music - no point stopping if just returning
			# to the jukebox
			if GlobalMusic.get_current_music_id() == MUSIC_ID:
				GlobalMusic.stop()
		STATE_ACHIEVEMENTS:
			achievements.show()
		STATE_CREDITS:
			credits.show()
		STATE_OPTIONS:
			options.show()

func _on_state_exit(p_state = state):
	match(p_state):
		STATE_PROMPT:
			start_prompt.hide()
		STATE_INTEGRATION:
			integration_menu.hide()
		STATE_START:
			start_gui.hide(fade_start_menu)
			fade_start_menu = false
		STATE_STORY_SETUP:
			story_setup.hide()
		STATE_EXTRAS:
			extras.hide()
		STATE_JUKEBOX:
			jukebox.hide()
			# Lets not override the jukebox with main menu music
			# Gives the player a chance to listen to what they just started
			# playing while they're poking around
			# Check just in case they didn't play anything though
			if not GlobalMusic.is_playing():
				GlobalMusic.play(MUSIC_ID)
		STATE_ACHIEVEMENTS:
			achievements.hide()
		STATE_CREDITS:
			credits.hide()
		STATE_OPTIONS:
			options.hide()

func _on_StartGUI_new_game():
	change_state(STATE_STORY_SETUP)

func _on_StartGUI_load_game():
	GlobalMusic.stop(0.5)
	StoryStatus.load_game()

func _on_StartGUI_extras():
	change_state(STATE_EXTRAS)

func _on_StartGUI_options():
	change_state(STATE_OPTIONS)

func _on_StartGUI_about():
	change_state(STATE_CREDITS)

func _on_StartGUI_quit():
	if OS.get_name() == "HTML5":
		fade_start_menu = true
		change_state(STATE_PROMPT)
	else:
		get_tree().quit()

func _on_Credits_back():
	change_state(STATE_START)

func _on_StartPromptGrace_timeout():
	any_key_grace = false

func _on_StorySetup_back():
	change_state(STATE_START)

func _on_Extras_jukebox():
	change_state(STATE_JUKEBOX)

func _on_Extras_achievements():
	change_state(STATE_ACHIEVEMENTS)

func _on_Extras_back():
	change_state(STATE_START)

func _on_Jukebox_back():
	change_state(STATE_EXTRAS)

func _on_AchievementsMenu_back():
	change_state(STATE_EXTRAS)

func _on_Options_back():
	change_state(STATE_START)

func _on_IntegrationMenu_back():
	change_state(STATE_START)
