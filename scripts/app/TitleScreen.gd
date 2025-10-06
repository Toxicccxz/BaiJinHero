extends Control

@onready var btn_start     : Button = $Center/Menu/BtnStart
@onready var btn_continue  : Button = $Center/Menu/BtnContinue
@onready var btn_settings  : Button = $Center/Menu/BtnSettings
@onready var btn_quit      : Button = $Center/Menu/BtnQuit
@onready var version_label : Label  = $Version

@export var first_map_scene: String = "res://features/exploration/scenes/World_01.tscn"

func _ready() -> void:
	print("[Title] ready")
	version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version", "dev")

	btn_start.pressed.connect(_on_start)
	btn_continue.pressed.connect(_on_continue)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)

	# —— Debug：看看 Autoload 是否在 /root 挂上了 ——
	print("TitleScreen ready; has /root/AudioHub? ",
		get_tree().get_root().has_node("AudioHub"))

	# 播标题BGM（Autoload 直接用全局名访问）
	var bgm_path := "res://sfx/bgm/title.ogg"
	if ResourceLoader.exists(bgm_path) and get_tree().get_root().has_node("AudioHub"):
		var bgm := load(bgm_path)
		if bgm:
			AudioHub.play_bgm(bgm)
			print("xavier: play bgm")

	# 是否有可继续的存档
	var has_save := false
	if get_tree().get_root().has_node("SaveSys") and SaveSys.has_method("has_any_save"):
		has_save = SaveSys.has_any_save()
	btn_continue.disabled = not has_save

func _on_start() -> void:
	if get_tree().get_root().has_node("GameState") and GameState.has_method("new_game"):
		GameState.new_game()
	await SceneRouter.goto_scene(first_map_scene)

func _on_continue() -> void:
	if get_tree().get_root().has_node("SaveSys") and SaveSys.has_method("load_latest"):
		var payload: Dictionary = await SaveSys.load_latest()
		if payload and payload.has("last_scene"):
			await SceneRouter.goto_scene(payload["last_scene"])
			return
	await _on_start()

func _on_settings() -> void:
	SceneRouter.toast("Settings TBD")

func _on_quit() -> void:
	get_tree().quit()
