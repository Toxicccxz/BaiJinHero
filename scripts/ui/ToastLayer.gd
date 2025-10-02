extends Control
const TOAST_SCENE := preload("res://ui/ToastItem.tscn")
@onready var stack := $ToastStack

func show_toast(text: String, duration := 1.8) -> void:
	var toast := TOAST_SCENE.instantiate()
	toast.set_text(text)
	stack.add_child(toast)
	await toast.play_and_wait(duration)
	if is_instance_valid(toast): toast.queue_free()
