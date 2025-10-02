extends Node

signal device_changed(kind: String) # "kbm" | "pad" | "touch"

var current_device := "kbm"

func _ready():
	Input.set_use_accumulated_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		_set_device("kbm")
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_set_device("pad")
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		_set_device("touch")

func _set_device(kind: String) -> void:
	if kind != current_device:
		current_device = kind
		emit_signal("device_changed", kind)
