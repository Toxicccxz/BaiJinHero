extends Node

@onready var ui_root       : CanvasLayer = $UIRoot
@onready var adaptive_root : Control     = $UIRoot/AdaptiveRoot
@onready var fade_layer    : ColorRect   = $UIRoot/AdaptiveRoot/FadeLayer
@onready var loading       : Control     = $UIRoot/AdaptiveRoot/LoadingOverlay
@onready var toast_layer   : Control     = $UIRoot/AdaptiveRoot/ToastLayer
@onready var system_menu   : Control     = $UIRoot/AdaptiveRoot/SystemMenu
@onready var input_hint    : Control     = $UIRoot/AdaptiveRoot/InputHint

func _ready() -> void:
	# UI 缩放（桌面=1.0；移动=1.25~1.75）
	if Engine.has_singleton("Platform"):
		adaptive_root.scale = Vector2(Platform.get_ui_scale(), Platform.get_ui_scale())

	# 将全局层交给 SceneRouter 统一使用
	SceneRouter.bind_layers({
		"fade": fade_layer,
		"loading": loading,
		"toast": toast_layer
	})

	# 绑定系统菜单信号
	system_menu.connect("request_resume",       Callable(self, "_on_menu_resume"))
	system_menu.connect("request_settings",     Callable(self, "_on_menu_settings"))
	system_menu.connect("request_goto_title",   Callable(self, "_on_menu_goto_title"))
	system_menu.connect("request_quit",         Callable(self, "_on_menu_quit"))

	# 输入设备提示
	if Engine.has_singleton("InputHub"):
		InputHub.connect("device_changed", Callable(input_hint, "set_device"))

	# 进入标题场景
	await SceneRouter.goto_title()

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		_toggle_system_menu()

func _toggle_system_menu() -> void:
	var vis := system_menu.is_visible_in_tree()
	system_menu.visible = not vis
	get_tree().paused = not vis

# —— 菜单回调 ——
func _on_menu_resume() -> void: _toggle_system_menu()
func _on_menu_settings() -> void: SceneRouter.toast("Settings TBD")
func _on_menu_goto_title() -> void:
	get_tree().paused = false
	system_menu.visible = false
	await SceneRouter.goto_title()
func _on_menu_quit() -> void:
	get_tree().paused = false
	get_tree().quit()
