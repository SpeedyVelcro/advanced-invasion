extends Control

@onready var username_line_edit = $CenterContainer/PanelContainer/VBoxContainer/Login/HBoxContainer/UsernameLineEdit
@onready var token_line_edit = $CenterContainer/PanelContainer/VBoxContainer/Login/HBoxContainer/TokenLineEdit
@onready var login_container = $CenterContainer/PanelContainer/VBoxContainer/Login
@onready var logout_container = $CenterContainer/PanelContainer/VBoxContainer/Logout
@onready var fail_label = $CenterContainer/PanelContainer/VBoxContainer/Login/HBoxContainer2/Control/FailLabel
@onready var login_fail_animation_player = $CenterContainer/PanelContainer/VBoxContainer/Login/HBoxContainer2/Control/LoginFailAnimationPlayer
@onready var continue_button = $CenterContainer/PanelContainer/VBoxContainer/ContinueButton
@onready var auto_login_button = $CenterContainer/PanelContainer/VBoxContainer/Login/HBoxContainer2/AutoLoginButton
const CONTINUE_BUTTON_TEXT = "Continue"
const SKIP_BUTTON_TEXT = "Skip"

signal back

func _ready():
	GameJoltIntegration.connect("session_open", Callable(self, "_on_GameJoltIntegration_session_open"))
	GameJoltIntegration.connect("session_open_fail", Callable(self, "_on_GameJoltIntegration_session_open_fail"))
	
	if OS.has_feature("web"):
		auto_login_button.disabled = true

@warning_ignore("native_method_override") # TODO: rename
func show():
	set_visible(true)
	fail_label.set_visible(false)
	if GameJoltIntegration.is_integration_enabled():
		show_logout()
	else:
		show_login()

@warning_ignore("native_method_override") # TODO: rename
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
