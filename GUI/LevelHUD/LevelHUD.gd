extends CanvasLayer

@onready var boss_health = $SubViewportContainer/UIScalingSubViewport/BossHealth
@onready var lives = $SubViewportContainer/UIScalingSubViewport/Lives
var lives_enabled = true

func _on_Player_health_changed(value):
	lives.update_lives(value)

func _on_boss_health_changed(health, max_health):
	boss_health.update_health(health, max_health)

@warning_ignore("native_method_override") # TODO: rename
func show(instant = false):
	# Show all hud elements
	lives.show(instant)

@warning_ignore("native_method_override") # TODO: rename
func hide(instant = false):
	# Hide all hud elements
	lives.hide(instant)

func show_boss_health(instant = false):
	boss_health.show(instant)

func hide_boss_health(instant = false):
	boss_health.hide(instant)

# Getters and setters
func set_lives_enabled(value : bool):
	lives_enabled = value
	lives.set_visible(value)
	print("lives enabled is " + str(value))
