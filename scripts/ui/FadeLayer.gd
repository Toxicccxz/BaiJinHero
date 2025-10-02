extends ColorRect
@export var fade_time := 0.35

func fade_out() -> void:
	visible = true
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, fade_time)
	await t.finished

func fade_in() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, fade_time)
	await t.finished
	visible = false
