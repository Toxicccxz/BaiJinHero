extends Node

## —— 全局游戏状态（运行时常驻）——

# 玩家基础信息（示例）
var player_name: String = "Hero"
var level: int = 1
var hp: int = 100
var mp: int = 30

# 当前所在场景（默认空）
var current_scene: String = ""

# 标记是否是新游戏
var is_new_game: bool = false

# 初始化新游戏状态
func new_game() -> void:
	print("[GameState] 初始化新游戏")
	player_name = "Hero"
	level = 1
	hp = 100
	mp = 30
	current_scene = ""  # 可以在 Start Game 时设置成 first_map_scene
	is_new_game = true

# 存档数据导出为 Dictionary
func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"level": level,
		"hp": hp,
		"mp": mp,
		"current_scene": current_scene
	}

# 从存档数据恢复
func from_dict(data: Dictionary) -> void:
	if data.has("player_name"): player_name = data["player_name"]
	if data.has("level"): level = data["level"]
	if data.has("hp"): hp = data["hp"]
	if data.has("mp"): mp = data["mp"]
	if data.has("current_scene"): current_scene = data["current_scene"]
	is_new_game = false
