extends Level

@export var dialogue_1: Array[Dialogue] = []

@onready var explosion_area = $ExplosionArea
@onready var animation_player = $AnimationPlayer
@onready var player = $Player
const QUAKE_KNOCKBACK = Vector2(300, -250)

func _ready():
	DialogueManager.end_broadcast_signal.connect(_on_DialogueManager_end_broadcast)

func _on_ExplosionArea_body_entered(_body):
	# Known player due to mask
	explosion_area.set_deferred("monitoring", false)
	animation_player.play("cutscene_1")
	player.set_input_locked(true)
	player.hit(QUAKE_KNOCKBACK, 0)

func start_dialogue():
	GlobalMusic.play("invasion")
	DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			player.set_input_locked(false)
