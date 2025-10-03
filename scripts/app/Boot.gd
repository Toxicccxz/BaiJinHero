extends Control

@export var next_scene: String = "res://app/TitleScreen.tscn"
@export var show_skip_hint: bool = true
@export var min_show_seconds: float = 0.8          # 最短展示时间（避免闪屏）
@export var poll_timeout_seconds: float = 10.0     # 线程加载轮询超时（防死等）

@onready var _bar   : ProgressBar = $VBox/Bar
@onready var _tip   : Label       = $VBox/Tip
@onready var _logo  : TextureRect = $VBox/Logo
@onready var _build : Label       = $Footer/BuildLabel

var _start_time := 0.0
var _requests: Array[String] = []
var _started := false
var _skipped := false

# —— Autoload 工具 —— 
func _has_autoload(name: String) -> bool:
	return get_tree().get_root().has_node(name)

func _ready() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
	if _build:
		_build.text = "Build: %s  |  %s" % [ProjectSettings.get_setting("application/config/version", "dev"), OS.get_name()]
	if _tip:
		_tip.visible = show_skip_hint

	_prepare_preload_list()
	await _kickoff()

func _unhandled_input(event: InputEvent) -> void:
	if show_skip_hint and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept")):
		_skipped = true

# 1) 准备预热清单
func _prepare_preload_list() -> void:
	_requests = [
		"res://ui/theme/default_theme.tres",
		"res://art/fonts/NotoSans.tres",
		"res://sfx/ui/click.ogg",
		"res://sfx/ui/confirm.ogg",
		# 需要的话再加你真实存在的场景/资源路径
		# "res://features/exploration/scenes/World_01.tscn",
		# "res://features/battle/BattleScene.tscn",
	]
	# 过滤不存在的路径，避免永远等不到
	_requests = _requests.filter(func(p): return ResourceLoader.exists(p))

# 2) 启动流程（存档迁移 + 线程预热 + 跳转）
func _kickoff() -> void:
	if _started: return
	_started = true
	if _bar: _bar.value = 0.0

	# 2.1 存档迁移（可选，存在则执行）
	if _has_autoload("SaveSys") and SaveSys.has_method("migrate_all"):
		await SaveSys.migrate_all()

	# 2.2 如果清单为空，直接收尾跳转
	if _requests.is_empty():
		await _finish_and_goto()
		return

	# 2.3 发起线程加载
	for path in _requests:
		ResourceLoader.load_threaded_request(path)

	# 2.4 轮询直到完成/跳过/超时
	await _poll_until_done()
	await _finish_and_goto()

# 收尾 + 跳转
func _finish_and_goto() -> void:
	# 保证最短展示时间
	var elapsed := float(Time.get_ticks_msec()) / 1000.0 - _start_time
	if elapsed < min_show_seconds:
		await get_tree().create_timer(min_show_seconds - elapsed).timeout

	# 路径校验，避免跳转到不存在的场景导致黑屏
	if not ResourceLoader.exists(next_scene):
		push_error("[Boot] next_scene 不存在：%s" % next_scene)
		if _has_autoload("SceneRouter"):
			SceneRouter.toast("next_scene not found")
		get_tree().quit()
		return

	if _has_autoload("SceneRouter"):
		await SceneRouter.goto_scene(next_scene)
	else:
		get_tree().change_scene_to_file(next_scene)

# 3) 进度轮询（更新 ProgressBar）
func _poll_until_done() -> void:
	var total := _requests.size()
	if total == 0:
		return  # 双保险

	var begin := Time.get_ticks_msec() / 1000.0

	while true:
		# 用户跳过：直接拉满进度并返回
		if _skipped:
			if _bar: _bar.value = 100.0
			return

		var done := 0
		for path in _requests:
			var st := ResourceLoader.load_threaded_get_status(path)
			# 认为“已加载/失败”都算完成，避免卡死
			if st == ResourceLoader.THREAD_LOAD_LOADED or st == ResourceLoader.THREAD_LOAD_FAILED:
				done += 1

		if _bar:
			_bar.value = float(done) / float(total) * 100.0

		# 全部完成
		if done >= total:
			return

		# 超时保护
		var now := Time.get_ticks_msec() / 1000.0
		if poll_timeout_seconds > 0.0 and (now - begin) >= poll_timeout_seconds:
			push_warning("[Boot] 预热超时，继续流程（可能某些资源未完成加载）")
			return

		await get_tree().process_frame
