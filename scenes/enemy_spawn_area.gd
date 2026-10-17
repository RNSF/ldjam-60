@tool
extends SpawnArea








func _on_timer_timeout() -> void:
	var spawn_position := global_position + Vector2(randf(), randf()) * size - size / 2
	
	var base_unit : Unit = unit_scene.instantiate()
	base_unit.add_to_group(&"enemy")
	base_unit.enemy_unit_tag = &"player"
	base_unit.ally_unit_tag = &"enemy"
	base_unit.target_x = -1920 / 2
	base_unit.color = Color.RED
	base_unit.charge_radius = 500
	
	
	spawn_at(base_unit, spawn_position, randi_range(3, 7))
	
	base_unit.queue_free()
	pass # Replace with function body.
