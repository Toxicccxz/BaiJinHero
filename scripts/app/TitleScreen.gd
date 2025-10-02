extends Control

@onready var btn_start     : Button = $Center/Menu/BtnStart
@onready var btn_continue  : Button = $Center/Menu/BtnContinue
@onready var btn_settings  : Button = $Center/Menu/BtnSettings
@onready var btn_quit      : Button = $Center/Menu/BtnQuit
@onready var version_label : Label  = $Version

# 下一步要进入的游戏场景（可换成你的探索首图）
@export var first_map_scene: String = "res://features/exploration/scenes/World_01.tscn"

func _ready() -> void:
	version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version", "dev")

	btn_start.pressed.connect(_on_start)
	btn_continue.pressed.connect(_on_continue)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)

	# 播标题BGM（如果你有 AudioHub 单例）
	if Engine.has_singleton("AudioHub"):
		var bgm := load("res://sfx/bgm/title.ogg")
		if bgm: AudioHub.play_bgm(bgm)

	# 是否有可继续的存档（按需替换为你的检测逻辑）
	var has_save := false
	if Engine.has_singleton("SaveSys"):
		has_save = SaveSys.has_any_save() if SaveSys.has_method("has_any_save") else false
	btn_continue.disabled = not has_save

func _on_start() -> void:
	# 可在这里初始化一次新游戏的 GameState
	if Engine.has_singleton("GameState") and GameState.has_method("new_game"):
		GameState.new_game()
	await SceneRouter.goto_scene(first_map_scene)

func _on_continue() -> void:
	if Engine.has_singleton("SaveSys") and SaveSys.has_method("load_latest"):
		var payload := await SaveSys.load_latest()
		if payload and payload.has("last_scene"):
			await SceneRouter.goto_scene(payload["last_scene"])
			return
	# 没存档则走 Start
	await _on_start()

func _on_settings() -> void:
	SceneRouter.toast("Settings TBD")

func _on_quit() -> void:
	get_tree().quit()
