class_name UIScalingSubViewport
extends SubViewport
## Viewport that scales its contents according to SV Options Menu UI scaling
## settings.
##
## The contents of this viewport will be scaled according to the UI scale set
## using SV Options Menu, provided that [member OptionsConfig.manage_ui_scaling]
## is true.
##
## Scaling is done by automatically adjusting
## [member size_2d_override] and [member size_2d_override_stretch], so you should
## not modify these properties at runtime. However, you may freely adjust them in
## the editor in order to preview your UI at the correct scale, as they will simply
## be overwritten when you run the game.
##
## [member size] is also managed automatically if [member OptionsConfig.manage_resolution]
## is true.
##
## This viewport should be displayed over the entire main viewport. The
## recommended way of doing this is to place it inside a [SubViewportContainer]
## with anchors set to "Full Rect". Note that [member SubViewportContainer.stretch]
## will need to be false so as not to interfere with this node's properties.
##
## NOTE: Since you will probably use this for user interfaces, it is likely you will
## want to set [member transparent_bg] to true, so that the game displays behind
## the UI.
# TODO: bool to optionally decide whether to set size to resolution (allows scaling for smaller non-fullscreen subviewports)
# TODO: check if [member oversampling] and [member oversampling_override] are worth changing

## Scale factor to scale UI by. Immediately adjusts [member size] and
## [member size_2d_override] when changed.
var ui_scale: float = 1.0:
	set(value):
		ui_scale = value
		_update_scaling_properties()
	get:
		return ui_scale

var _options_config: OptionsConfig
var _options: GameOptions


# Override
func _ready() -> void:
	_options_config = OptionsConfigProvider.get_config()
	_options = OptionsProvider.get_local_options()
	_options.option_modified.connect(_on_options_option_modifed)
	
	if _options_config.manage_resolution:
		_update_resolution()
	
	if _options_config.manage_ui_scaling:
		var option_value = _options.get_option(_options_config.ui_scale_option_path)
		_set_ui_scale_from_variant(option_value)


func _set_ui_scale_from_variant(value: Variant) -> void:
	if value is not float:
		push_error("UI Scale option was not a float")
		return
	
	ui_scale = value


func _update_resolution() -> void:
	var x = _options.get_option(_options_config.get_resolution_x_path())
	var y = _options.get_option(_options_config.get_resolution_y_path())
	
	if not ((x is int or x is float) and (y is int or y is float)):
		push_error("Resolution option is unset or wrong type. Cannot adjust UIScalingSubViewport size.")
		return
	
	size = Vector2i(int(x), int(y))
	
	_update_scaling_properties()


func _update_scaling_properties() -> void:
	size_2d_override = size / ui_scale
	size_2d_override_stretch = true


# Signal connection
func _on_options_option_modifed(path: String, new_value: Variant) -> void:
	if _options_config.manage_ui_scaling:
		if path == _options_config.ui_scale_option_path:
			_set_ui_scale_from_variant(new_value)
	
	if _options_config.manage_resolution:
		if path.begins_with(_options_config.resolution_option_path):
			_update_resolution()
