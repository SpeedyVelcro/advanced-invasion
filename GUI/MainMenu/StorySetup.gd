extends Control

@export var standard_button_path: NodePath
@onready var standard_button = get_node(standard_button_path)
@export var hardcore_button_path: NodePath
@onready var hardcore_button = get_node(hardcore_button_path)
@export var description_label_path: NodePath
@onready var description_label = get_node(description_label_path)
@export var back_button_path: NodePath
@onready var back_button = get_node(back_button_path)
@export var play_button_path: NodePath
@onready var play_button = get_node(play_button_path)

var locked = false

const TEXT_STANDARD = "You can take three hits in each level before you die."
const TEXT_HARDCORE = "You will die in one hit. Punishing, but the way it was designed to be played."
const START_LEVEL = "res://Level/01Invasion/01Cutscene.tscn"

signal back

func _ready():
	standard_button.set_pressed(true)
	description_label.set_text(TEXT_STANDARD)

@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true
	standard_button.set_pressed(true)
	description_label.set_text(TEXT_HARDCORE)

@warning_ignore("native_method_override") # TODO: rename
func hide():
	visible = false

func _on_StandardButton_pressed():
	description_label.set_text(TEXT_STANDARD)

func _on_HardcoreButton_pressed():
	description_label.set_text(TEXT_HARDCORE)

func _on_BackButton_pressed():
	if not locked:
		emit_signal("back")

func _on_PlayButton_pressed():
	if not locked:
		# Set up StoryStatus
		StoryStatus.reset()
		if standard_button.is_pressed():
			StoryStatus.change_difficulty(0, true)
		else:
			StoryStatus.change_difficulty(1, true)
		# Get ready to start the game
		GlobalMusic.stop(2.0)
		locked = true
		$Timer.start(1.0)
		hardcore_button.set_disabled(true)
		standard_button.set_disabled(true)
		play_button.set_disabled(true)
		back_button.set_disabled(true)
		

func _on_Timer_timeout():
	SceneTransition.fade(START_LEVEL, 0.5, 0.5)
