extends Control

export(NodePath) var resolution_option_path
onready var resolution_option = get_node(resolution_option_path)
export(NodePath) var fullscreen_checkbox_path
onready var fullscreen_checkbox = get_node(fullscreen_checkbox_path)
export(NodePath) var vsync_checkbox_path
onready var vsync_checkbox = get_node(vsync_checkbox_path)
export(NodePath) var confirm_prompt_path
onready var confirm_prompt = get_node(confirm_prompt_path)

onready var viewport = get_tree().get_root()
var current_resolution = Vector2(1280, 720)
var current_fullscreen = false
var current_vsync = false
var selected_resolution = Vector2(1280, 720)
var resolution_list = [
		#Vector2( 640, 480 ),
		#Vector2( 720, 480 ),
		#Vector2( 720, 576 ),
		#Vector2( 800, 600 ),
		Vector2( 1024, 768 ),
		Vector2( 1280, 720 ),
		Vector2( 1280, 800 ),
		Vector2( 1280, 1024 ),
		Vector2( 1360, 768 ),
		Vector2( 1366, 768 ),
		Vector2( 1440, 900 ),
		Vector2( 1600, 900 ),
		Vector2( 1680, 1050 ),
		Vector2( 1920, 1080 ),
		Vector2( 1920, 1200 )
		#Vector2( 2560, 1440 ),
		#Vector2( 2560, 1080 ),
		#Vector2( 3440, 1440 ),
		#Vector2( 3840, 2160 )
]

func _ready():
	# Remove unvalid sizes from resolution list
	# Iterate backwards since removal changes size/causes skipping otherwise
	for i in range(resolution_list.size() - 1, -1, -1):
		var found_valid_screen = false
		for screen in range(OS.get_screen_count()):
			if resolution_list[i].x <= OS.get_screen_size(screen).x:
				if resolution_list[i].y <= OS.get_screen_size(screen).y:
					found_valid_screen = true
		if not found_valid_screen:
			resolution_list.remove(i)
	# Add monitor sizes to resolution list
	for i in range(OS.get_screen_count()):
		if not resolution_list.has(OS.get_screen_size(i)):
			resolution_list.append(OS.get_screen_size(i))
	if not resolution_list.has(viewport.get_size()):
		resolution_list.append(viewport.get_size())
	# Populate options button with resolutions
	resolution_option.clear()
	for resolution in resolution_list:
		resolution_option.add_item(res_as_string(resolution))
	# Set controls
	current_resolution = viewport.get_size()
	current_fullscreen = OS.is_window_fullscreen()
	current_vsync = OS.is_vsync_enabled()
	revert_controls()

func revert_controls():
	selected_resolution = current_resolution
	var res_index = resolution_list.find(selected_resolution)
	if res_index != -1:
		resolution_option.select(res_index)
	else:
		resolution_option.set_text(res_as_string(current_resolution))
	fullscreen_checkbox.set_pressed(current_fullscreen)
	vsync_checkbox.set_pressed(current_vsync)

func res_as_string(resolution : Vector2)->String:
	return String(resolution.x) + "x" + String(resolution.y)

func _on_ApplyButton_pressed():
	OptionsManager.set_display(selected_resolution, fullscreen_checkbox.is_pressed(), vsync_checkbox.is_pressed())
	confirm_prompt.show()

func _on_ConfirmPrompt_no():
	OptionsManager.set_display(current_resolution, current_fullscreen, current_vsync)
	revert_controls()

func _on_ConfirmPrompt_yes():
	print(viewport.get_size())
	current_resolution = selected_resolution
	current_fullscreen = OS.is_window_fullscreen()
	current_vsync = OS.is_vsync_enabled()
	# TODO: get OptionsManager to save

func _on_ResolutionOptionButton_item_selected(index):
	selected_resolution = resolution_list[index]
