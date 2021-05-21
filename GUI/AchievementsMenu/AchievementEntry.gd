extends Control

export(NodePath) var title_label_path
onready var title_label = get_node(title_label_path)
export(NodePath) var description_label_path
onready var description_label = get_node(description_label_path)
export(NodePath) var icon_texture_rect_path
onready var icon_texture_rect = get_node(icon_texture_rect_path)
export(NodePath) var progress_bar_path
onready var progress_bar = get_node(progress_bar_path)
export(NodePath) var progress_label_path
onready var progress_label = get_node(progress_label_path)
export(NodePath) var sync_button_path
onready var sync_button = get_node(sync_button_path)

const GRAYSCALE_MATERIAL = preload("res://Shader/Grayscale/Grayscale.tres")

signal synced

func _on_SyncButton_pressed():
	emit_signal("synced")

func set_title(value : String):
	title_label.set_text(value)

func set_description(value : String):
	description_label.set_text(value)

func set_icon(texture : Texture):
	icon_texture_rect.set_texture(texture)

func set_locked(value : bool):
	if value:
		icon_texture_rect.set_material(GRAYSCALE_MATERIAL)
	else:
		icon_texture_rect.set_material(null)

func set_target_enabled(value):
	progress_bar.set_visible(value)

func set_progress(progress : float, target : float, decimal : int):
	progress_bar.set_max(target)
	progress_bar.set_value(progress)
	var progress_string = String(progress).pad_decimals(decimal)
	var target_string = String(target).pad_decimals(decimal)
	progress_label.set_text(progress_string + " / " + target_string)

func set_sync_enabled(value : bool):
	sync_button.set_disabled(not value)
