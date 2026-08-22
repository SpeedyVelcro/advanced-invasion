extends Level

@export var dialogue_1: Array[Dialogue] = []
@onready var dialogue_area = $DialogueArea

func _ready():
	super()
	
	DialogueManager.end_broadcast_signal.connect(_on_DialogueManager_end_broadcast)
	DialogueManager.connect("broadcast", Callable(self, "_on_DialogueManager_broadcast"))

func _on_DialogueManager_end_broadcast(message):
	match message:
		"dialogue_1":
			player.set_input_locked(false)
			GlobalMusic.play("militia")

func _on_DialogueManager_broadcast(message):
	match message:
		"":
			pass

func _on_DialogueArea_body_entered(_body):
	# Known to be player due to collision mask
	player.set_input_locked(true)
	DialogueManager.queue_dialogue(dialogue_1, "dialogue_1")
	dialogue_area.set_deferred("monitoring", false)
	GlobalMusic.stop(2.0)
