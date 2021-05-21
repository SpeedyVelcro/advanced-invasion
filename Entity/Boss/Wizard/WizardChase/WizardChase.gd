extends PathFollow2D

onready var body_sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer
onready var attack_area = $AttackArea
onready var beam_bottom = $BeamBottom
onready var beam_top = $BeamTop
var player
const FOLLOW_SPEED = 90.0
const DISTANT_SPEED_COEFFICIENT = 1.0
const SPEED_UP_DISTANCE = 300.0 # For reference, half a camera is about 320
const BODY_KNOCKBACK = Vector2(300, -250)

enum {
	STATE_SLEEP,
	STATE_FOLLOWING,
	STATE_DEATH
}
var state = STATE_SLEEP

signal appeared
signal ended

func _ready():
	body_sprite.set_visible(false)
	# Find player
	# Could probably check if player doesn't exist but seems like too much effort
	# for something that will never happen
	player = get_tree().get_nodes_in_group("player")[0]

func appear():
	animation_player.play("appear")

func start():
	change_state(STATE_FOLLOWING)
	attack_area.set_deferred("monitoring", true)

func change_state(p_state):
	_on_state_exit()
	state = p_state
	_on_state_enter()

func _on_state_enter(p_state = state):
	match(p_state):
		STATE_SLEEP:
			pass

func _physics_process(delta):
	match state:
		STATE_FOLLOWING:
			# Calculate speed
			var spd = FOLLOW_SPEED
			var distance = abs(player.global_position.x - global_position.x)
			var distance_over = max(0.0, distance - SPEED_UP_DISTANCE)
			spd += distance_over * DISTANT_SPEED_COEFFICIENT
			
			var previous_x = position.x
			offset += spd * delta
			if position.x >= previous_x:
				body_sprite.play("right")
			else:
				body_sprite.play("left")
			beam_bottom.update()
			beam_top.update()
	

func _on_state_exit(p_state = state):
	match(p_state):
		STATE_SLEEP:
			pass

func end():
	change_state(STATE_DEATH)
	animation_player.play("end")
	attack_area.set_deferred("monitoring", false)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"appear":
			emit_signal("appeared")
		"end":
			emit_signal("ended")


func _on_AttackArea_body_entered(body):
	# Body is player due to mask
	var kb = BODY_KNOCKBACK
	if body.global_position.x < global_position.x:
		kb.x *= -1
	body.hit(kb, 1)
