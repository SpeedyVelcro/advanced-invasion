# Bullet.gd

class_name Bullet
extends RigidBody2D

export var team = -1
export var damage = 1.0

func _on_Bullet_body_entered(_body):
	# Hit a wall so delete
	destroy()

func _physics_process(_delta):
	# The body_entered signal sometimes doesn't fire off on collision with a wall
	# So we also do this.
	var bodies = get_colliding_bodies()
	if bodies.size() > 0:
		destroy()

func destroy():
	queue_free()

# Getters and setters
func get_team():
	return team

func set_team(value):
	team = value

func get_damage():
	return damage

func set_damage(value):
	damage = value
