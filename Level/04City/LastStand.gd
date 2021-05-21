extends Level

export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []
export(Array, Resource) var dialogue_3 = []
export(Array, Resource) var dialogue_4 = []

const NEXT_LEVEL = "res://Level/04City/10Cutscene.tscn"
onready var player = $Player
onready var player_camera = $Player/CameraPlayer
onready var animation_player = $AnimationPlayer
onready var virus_spawn_pos_left = $VirusSpawnPositionLeft.global_position
onready var virus_spawn_pos_right = $VirusSpawnPositionRight.global_position
onready var virus_spawn_timer_left = $VirusSpawnTimerLeft
onready var virus_spawn_timer_right = $VirusSpawnTimerRight
onready var shield_spawn_timer = $ShieldSpawnTimer
onready var last_stand_hud = $LastStandHUD
onready var virus_resource = preload("res://Entity/Creep/VirusPawn/VirusPawn.tscn")
onready var virus_shield_resource = preload("res://Entity/Creep/VirusPawn/Variants/VirusShieldPawn.tscn")
const INITIAL_SPAWN_TIME = 0.4
const PEAK_SPAWN_TIME = 0.27
const END_SPAWN_TIME = 0.6
const SHIELD_SPAWN_TIME = 0.5 # Both time before and after shield spawn, to give a buffer zone
const INITIAL_VIRUS_PER_SHIELD = 10
const END_VIRUS_PER_SHIELD = 6
var virus_per_shield = INITIAL_VIRUS_PER_SHIELD
var viruses_until_shield = virus_per_shield
var spawn_time = INITIAL_SPAWN_TIME
const VIRUS_TOTAL = 1000
const PEAK_VIRUSES_LEFT = 400 # Number of viruses left at peak spawn rate
var viruses_left = VIRUS_TOTAL
var viruses_alive = VIRUS_TOTAL # Reset when battle actually starts to account for cutscene deaths
var zoomed_in = false
onready var cutscene_bullet = [
	$CutsceneBullet1,
	$CutsceneBullet2,
	$CutsceneBullet3
]
const CUTSCENE_BULLET_IMPULSE = [
	Vector2(256, 0),
	Vector2(256, 0),
	Vector2(-256, 0)
]
onready var teal = $TealLastStand
onready var teal_cutscene_sprite = $TealSprite
onready var initial_virus_carrier_left = $InitialVirusCarrierLeft
onready var initial_virus_carrier_right = $InitialVirusCarrierRight
const CAMERA_BATTLE_POSITION = Vector2(-64, 0)

func _ready():
	DialogueManager.connect("end_broadcast", self, "_on_DialogueManager_end_broadcast")
	animation_player.play("cutscene_1")
	for bullet in cutscene_bullet:
		bullet.set_visible(false)

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			pass
		"dialogue_2":
			animation_player.play("cutscene_2")
			GlobalMusic.stop(0.3)
		"dialogue_3":
			animation_player.play("cutscene_3")
		"dialogue_4":
			start_battle()

func teal_says_look_out():
	DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_2, "dialogue_2")
		"cutscene_2":
			DialogueManager.queue_dialogue(dialogue_3, "dialogue_3")
		"cutscene_3":
			DialogueManager.queue_dialogue(dialogue_4, "dialogue_4")
			player_camera.zoom_in()
			zoomed_in = true

func fire_cutscene_bullet(number : int):
	cutscene_bullet[number].set_visible(true)
	cutscene_bullet[number].apply_central_impulse(CUTSCENE_BULLET_IMPULSE[number])

func play_dynamite():
	GlobalMusic.play("dynamite")

