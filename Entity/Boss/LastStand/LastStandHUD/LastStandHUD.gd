extends CanvasLayer

@onready var label = $SubViewportContainer/UIScalingSubViewport/Label
@onready var animation_player = $SubViewportContainer/UIScalingSubViewport/AnimationPlayer
const TEXT_POSTFIX = " Viruses Remaining"

func _ready():
	label.set_visible(false)

@warning_ignore("native_method_override") # TODO: rename
func show():
	animation_player.play("show")

@warning_ignore("native_method_override") # TODO: rename
func hide():
	animation_player.play("hide")

func set_viruses_remaining(val : int):
	label.set_text(str(val) + TEXT_POSTFIX)
