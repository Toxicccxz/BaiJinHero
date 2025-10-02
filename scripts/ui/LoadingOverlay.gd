extends Control
@onready var dimmer  : ColorRect    = $Dimmer
@onready var spinner : TextureRect  = $Spinner
@onready var bar     : ProgressBar  = $ProgressBar

func show_loading() -> void:
	visible = true
	mouse_filter = MOUSE_FILTER_STOP

func hide_loading() -> void:
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE

func set_progress(p: float) -> void:
	if is_instance_valid(bar):
		bar.value = clamp(p, 0.0, 1.0) * 100.0
