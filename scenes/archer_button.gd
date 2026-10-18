extends TextureButton

func _ready() -> void:
	Global.wave_started.connect(_on_wave_started)
	_on_wave_started(0)


func _on_wave_started(number: int) -> void:
	disabled = number < 1