func update_spawn_time():
	# Starts at INITIAL_SPAWN_TIME
	# as we approach PEAK_VIRUSES_LEFT we also approach PEAK_SPAWN_TIME (which is at a minimum)
	# Then as we approach - viruses left from there we approach END_SPAWN_TIME
	var progress_through_phase
	if viruses_left < PEAK_VIRUSES_LEFT:
		progress_through_phase = (float(PEAK_VIRUSES_LEFT) - float(viruses_left)) / float(PEAK_VIRUSES_LEFT)
		spawn_time = lerp(PEAK_SPAWN_TIME, END_SPAWN_TIME, progress_through_phase)
	else:
		progress_through_phase = (float(VIRUS_TOTAL) - float(viruses_left)) / (float(VIRUS_TOTAL) - float(PEAK_VIRUSES_LEFT))
		spawn_time = lerp(INITIAL_SPAWN_TIME, PEAK_SPAWN_TIME, progress_through_phase)
	assert(spawn_time >= PEAK_SPAWN_TIME)
	# Also update viruses per shield
	progress_through_phase = (float(VIRUS_TOTAL) - float(viruses_left)) / float(VIRUS_TOTAL)
	virus_per_shield = lerp(INITIAL_VIRUS_PER_SHIELD, END_VIRUS_PER_SHIELD, progress_through_phase)
	assert(virus_per_shield >= END_VIRUS_PER_SHIELD)

func spawn_left():
	viruses_left -= 1
	var virus = virus_resource.instance()
	add_child(virus)
	virus.set_global_position(virus_spawn_pos_left)
	virus.set_direction(Vector2.RIGHT)

func spawn_shield_left():
	# NOTE: This should never be called because Teal would just die
	viruses_left -= 1
	var virus = virus_shield_resource.instance()
	add_child(virus)
	virus.set_global_position(virus_spawn_pos_left)
	virus.set_direction(Vector2.RIGHT)

func spawn_right():
	viruses_left -= 1
	var virus = virus_resource.instance()
	add_child(virus)
	virus.set_global_position(virus_spawn_pos_right)
	virus.set_direction(Vector2.LEFT)

func spawn_shield_right():
	viruses_left -= 1
	var virus = virus_shield_resource.instance()
	add_child(virus)
	virus.set_global_position(virus_spawn_pos_right)
	virus.set_direction(Vector2.LEFT)

func _on_VirusSpawnTimerLeft_timeout():
	if viruses_left > 0:
		spawn_left()
		update_spawn_time()
		virus_spawn_timer_left.start(spawn_time)

func _on_VirusSpawnTimerRight_timeout():
	# TODO: Shield stuff as well
	if viruses_left > 0:
		if viruses_until_shield > 0:
			# Spawn normal virus
			spawn_right()
			viruses_until_shield -= 1
			if viruses_until_shield > 0:
				virus_spawn_timer_right.start(spawn_time)
			else:
				var t = max(spawn_time, SHIELD_SPAWN_TIME)
				virus_spawn_timer_right.start(t)
		else:
			# Spawn shield virus
			spawn_shield_right()
			viruses_until_shield = virus_per_shield
			var t = max(spawn_time, SHIELD_SPAWN_TIME)
			virus_spawn_timer_right.start(t)

func _on_TealLastStand_death():
	restart()

func _on_tree_node_added(node):
	if node.is_in_group("creep"):
		node.connect("death", self, "_on_creep_death")

func _on_creep_death():
	viruses_alive -= 1
	last_stand_hud.set_viruses_remaining(viruses_alive)
	if viruses_alive <= 0:
		# TODO: end fight
		SceneTransition.fade(NEXT_LEVEL)

func start_battle():
	if zoomed_in:
		player_camera.zoom_out()
	player_camera.set_position(CAMERA_BATTLE_POSITION)
	player.set_input_locked(false)
	teal.start()
	teal_cutscene_sprite.set_visible(false)
	get_tree().connect("node_added", self, "_on_tree_node_added")
	viruses_alive = VIRUS_TOTAL
	last_stand_hud.set_viruses_remaining(viruses_alive)
	viruses_left -= initial_virus_carrier_left.start_viruses()
	viruses_left -= initial_virus_carrier_right.start_viruses()
	spawn_left()
	spawn_shield_right()
	virus_spawn_timer_left.start(spawn_time)
	virus_spawn_timer_right.start(SHIELD_SPAWN_TIME)
	last_stand_hud.show()
	set_cutscene_active(false)

func _on_cutscene_skip():
	call_deferred("cutscene_skip")

func cutscene_skip():
	GlobalMusic.play("dynamite", 0.2, 30.5, true)
	animation_player.play("cutscene_1")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	animation_player.play("cutscene_2")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	animation_player.play("cutscene_3")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	DialogueManager.cancel_dialogue()
	for creep in get_tree().get_nodes_in_group("creep"):
		creep.free()
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()
	start_battle()
