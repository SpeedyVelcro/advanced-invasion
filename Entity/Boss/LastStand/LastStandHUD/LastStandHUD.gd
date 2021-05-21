extends CanvasLayer

onready var label = $Label
onready var animation_player = $AnimationPlayer
const TEXT_POSTFIX = " Viruses Remaining"

func _ready():
	label.set_visible(false)

func show():
	animation_player.play("show")

func hide():
	animation_player.play("hide")

func set_viruses_remaining(val : int):
	label.set_text(String(val) + TEXT_POSTFIX)
