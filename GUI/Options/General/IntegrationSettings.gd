extends Control

onready var available_container = $Available
onready var unavailable_container = $UnavailableLabel
onready var status_label = $Available/StatusLabel
onready var platform_label = $Available/PlatformLabel
const ENABLED_COLOR = Color(0.0, 1.0, 0.0, 1.0)
const DISABLED_COLOR = Color(1.0, 0.0, 0.0, 1.0)
const ENABLED_TEXT = "Enabled"
const DISABLED_TEXT = "Disabled"
const NEWGROUNDS_TEXT = "Newgrounds"
const GAME_JOLT_TEXT = "Game Jolt"
var integration_available = false setget, is_integration_available

signal activated

func _ready():
	# Update availability
	integration_available = OS.has_feature("newgrounds") or OS.has_feature("gamejolt")
	available_container.set_visible(integration_available)
	unavailable_container.set_visible(not integration_available)
	# Connect signals
	GameJoltIntegration.connect("session_open", self, "_on_integration_enabled")
	GameJoltIntegration.connect("session_closed", self, "_on_integration_disabled")
	NewgroundsIntegration.connect("enabled", self, "_on_integration_enabled")
	NewgroundsIntegration.connect("disabled", self, "_on_integration_disabled")
	# Updated enabled
	var integration_enabled = NewgroundsIntegration.is_integration_enabled() or GameJoltIntegration.is_integration_enabled()
	if integration_enabled:
		mark_enabled()
	else:
		mark_disabled()
	# Set platform label
	if OS.has_feature("newgrounds"):
		platform_label.set_text(NEWGROUNDS_TEXT)
	elif OS.has_feature("gamejolt"):
		platform_label.set_text(GAME_JOLT_TEXT)

func _on_ChangeButton_pressed():
	emit_signal("activated")

func _on_integration_enabled():
	mark_enabled()

func _on_integration_disabled():
	mark_disabled()

func mark_enabled():
	status_label.set("custom_colors/font_color", ENABLED_COLOR)
	status_label.set_text(ENABLED_TEXT)

func mark_disabled():
	status_label.set("custom_colors/font_color", DISABLED_COLOR)
	status_label.set_text(DISABLED_TEXT)

# Getters and setters
func is_integration_available():
	return integration_available
