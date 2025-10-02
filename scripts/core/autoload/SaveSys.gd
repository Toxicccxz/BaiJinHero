extends Node

func migrate_all() -> void:
	# 在这里做：创建保存目录、把旧版存档字段升级、读取设置并写回等
	await get_tree().process_frame
