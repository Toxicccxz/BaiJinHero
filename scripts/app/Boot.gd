extends Control

## === 可配置导出 ===
@export var next_scene: String = "res://app/TitleScreen.tscn"   # 预热完成后要去的场景
@export var show_skip_hint: bool = true
@export var min_show_seconds: float = 0.8                        # 最短展示时间（避免闪屏）

## === 节点引用 ===
@onready var _bar : ProgressBar  = $VBox/Bar
@onready var _tip : Label        = $VBox/Tip
@onready var _logo: TextureRect  = $VBox/Logo
@onready var _build: Label       = $Footer/BuildLabel

## === 线程/状态 ===
var _start_time : float = 0.0
var _requests   : Array[String] = []         # 需要Threaded预热的资源路径列表
var _started    : bool = false
var _skipped    : bool = false

func _ready() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
	_build.text = "Build: %s  |  %s" % [ProjectSettings.get_setting("application/config/version", "dev"), OS.get_name()]
	_tip.visible = show_skip_hint
	_prepare_preload_list()
	_kickoff()

func _unhandled_input(event: InputEvent) -> void:
	if show_skip_hint and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept")):
		_skipped = true

## 1) 准备预热清单（按需替换为你的资源路径）
func _prepare_preload_list() -> void:
	_requests = [
		"res://ui/theme/default_theme.tres",
		"res://art/fonts/NotoSans.tres",
		"res://sfx/ui/click.ogg",
		"res://sfx/ui/confirm.ogg",
		"res://features/exploration/scenes/World_01.tscn",   # 首地图（可选）
		"res://features/battle/BattleScene.tscn"             # 战斗场景（可选）
	]

## 2) 启动流程（存档迁移 + 线程预热 + 跳转）
func _kickoff() -> void:
	if _started: return
	_started = true
	_bar.value = 0.0

	# 2.1 迁移/初始化（可在这里做异步IO，如读取设置、迁移存档）
	if Engine.has_singleton("SaveSys"):
		await SaveSys.migrate_all()

	# 2.2 线程预热 ResourceLoader（非阻塞）
	for path in _requests:
		if not ResourceLoader.exists(path): continue
		ResourceLoader.load_threaded_request(path)

	# 2.3 轮询进度直到完成或用户跳过
	await _poll_until_done()

	# 2.4 等待最短展示时间，避免一闪而过
	var elapsed: float = float(Time.get_ticks_msec()) / 1000.0 - _start_time
	if elapsed < min_show_seconds:
		await get_tree().create_timer(min_show_seconds - elapsed).timeout

	# 2.5 跳转到标题
	if Engine.has_singleton("SceneRouter"):
		await SceneRouter.goto_scene(next_scene)
	else:
		get_tree().change_scene_to_file(next_scene)

## 3) 进度轮询（更新 ProgressBar）
func _poll_until_done() -> void:
	var total: int = int(max(1, _requests.size()))
	while true:
		if _skipped:
			_bar.value = 100.0
			return

		var done: int = 0
		for path in _requests:
			var st: int = ResourceLoader.load_threaded_get_status(path)
			if st == ResourceLoader.THREAD_LOAD_LOADED:
				done += 1
			elif st == ResourceLoader.THREAD_LOAD_FAILED:
				done += 1

		var progress: float = float(done) / float(total)
		_bar.value = progress * 100.0

		if done >= total:
			return

		await get_tree().process_frame
