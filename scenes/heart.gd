class_name Heart
extends TextureRect


@export var full_texture : Texture
@export var empty_texture : Texture
@export var is_full : bool = true :
	set(new_value):
		is_full = new_value
		texture = full_texture if is_full else empty_texture
