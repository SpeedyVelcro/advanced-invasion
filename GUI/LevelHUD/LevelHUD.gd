class_name LevelHUD
extends CanvasLayer

## Show lives for the teal character as well; for the final boss (last stand).
@export var show_teal_lives := false

@onready var boss_health = $SubViewportContainer/UIScalingSubViewport/BossHealth
@onready var lives = $SubViewportContainer/UIScalingSubViewport/Lives
@onready var teal_lives = $SubViewportContainer/UIScalingSubViewport/LivesTeal
var lives_enabled = true

func _on_Player_health_changed(value):
	lives.update_lives(value)

func _on_teal_health_changed(value):
	teal_lives.update_lives(value)

func _on_boss_health_changed(health, max_health):
	boss_health.update_health(health, max_health)


# Override
func _ready() -> void:
	const INSTANT := true
	lives.hide(INSTANT)
	teal_lives.hide(INSTANT)


@warning_ignore("native_method_override") # TODO: rename
func show(instant = false):
	# Show all hud elements
	lives.show(instant)
	if show_teal_lives:
		teal_lives.show(instant)


@warning_ignore("native_method_override") # TODO: rename
func hide(instant = false):
	# Hide all hud elements
	lives.hide(instant)
	teal_lives.hide(instant)


func show_boss_health(instant = false):
	boss_health.show(instant)


func hide_boss_health(instant = false):
	boss_health.hide(instant)


# Getters and setters
func set_lives_enabled(value : bool):
	lives_enabled = value
	lives.set_visible(value)
	teal_lives.set_visible(value)
	print("lives enabled is " + str(value))
