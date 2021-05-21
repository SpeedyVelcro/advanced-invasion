# SceneTransition.gd

extends Node

var next_scene
var next_in_time_sec

func _ready():
	$AnimationPlayer/CanvasLayer/ColorRect.set_visible(false)

func instant(scene: String):
	get_tree().change_scene(scene)
	get_tree().set_pause(false)
	DialogueManager.cancel_dialogue(true)

func fade(scene : String, out_time_sec : float = 0.5, in_time_sec : float = 0.5):
	next_scene = scene
	next_in_time_sec = in_time_sec
	if out_time_sec > 0.0:
		$AnimationPlayer.play("fade_out")
		$AnimationPlayer.set_speed_scale(1 / out_time_sec)
	else:
		_fade_in(next_scene, next_in_time_sec)

func _fade_in(scene : String, time_sec : float = 0.5):
	get_tree().change_scene(next_scene)
	DialogueManager.cancel_dialogue(true)
	$AnimationPlayer.play("fade_in")
	if time_sec > 0:
		$AnimationPlayer.set_speed_scale(1 / next_in_time_sec)
	else:
		$AnimationPlayer.seek($AnimationPlayer.get_current_animation_length(), true)
	get_tree().set_pause(false)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade_out":
			_fade_in(next_scene, next_in_time_sec)
