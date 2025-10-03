extends Node

# —— 首次运行持久化标记（保存在用户数据目录）——
const FIRST_RUN_FLAG_PATH := "user://first_run.done"

func _is_first_run() -> bool:
	return not FileAccess.file_exists(FIRST_RUN_FLAG_PATH)

func _mark_first_run_done() -> void:
	var f := FileAccess.open(FIRST_RUN_FLAG_PATH, FileAccess.WRITE)
	if f:
		f.store_string("ok")
		f.close()

# —— Autoload 工具函数 ——
func _has_autoload(name: String) -> bool:
	return get_tree().get_root().has_node(name)

func _get_autoload(name: String) -> Node:
	return get_tree().get_root().get_node(name) if _has_autoload(name) else null

@onready var ui_root       : CanvasLayer = $UIRoot
@onready var adaptive_root : Control     = $UIRoot/AdaptiveRoot
@onready var fade_layer    : ColorRect   = $UIRoot/AdaptiveRoot/FadeLayer
@onready var loading       : Control     = $UIRoot/AdaptiveRoot/LoadingOverlay
@onready var toast_layer   : Control     = $UIRoot/AdaptiveRoot/ToastLayer
@onready var system_menu   : Control     = $UIRoot/AdaptiveRoot/SystemMenu
@onready var input_hint    : Control     = $UIRoot/AdaptiveRoot/InputHint

func _ready() -> void:
	# —— UI 缩放（桌面=1.0；移动=1.25~1.75）——
	var platform := _get_autoload("Platform")
	if platform and platform.has_method("get_ui_scale"):
		var s: float = platform.call("get_ui_scale")
		adaptive_root.scale = Vector2(s, s)

	# —— 将全局层交给 SceneRouter 统一使用（存在则绑定）——
	if _has_autoload("SceneRouter"):
		SceneRouter.bind_layers({
			"fade": fade_layer,
			"loading": loading,
			"toast": toast_layer
		})
	else:
		push_warning("[Main] SceneRouter 未注册为 Autoload，转场将使用引擎默认切换。")

	# —— 绑定系统菜单信号 ——
	system_menu.connect("request_resume",     Callable(self, "_on_menu_resume"))
	system_menu.connect("request_settings",   Callable(self, "_on_menu_settings"))
	system_menu.connect("request_goto_title", Callable(self, "_on_menu_goto_title"))
	system_menu.connect("request_quit",       Callable(self, "_on_menu_quit"))

	# —— 输入设备提示（InputHub Autoload） ——
	var input_hub := _get_autoload("InputHub")
	if input_hub:
		input_hub.connect("device_changed", Callable(input_hint, "set_device"))

	# —— 启动路由：首次进 Boot，之后直接进 Title ——
	var force_boot := Input.is_key_pressed(KEY_SHIFT)  # 按住 SHIFT 强制走 Boot（可选）
	if _is_first_run() or force_boot:
		# 进入 Boot（Boot 完成后会自己切到 Title）
		if _has_autoload("SceneRouter"):
			await SceneRouter.goto_scene("res://app/Boot.tscn")
		else:
			get_tree().change_scene_to_file("res://app/Boot.tscn")
		_mark_first_run_done()  # 写入“已完成首次运行”标记
	else:
		# 非首次：直接进标题
		if _has_autoload("SceneRouter"):
			await SceneRouter.goto_title()
		else:
			get_tree().change_scene_to_file("res://app/TitleScreen.tscn")

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		_toggle_system_menu()

func _toggle_system_menu() -> void:
	var vis := system_menu.is_visible_in_tree()
	system_menu.visible = not vis
	get_tree().paused = not vis

# —— 菜单回调 ——
func _on_menu_resume() -> void:
	_toggle_system_menu()

func _on_menu_settings() -> void:
	if _has_autoload("SceneRouter"):
		SceneRouter.toast("Settings TBD")

func _on_menu_goto_title() -> void:
	get_tree().paused = false
	system_menu.visible = false
	if _has_autoload("SceneRouter"):
		await SceneRouter.goto_title()
	else:
		get_tree().change_scene_to_file("res://app/TitleScreen.tscn")

func _on_menu_quit() -> void:
	get_tree().paused = false
	get_tree().quit()
