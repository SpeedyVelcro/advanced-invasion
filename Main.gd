extends Node

var first_scene_path = "res://GUI/MainMenu/MainMenu.tscn"

func _ready():
	SceneTransition.fade(first_scene_path, 0.0, 1.0)
