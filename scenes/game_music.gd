extends AudioStreamPlayer


@export var music_0 : AudioStream
@export var music_1 : AudioStream
@export var music_2 : AudioStream
@export var music_3 : AudioStream


func _ready() -> void:
	stream = music_0
	play()
	Global.wave_started.connect(_on_wave_started)
	_on_wave_started(0)


func _on_wave_started(number: int) -> void:
	
	if number == 0:
		stream = music_1
	if number == 1:
		stream = music_2
	if number == 2:
		stream = music_3
	
	play()
