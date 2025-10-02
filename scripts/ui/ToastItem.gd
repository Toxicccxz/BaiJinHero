extends Control
@onready var label := $Panel/Label

func set_text(t: String) -> void: label.text = t

func play_and_wait(duration: float) -> void:
	modulate.a = 0.0
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.18)
	t.tween_interval(duration)
	t.tween_property(self, "modulate:a", 0.0, 0.18)
	await t.finished
