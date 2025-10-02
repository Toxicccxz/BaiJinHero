extends Node
var _fade    : Node = null
var _loading : Node = null
var _toast   : Node = null

func bind_layers(layers: Dictionary) -> void:
	_fade    = layers.get("fade")
	_loading = layers.get("loading")
	_toast   = layers.get("toast")

func goto_title() -> void:
	await _fade_call("fade_out")
	get_tree().change_scene_to_file("res://app/TitleScreen.tscn")
	await get_tree().process_frame
	await _fade_call("fade_in")

func goto_scene(path: String) -> void:
	await _fade_call("fade_out")
	_loading_call("show_loading")
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	_loading_call("hide_loading")
	await _fade_call("fade_in")

func toast(msg: String) -> void:
	if _toast and _toast.has_method("show_toast"):
		_toast.call("show_toast", msg)

func _fade_call(fn: String) -> void:
	if _fade and _fade.has_method(fn): await _fade.call(fn)

func _loading_call(fn: String) -> void:
	if _loading and _loading.has_method(fn): _loading.call(fn)
