extends Label

var _timer := 0.0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= 0.25:
		_timer = 0.0
		text = "FPS: %d" % Engine.get_frames_per_second()
