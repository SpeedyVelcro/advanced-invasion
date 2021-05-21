extends Control

onready var username_line_edit = $CenterContainer/Panel/VBoxContainer/Login/HBoxContainer/UsernameLineEdit
onready var token_line_edit = $CenterContainer/Panel/VBoxContainer/Login/HBoxContainer/TokenLineEdit
onready var login_container = $CenterContainer/Panel/VBoxContainer/Login
onready var logout_container = $CenterContainer/Panel/VBoxContainer/Logout
onready var fail_label = $CenterContainer/Panel/VBoxContainer/Login/HBoxContainer2/Control/FailLabel
onready var login_fail_animation_player = $CenterContainer/Panel/VBoxContainer/Login/HBoxContainer2/Control/LoginFailAnimationPlayer
onready var continue_button = $CenterContainer/Panel/VBoxContainer/ContinueButton
const CONTINUE_BUTTON_TEXT = "Continue"
const SKIP_BUTTON_TEXT = "Skip"

signal back

func _ready():
	GameJoltIntegration.connect("session_open", self, "_on_GameJoltIntegration_session_open")
	GameJoltIntegration.connect("session_open_fail", self, "_on_GameJoltIntegration_session_open_fail")

func show():
	set_visible(true)
	fail_label.set_visible(false)
	if GameJoltIntegration.is_integration_enabled():
		show_logout()
	else:
		show_login()

func hide():
	set_visible(false)

func _on_LoginButton_pressed():
	var username = username_line_edit.get_text()
	var token = token_line_edit.get_text()
	GameJoltIntegration.login(username, token)

func _on_AutoLoginButton_pressed():
	GameJoltIntegration.login_auto()

func _on_LogoutButton_pressed():
	GameJoltIntegration.logout()
	show_login()

func _on_GameJoltIntegration_session_open():
	show_logout()

func _on_GameJoltIntegration_session_open_fail():
	login_fail_animation_player.play("login_fail")

func _on_ContinueButton_pressed():
	emit_signal("back")

func show_login():
	login_container.set_visible(true)
	logout_container.set_visible(false)
	continue_button.set_text(SKIP_BUTTON_TEXT)

func show_logout():
	login_container.set_visible(false)
	logout_container.set_visible(true)
	continue_button.set_text(CONTINUE_BUTTON_TEXT)
