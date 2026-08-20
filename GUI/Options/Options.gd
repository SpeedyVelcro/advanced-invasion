extends Control

@onready var integration_menu = $IntegrationMenu
@onready var integration_settings = $CenterContainer/Panel/VBoxContainer/TabContainer/General/VBoxContainer/IntegrationSettings
@onready var tab_container = $CenterContainer/Panel/VBoxContainer/TabContainer
@onready var options_menu_container = $CenterContainer/Panel
@onready var window_settings_ui = $CenterContainer/Panel/VBoxContainer/TabContainer/Video/VBoxContainer/WindowSettingsUI
@onready var fullscreen_toggle_control = $CenterContainer/Panel/VBoxContainer/TabContainer/Video/VBoxContainer/FullscreenToggle
var showing = false

signal back


# Override
func _ready() -> void:
	if OS.has_feature("web"):
		window_settings_ui.visible = false
		fullscreen_toggle_control.visible = true
	else:
		window_settings_ui.visible = true
		fullscreen_toggle_control.visible = false


# Override
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and showing:
		go_back()


@warning_ignore("native_method_override") # TODO: rename
func show():
	visible = true
	showing = true
	# If there's not integrations skip general tab because it has nothing on it
	# TODO: Remove this once more stuff is added to General.
	if not integration_settings.is_integration_available():
		tab_container.set_current_tab(1)


@warning_ignore("native_method_override") # TODO: rename
func hide():
	visible = false
	showing = false


func _on_BackButton_pressed():
	go_back()


func go_back():
	OptionsSaver.save()
	emit_signal("back")


func _on_IntegrationSettings_activated():
	options_menu_container.set_visible(false)
	integration_menu.show()


func _on_IntegrationMenu_back():
	options_menu_container.set_visible(true)
	integration_menu.hide()
