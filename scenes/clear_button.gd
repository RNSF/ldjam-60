extends Button

@export var draw_canvas: DrawTexture

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			draw_canvas.clear()
