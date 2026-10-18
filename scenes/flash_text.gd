extends Control




func show_text(new_text: String, color: Color) -> void:
	$FlashText.text = new_text
	modulate = color
	$AnimationPlayer.play("Flash")
	rotation = randf_range(-0.1, 0.1)
