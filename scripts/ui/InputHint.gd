extends Control
@onready var kbm  := $KBM
@onready var pad  := $Gamepad
@onready var touch:= $Touch

func set_device(kind: String) -> void:
	kbm.visible   = (kind == "kbm")
	pad.visible   = (kind == "pad")
	touch.visible = (kind == "touch")
