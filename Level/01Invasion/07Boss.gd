extends Level

const START_DELAY = 0.2
const CREEP_SPAWN_TIME_SHORT = 1.5
const CREEP_SPAWN_TIME_SHORT_EASY = 2.5
const CREEP_SPAWN_TIME = 6.0
const CREEP_SPAWN_TIME_EASY = 8.0
const MAX_CREEPS = 30
const CREEP_CULLABLE_HEIGHT = 96
@onready var landing_timer = $LandingTimer
@onready var giant = $Giant
@onready var player_camera = $Player/CameraPlayer
@onready var creep_spawn_left = $CreepSpawnLeft
@onready var creep_spawn_right = $CreepSpawnRight
@onready var left_spawn_timer = $LeftSpawnTimer
@onready var right_spawn_timer = $RightSpawnTimer
@onready var creep_resource = preload("res://Entity/Creep/VirusPawn/VirusPawn.tscn")
@onready var barrier = $Barrier

func _ready():
	super()
	
	if StoryStatus.get_difficulty_id() == StoryStatus.get_lowest_difficulty_id():
		left_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_EASY)
		right_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_EASY)
	else:
		left_spawn_timer.set_wait_time(CREEP_SPAWN_TIME)
		right_spawn_timer.set_wait_time(CREEP_SPAWN_TIME)

func _on_WakeArea_body_entered(_body):
	# NB: This is one-shot
	# We know it's the player due to collision mask
	landing_timer.start(START_DELAY)
	player_camera.input_enabled = false
	player_camera.set_limit(SIDE_LEFT, 0)
	player_camera.set_global_position(giant.get_global_position())
	player.set_input_locked(true)

func _on_LandingTimer_timeout():
	giant.wake()
	GlobalMusic.play("meager")

func _on_Giant_awake():
	player_camera.set_position(Vector2(0, 0))
	player_camera.input_enabled = true
	player.set_input_locked(false)

func _on_StopMusicArea_body_entered(_body):
	GlobalMusic.stop(9.0)

func _on_SpawnAreaLeft_body_entered(_body):
	if StoryStatus.get_difficulty_id() == StoryStatus.get_lowest_difficulty_id():
		left_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_SHORT_EASY)
	else:
		left_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_SHORT)

func _on_SpawnAreaLeft_body_exited(_body):
	if StoryStatus.get_difficulty_id() == StoryStatus.get_lowest_difficulty_id():
		left_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_EASY)
	else:
		left_spawn_timer.set_wait_time(CREEP_SPAWN_TIME)

func _on_SpawnAreaRight_body_entered(_body):
	if StoryStatus.get_difficulty_id() == StoryStatus.get_lowest_difficulty_id():
		right_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_SHORT_EASY)
	else:
		right_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_SHORT)

func _on_SpawnAreaRight_body_exited(_body):
	if StoryStatus.get_difficulty_id() == StoryStatus.get_lowest_difficulty_id():
		right_spawn_timer.set_wait_time(CREEP_SPAWN_TIME_EASY)
	else:
		right_spawn_timer.set_wait_time(CREEP_SPAWN_TIME)

func spawn_left():
	# MUST USE call_deferred()
	cull_creeps() # Already within a deferred call
	var creep = creep_resource.instantiate()
	add_child(creep)
	creep.set_global_position(creep_spawn_left.get_global_position())
	creep.reset_physics_interpolation()
	creep.set_direction(Vector2.RIGHT)

func spawn_right():
	# MUST USE call_deferred()
	cull_creeps() # Already within a deferred call
	var creep = creep_resource.instantiate()
	add_child(creep)
	creep.set_global_position(creep_spawn_right.get_global_position())
	creep.reset_physics_interpolation()
	creep.set_direction(Vector2.LEFT)

func _on_LeftSpawnTimer_timeout():
	call_deferred("spawn_left")

func _on_RightSpawnTimer_timeout():
	call_deferred("spawn_right")

func _on_Giant_first_hit():
	left_spawn_timer.start()
	right_spawn_timer.start()
	call_deferred("spawn_left")
	call_deferred("spawn_right")

func _on_Giant_death():
	left_spawn_timer.stop()
	right_spawn_timer.stop()
	for creep in get_tree().get_nodes_in_group("creep"):
		creep.die()
	barrier.disable()

func cull_creeps():
	# MUST USE call_deferred()
	var creeps = get_tree().get_nodes_in_group("creep")
	var creep_number = creeps.size()
	if creep_number > MAX_CREEPS:
		for creep in creeps:
			if creep.get_global_position().y > CREEP_CULLABLE_HEIGHT:
				creep.free()
				creep_number -= 1
				if creep_number <= MAX_CREEPS:
					break
