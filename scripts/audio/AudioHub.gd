extends Node
var current_bgm: AudioStreamPlayer

func play_bgm(stream: AudioStream, time_seek := 0.0) -> void:
	if current_bgm and is_instance_valid(current_bgm):
		current_bgm.stop()
		current_bgm.queue_free()
	current_bgm = AudioStreamPlayer.new()
	current_bgm.bus = "BGM"
	current_bgm.stream = stream
	add_child(current_bgm)
	current_bgm.play(time_seek)

func stop_bgm(): if current_bgm: current_bgm.stop()
