@tool
extends SpawnArea




func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_event : InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var unit: Unit = unit_scene.instantiate()
			var spawn_position: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * mouse_event.global_position
			
			var base_unit : Unit = unit_scene.instantiate()
			base_unit.add_to_group(&"player")
			base_unit.enemy_unit_tag = &"enemy"
			base_unit.ally_unit_tag = &"player"
			base_unit.target_x = 0
			base_unit.charge_radius = 4000
			
			spawn_at(base_unit, spawn_position, 5)
			
			base_unit.queue_free()
