extends Node2D

onready var animation_player = $AnimationPlayer
onready var area = $Physical/Area2D
onready var sprite = $Physical/Sprite
onready var timer = $Timer
onready var raycast = $Physical/RayCast2D
onready var physical_node = $Physical
onready var gun_audio_player = $GunAudioStreamPlayer2D
var dead = false
const FIRST_GUN_TIME = 0.2
const BASE_GUN_TIME = 0.9
const MIN_GUN_TIME = 0.05
const BULLET_SPAWN_POS = Vector2(-9, 0)
const BULLET_SPEED = 256
var bullet_resource = preload("res://Entity/Player/PlayerBullet/PlayerBullet.tscn")

signal death

func _ready():
	set_visible(false)
	sprite.set_visible(true)
	sprite.set_offset(Vector2(0, 0))
	sprite.set_position(Vector2(0, 0))

func start():
	animation_player.play("movement")
	area.set_deferred("monitoring", true)
	timer.start(FIRST_GUN_TIME)
	set_visible(true)

func fire_gun():
	gun_audio_player.play()
	var bullet = bullet_resource.instance()
	get_parent().add_child(bullet)
	bullet.set_global_position(physical_node.global_position + BULLET_SPAWN_POS)
	bullet.set_linear_velocity(BULLET_SPEED * Vector2.LEFT)

func _on_Area2D_body_entered(body):
	if not dead:
		dead = true
		animation_player.play("death")
		emit_signal("death")
		timer.stop()

func _on_Timer_timeout():
	raycast.force_raycast_update()
	if raycast.is_colliding():
		fire_gun()
	var distance = abs(raycast.get_collision_point().x - raycast.global_position.x)
	var distance_frac = clamp(distance / raycast.cast_to.length(), 0.0, 1.0)
	var t = BASE_GUN_TIME * distance_frac
	t = max(t, MIN_GUN_TIME)
	timer.start(t)
