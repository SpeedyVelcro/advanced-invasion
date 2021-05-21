extends Control

onready var integration_menu = $IntegrationMenu
onready var integration_settings = $CenterContainer/Panel/VBoxContainer/TabContainer/General/VBoxContainer/IntegrationSettings
onready var tab_container = $CenterContainer/Panel/VBoxContainer/TabContainer
onready var options_menu_container = $CenterContainer/Panel
var showing = false

signal back

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and showing:
		back()

func show():
	visible = true
	showing = true
	# If there's not integrations skip general tab because it has nothing on it
	# TODO: Remove this once more stuff is added to General.
	if not integration_settings.is_integration_available():
		tab_container.set_current_tab(1)

func hide():
	visible = false
	showing = false

func _on_BackButton_pressed():
	back()

func back():
	OptionsManager.save()
	emit_signal("back")

func _on_IntegrationSettings_activated():
	options_menu_container.set_visible(false)
	integration_menu.show()

func _on_IntegrationMenu_back():
	options_menu_container.set_visible(true)
	integration_menu.hide()
