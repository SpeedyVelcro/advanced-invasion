extends Level

@export var dialogue_1: Array[Dialogue] = []
@export var dialogue_2: Array[Dialogue] = []
@export var dialogue_3: Array[Dialogue] = []
@export var dialogue_4: Array[Dialogue] = []
@export var dialogue_5: Array[Dialogue] = []

const NEXT_SCENE = "res://Level/02Underbelly/10Boss.tscn"
const CAMPFIRE_END_BROADCAST := "campfire_end"

@onready var player_camera: CameraPlayer = $Player/CameraPlayer
@onready var teal: TealSanctuary = $TealSanctuary
@onready var cutscene_timer: Timer = $CutsceneTimer
@onready var campfire_particles: CPUParticles2D = $CampfireCPUParticles2D
var cutscene_timer_for: CutsceneTimerFor = CutsceneTimerFor.NONE
var lighting_fire_stage: int = 0
var dialogue_2_triggered := false
var dialogue_3_triggered := false
var teal_cutscene_spot_triggered := false
var player_cutscene_spot_triggered := false

enum CutsceneTimerFor {
	NONE,
	TEAL_MEETS_YELLOW,
	TEAL_STARTING_FIRE,
	CAMPFIRE_PAUSE,
	TEAL_WHAT,
	TEAL_COME_ON
}


# Override
func _ready():
	super()
	
	DialogueManager.end_broadcast_signal.connect(_on_dialogue_manager_end_broadcast)
	DialogueManager.broadcast.connect(_on_dialogue_manager_broadcast)


# Signal connection
func _on_dialogue_manager_end_broadcast(message: String):
	match message:
		"1_end":
			player_camera.position = Vector2.ZERO
			player.input_locked = false
			player_camera.input_enabled = true
			cutscene_timer.stop()
			cutscene_timer_for = CutsceneTimerFor.NONE
			teal.change_state(teal.State.LEADING)
			GlobalMusic.play("sanctuary")
		CAMPFIRE_END_BROADCAST:
			cutscene_active = true
			GlobalMusic.stop(4.0)
			cutscene_timer_for = CutsceneTimerFor.CAMPFIRE_PAUSE
			cutscene_timer.one_shot = true
			cutscene_timer.start(6.0)
		"final_end":
			teal.change_state(teal.State.LEADING)
			player_camera.position = Vector2.ZERO
			player.input_locked = false
			player_camera.input_enabled = true
			cutscene_timer.stop()
			cutscene_timer_for = CutsceneTimerFor.NONE
			campfire_particles.emitting = false
			set_cutscene_active(false)


func final_cutscene_end() -> void:
	teal.change_state(teal.State.LEADING)
	player_camera.position = Vector2.ZERO
	player.input_locked = false
	player_camera.input_enabled = true
	cutscene_timer.stop()
	cutscene_timer_for = CutsceneTimerFor.NONE
	campfire_particles.emitting = false
	set_cutscene_active(false)
	DialogueManager.cancel_dialogue()
	if GlobalMusic.get_current_music_id() != "invasion":
		GlobalMusic.play("invasion")


# Signal connection
func _on_dialogue_manager_broadcast(message: String):
	match message:
		"teal_what":
			cutscene_timer_for = CutsceneTimerFor.TEAL_WHAT
			cutscene_timer.one_shot = true
			cutscene_timer.start(0.4)
			teal.moving = true
			teal.facing = Vector2.RIGHT
		"teal_come_on":
			cutscene_timer_for = CutsceneTimerFor.TEAL_COME_ON
			cutscene_timer.one_shot = true
			cutscene_timer.start(0.4)
			teal.moving = true
			teal.facing = Vector2.LEFT


# Override
func _on_cutscene_skip():
	final_cutscene_end()


# Signal connection
func _on_virus_pawn_death() -> void:
	player_camera.global_position = teal.global_position
	player_camera.global_position.x -= 256
	player.input_locked = true
	player_camera.input_enabled = false
	DialogueManager.queue_dialogue(dialogue_1, "1_end")
	cutscene_timer.one_shot = true
	cutscene_timer.start(2.0)
	cutscene_timer_for = CutsceneTimerFor.TEAL_MEETS_YELLOW
	teal.moving = true
	teal.facing = Vector2.LEFT


# Signal connection
func _on_cutscene_timer_timeout() -> void:
	match cutscene_timer_for:
		CutsceneTimerFor.TEAL_MEETS_YELLOW:
			cutscene_timer_for = CutsceneTimerFor.NONE
			teal.moving = false
		CutsceneTimerFor.TEAL_STARTING_FIRE:
			match lighting_fire_stage:
				0:
					teal.moving = true
					teal.facing = Vector2.LEFT
					cutscene_timer.start(0.3)
				1:
					teal.moving = false
					cutscene_timer.start(1.0)
				2:
					campfire_particles.emitting = true
					cutscene_timer.start(1.5)
				3:
					teal.moving = true
					teal.facing = Vector2.RIGHT
					cutscene_timer.start(0.4)
				4:
					teal.moving = false
					cutscene_timer.start(0.3)
				5:
					teal.moving = true
					teal.facing = Vector2.LEFT
					cutscene_timer.start(0.1)
				6:
					teal.moving = false
					if player.input_locked: # Player has already reached their spot, so now waiting for us to start the dialogue.
						DialogueManager.queue_dialogue(dialogue_4, CAMPFIRE_END_BROADCAST)
			lighting_fire_stage += 1
		CutsceneTimerFor.CAMPFIRE_PAUSE:
			end_campfire_pause()
		CutsceneTimerFor.TEAL_WHAT:
			teal.moving = false
		CutsceneTimerFor.TEAL_COME_ON:
			teal.moving = false


func end_campfire_pause() -> void:
	cutscene_timer.stop()
	cutscene_timer_for = CutsceneTimerFor.NONE
	GlobalMusic.play("invasion")
	DialogueManager.queue_dialogue(dialogue_5, "final_end")


# Signal connection
func _on_dialogue_2_area_2d_body_entered(_body: Node2D) -> void:
	if not dialogue_2_triggered:
		DialogueManager.queue_dialogue(dialogue_2)
		dialogue_2_triggered = true


# Signal connection
func _on_safe_cave_entrance_area_2d_body_entered(_body: Node2D) -> void:
	if not dialogue_3_triggered:
		DialogueManager.queue_dialogue(dialogue_3)
		dialogue_3_triggered = true


# Signal connection
func _on_player_cutscene_spot_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	if player_cutscene_spot_triggered:
		return
	
	player_cutscene_spot_triggered = true
	
	player.input_locked = true
	player_camera.input_enabled = false
	player_camera.global_position = campfire_particles.global_position
	player_camera.position.y -= 64
	set_cutscene_active(true)
	if campfire_particles.emitting: # Only start the dialogue if fire is lit. Otherwise it will be the fire-lighting timer's responsibility.
		DialogueManager.queue_dialogue(dialogue_4, CAMPFIRE_END_BROADCAST)


# Signal connection
func _on_teal_cutscene_spot_area_2d_body_entered(body: Node2D) -> void:
	if body is not TealSanctuary:
		return
	
	if teal_cutscene_spot_triggered:
		return
	
	teal_cutscene_spot_triggered = true
	
	teal.state = teal.State.NONE
	teal.moving = false
	
	cutscene_timer_for = CutsceneTimerFor.TEAL_STARTING_FIRE
	cutscene_timer.one_shot = true
	cutscene_timer.start(0.2)
