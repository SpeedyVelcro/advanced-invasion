extends Control

onready var title_label = $VBoxContainer/TitleLabel
onready var rich_label = $VBoxContainer/RichTextLabel
onready var vbox_container = $VBoxContainer
onready var finish_timer = $FinishTimer
onready var start_timer = $StartTimer
onready var music_start_timer = $MusicStartTimer
onready var start_sound_audio_player = $StartSoundAudioStreamPlayer
var credits_end = 999999
const CREDITS_FILE = "res://About/Credits.txt"
const SCROLL_SPEED = 40.0
var credits_rolling = false
const NEXT_SCENE = "res://GUI/MainMenu/MainMenu.tscn"
onready var viewport = get_tree().get_root()

func _ready():
	start_sound_audio_player.play()
	title_label.rect_min_size.y = viewport.size.y
	display_text_file(CREDITS_FILE)
	music_start_timer.start(2.0)
	start_timer.start(2.0)

func _process(delta):
	if credits_rolling:
		vbox_container.rect_position.y -= SCROLL_SPEED * delta
		if abs(vbox_container.rect_position.y) > credits_end:
			credits_rolling = false
			finish_timer.start(2.5)
			GlobalMusic.stop(3.0)
	if Input.is_action_just_pressed("ui_cancel"):
		end()

func display_text_file(file_path):
	var file = File.new()
	file.open(file_path, File.READ)
	var credits_text = "[center]"
	while true:
		credits_text += file.get_line()
		if file.eof_reached():
			break
		else:
			credits_text += "\n"
	file.close()
	credits_text += "[/center]"
	rich_label.set_bbcode(credits_text)
	#rich_label.get_v_scroll().set_value(0.0)

func _on_StartTimer_timeout():
	# Calculate end point
	# Must be delayed because RichTextLabel height doesn't update instantly.
	var credits_height = 0
	for child in vbox_container.get_children():
		if child is Control:
			credits_height += child.rect_size.y
	credits_end = credits_height
	credits_rolling = true


func _on_FinishTimer_timeout():
	end()

func end():
	SceneTransition.fade(NEXT_SCENE)

func _on_MusicStartTimer_timeout():
	GlobalMusic.play("download")
