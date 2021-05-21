# PlayerStateKnockback.gd

extends PlayerState

var velocity # Set by Player.gd, NOT reset every frame
var drag_x = 10
var dead = false

func _on_state_enter():
	._on_state_enter()
	disable_snap(false)
	#print("entered knockback")

func _physics_process(_delta):
	var velocity = get_velocity.call_func()
	velocity.x -= drag_x * sign(velocity.x)
	set_velocity.call_func(velocity)
	print(velocity.x)
	if velocity.x > -6 and velocity.x < 6:
		#print("reverting state")
		revert_state()

func start_new_knockback(knockback_velocity):
	set_velocity.call_func(knockback_velocity)
	disable_snap(false) # Don't need to follow floor in knockback mode
	#print("started knockback with velocity" + String(knockback_velocity))
	#print("The player's velocity is now " + String(get_velocity.call_func()))
	# TODO: update facing
