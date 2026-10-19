class_name Heart
extends TextureRect


@export var variation : int
@export var full_textures : Array[Texture]
@export var empty_textures : Array[Texture]
@export var is_full : bool = true : 
	set(new_value):
		is_full = new_value
		texture = full_textures[variation] if is_full else empty_textures[variation]


func _ready() -> void:
	flip_h = randi_range(0, 2) == 0
