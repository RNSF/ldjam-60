extends Node2D

@export var default_texture_bank : Array[Texture]

@onready var texture_rect := $TextureRect

func _ready() -> void:
	if Global.did_win:
		texture_rect.modulate = Color.BLACK
		texture_rect.texture = Global.texture_cache.pick_random()
		$AnimationPlayer.play("Dance")
	else:
		texture_rect.modulate = Color("#7A2F2A")
		texture_rect.texture = default_texture_bank.pick_random()
	
	texture_rect.modulate.a = 0.8
	texture_rect.flip_h = randi_range(0, 1) == 0
	
