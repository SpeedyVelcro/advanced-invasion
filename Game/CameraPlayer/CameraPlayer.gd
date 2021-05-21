extends Camera2D

export var input_enabled = true
onready var viewport = get_tree().get_root()
# For ZOOM_LEVELS[i][a], i represents different screen sizes and [a] represents
# valid zoom levels at that size.
# Zoom levels must be in size order, smallest vector length to largest.
var ZOOM_LEVELS = [
		[Vector2(0.5, 0.5), # 2x zoom
		Vector2(1.0, 1.0)], # 1x zoom
		
		[Vector2(1.0/3.0, 1.0/3.0), # 3x zoom
		Vector2(0.5, 0.5)], # 2x zoom
		
		[Vector2(0.25, 0.25), # 4x zoom
		Vector2(1.0/3.0, 1.0/3.0)], # 3x zoom
	]
# ZOOM_MIN_RESOLUTION[i] corresponds to ZOOM_LEVELS[i - 1] because ZOOM_LEVELS[0]
# has no minimum resolution.
var ZOOM_MIN_RESOLUTION = [
	Vector2(1280, 720),
	Vector2(1920, 1080)
]
var zoom_levels = ZOOM_LEVELS[0] # Updated by viewport size change
const ZOOM_DURATION = 0.2
var input_zoom_in = false
var input_zoom_out = false
var look_down_height = 160 # Variable not constant because may need to change with resolution
var look_down_stored_height = 0
var input_zoom_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport.connect("size_changed", self, "_on_viewport_size_changed")
	_on_viewport_size_changed() # Adapt size once
	zoom = zoom_levels[1] # Then choose correct starting zoom
	# TODO: move correct starting zoom into a constant or export variable

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var zoom_to = zoom
	# Make sure to not override the ass-backwards mouse wheel detection we have to do
	input_zoom_in = input_zoom_in or (Input.is_action_just_pressed("zoom_in") and input_enabled and input_zoom_enabled)
	input_zoom_out = input_zoom_out or (Input.is_action_just_pressed("zoom_out") and input_enabled and input_zoom_enabled)
	if input_zoom_in:
		input_zoom_in = false
		# Select next smallest zoom level
		for i in range(zoom_levels.size() - 1, -1, -1): # Going through array backwards
			if zoom_levels[i].length_squared() < zoom.length_squared():
				zoom_to = zoom_levels[i]
				break
	elif input_zoom_out:
		input_zoom_out = false
		# Select next biggest zoom level
		for i in range(0, zoom_levels.size(), 1):
			if zoom_levels[i].length_squared() > zoom.length_squared():
				zoom_to = zoom_levels[i]
				break
	#Start up the tween to ease into new zoom level
	if zoom_to != zoom:
		$ZoomTween.interpolate_property(self, "zoom", zoom, zoom_to, ZOOM_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$ZoomTween.start()
	# Look down
	if Input.is_action_just_pressed("look_down") and input_enabled:
		look_down_stored_height = position.y
		position.y = look_down_height
	elif Input.is_action_just_released("look_down") and input_enabled:
		position.y = look_down_stored_height

func zoom_in():
	input_zoom_in = true

func zoom_out():
	input_zoom_out = true

func _input(event):
	# input map doesn't work with mouse wheel so must be polled here
	if input_zoom_enabled:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_UP:
				zoom_in()
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom_out()

func _on_viewport_size_changed():
	var size = viewport.size
	# End any currently running tweens
	var tween_rt = $ZoomTween.get_runtime()
	$ZoomTween.seek(tween_rt)
	# TODO: Might need to also stop the tween. Test this.
	# Identify current zoom level:
	var current_level = 0
	for i in range(1, zoom_levels.size()):
		if zoom.x >= zoom_levels[i].x and zoom.y >= zoom_levels[i].y:
			current_level = i
	# Choose new set of zoom levels
	var chosen_levels = 0
	for i in range(1, ZOOM_LEVELS.size()):
		var test_size = ZOOM_MIN_RESOLUTION[i-1]
		if size.x >= test_size.x or size.y >= test_size.y:
			chosen_levels = i
	zoom_levels = ZOOM_LEVELS[chosen_levels]
	# Finally update current zoom
	zoom = zoom_levels[current_level]
