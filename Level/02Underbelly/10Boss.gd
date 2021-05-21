extends Level

export(Array, Resource) var dialogue_1 = []
export(Array, Resource) var dialogue_2 = []

onready var animation_player = $AnimationPlayer
onready var player = $Player
onready var boss = $SquareVirus
onready var barrier_right = $BarrierRight
onready var creep_resource = preload("res://Entity/Creep/VirusPawn/Variants/VirusShieldPawn.tscn")
onready var creep_spawn_location = [
	$Portal.get_global_position(),
	$Portal2.get_global_position(),
	$Portal3.get_global_position()
]
var cutscene_stage = 0
var rng = RandomNumberGenerator.new()
var remaining_viruses = 0

func _ready():
	$Portal.set_visible(false)
	$Portal2.set_visible(false)
	$Portal3.set_visible(false)
	DialogueManager.connect("finished", self, "_on_DialogueManager_finished")
	animation_player.play("cutscene_1")
	rng.randomize()

func _on_DialogueManager_finished():
	match cutscene_stage:
		0:
			cutscene_stage = 1
			animation_player.play("cutscene_2")
			GlobalMusic.stop(6.0)
		1:
			start_boss()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"cutscene_1":
			DialogueManager.queue_dialogue(dialogue_1)
		"cutscene_2":
			DialogueManager.queue_dialogue(dialogue_2)
		"cutscene_3":
			player.set_input_locked(false)
			boss.start()

func spawn_viruses():
	for pos in creep_spawn_location:
		var new_creep = creep_resource.instance()
		add_child(new_creep)
		new_creep.set_global_position(pos)
		if rng.randf() > 0.5:
			new_creep.set_direction(Vector2.RIGHT)
		else:
			new_creep.set_direction(Vector2.LEFT)
		remaining_viruses += 1
		new_creep.connect("death", self, "_on_creep_death")

func _on_SquareVirus_hang_back():
	animation_player.play("spawn_virus")

func _on_creep_death():
	remaining_viruses -= 1
	if remaining_viruses <= 0:
		boss.return_to_fight()

func _on_SquareVirus_death():
	barrier_right.disable()
	$LevelHUD.hide_boss_health()

func start_boss():
	set_cutscene_active(false)
	cutscene_stage = 2
	animation_player.play("cutscene_3")
	GlobalMusic.play("brash")
	$LevelHUD.show_boss_health()

func _on_cutscene_skip():
	animation_player.play("cutscene_1")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	animation_player.play("cutscene_2")
	animation_player.seek(animation_player.get_current_animation_length(), true)
	animation_player.stop()
	DialogueManager.cancel_dialogue()
	start_boss()
