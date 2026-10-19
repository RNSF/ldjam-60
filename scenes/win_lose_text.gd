extends Sprite2D


@export var win_text : Texture2D
@export var lose_text : Texture2D



func _ready() -> void:
	if Global.did_win:
		texture = win_text
	else:
		texture = lose_text
