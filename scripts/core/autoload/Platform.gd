extends Node

var device_type := "desktop"  # desktop | mobile | tablet

func _ready():
	var os_name = OS.get_name()
	if os_name in ["Android","iOS"]:
		device_type = "mobile"
	elif DisplayServer.screen_get_dpi() > 180 and OS.has_feature("touchscreen"):
		device_type = "tablet"

func get_ui_scale() -> float:
	match device_type:
		"desktop": return 1.0
		"tablet":  return 1.25
		"mobile":  return 1.5
		_ :        return 1.0
