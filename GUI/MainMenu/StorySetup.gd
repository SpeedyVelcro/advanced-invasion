extends Control

export(NodePath) var casual_button_path
onready var casual_button = get_node(casual_button_path)
export(NodePath) var normal_button_path
onready var normal_button = get_node(normal_button_path)
export(NodePath) var description_label_path
onready var description_label = get_node(description_label_path)
export(NodePath) var back_button_path
onready var back_button = get_node(back_button_path)
export(NodePath) var play_button_path
onready var play_button = get_node(play_button_path)

var locked = false

const TEXT_CASUAL = "You can take three hits before you die. Best for casual gamers."
const TEXT_NORMAL = "You will die in one hit. The way Advanced Invasion was designed to be played."
const START_LEVEL = "res://Level/01Invasion/01Cutscene.tscn"

signal back

func _ready():
	normal_button.set_pressed(true)
	description_label.set_text(TEXT_NORMAL)

func show():
	visible = true
	normal_button.set_pressed(true)
	description_label.set_text(TEXT_NORMAL)

func hide():
	visible = false

func _on_CasualButton_pressed():
	description_label.set_text(TEXT_CASUAL)

func _on_NormalButton_pressed():
	description_label.set_text(TEXT_NORMAL)

func _on_BackButton_pressed():
	if not locked:
		emit_signal("back")

func _on_PlayButton_pressed():
	if not locked:
		# Set up StoryStatus
		StoryStatus.reset()
		if casual_button.is_pressed():
			StoryStatus.change_difficulty(0, true)
		else:
			StoryStatus.change_difficulty(1, true)
		# Get ready to start the game
		# TODO: play fancy sound effect like Spiral Knights does
		GlobalMusic.stop(3.0)
		locked = true
		$Timer.start(2.5)
		normal_button.set_disabled(true)
		casual_button.set_disabled(true)
		play_button.set_disabled(true)
		back_button.set_disabled(true)
		

func _on_Timer_timeout():
	SceneTransition.fade(START_LEVEL, 0.5, 0.5)
