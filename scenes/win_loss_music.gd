extends AudioStreamPlayer


@export var win_music : AudioStream
@export var loss_music : AudioStream



func _ready() -> void:
	if Global.did_win:
		stream = win_music
	else:
		stream = loss_music
	
	play()
