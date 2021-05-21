# Hitbox.gd

class_name Hitbox
extends Area2D

export var direction_by_velocity = true
export var vulnerable_to_teams = [0]

signal attacked(damage, from_direction)

func attack(damage, from_direction):
	emit_signal("attacked", damage, from_direction)


func _on_Hitbox_body_entered(body):
	if body is Bullet:
		if vulnerable_to_teams.has(body.get_team()):
			var dir
			if direction_by_velocity:
				dir = body.get_linear_velocity().normalized()
			else:
				assert(false) # TODO: angle by difference between hitbox and bullet position
			var dam = body.get_damage()
			attack(dam, dir)
			body.destroy()

func set_active(value):
	set_deferred("monitoring", value)
	set_deferred("monitorable", value)
