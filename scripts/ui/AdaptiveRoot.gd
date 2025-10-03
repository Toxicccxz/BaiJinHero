extends Control
@export var desktop_reference := Vector2i(1920, 1080)
@onready var right_gutter := $RightGutter if has_node("RightGutter") else null

func _has_autoload(name: String) -> bool:
	return get_tree().get_root().has_node(name)

func _ready() -> void:
	_apply_safe_area()
	_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout()

func _layout() -> void:
	var sz := get_viewport_rect().size
	var w: float = float(sz.x)
	var h: float = float(sz.y)
	var aspect: float = w / max(1.0, h)   # 两个参数同为 float，返回就是 float

	if right_gutter:
		right_gutter.visible = aspect >= 1.6  # ≥16:10 展开侧栏；窄屏折叠

func _apply_safe_area():
	var platform := get_tree().get_root().get_node("Platform") if _has_autoload("Platform") else null
	if platform and platform.has_method("device_type") and platform.device_type != "desktop":
		var r := DisplayServer.get_display_safe_area()
		# 根据 r 对 UI 容器设置 margin/padding
