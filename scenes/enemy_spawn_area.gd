@tool
extends SpawnArea








func _on_timer_timeout() -> void:
	var spawn_position := global_position + Vector2(randf(), randf()) * size - size / 2
	var unit_scene := unit_scenes[Unit.Type.values().pick_random()]
	
	var spawn_locations := get_spawn_locations(Vector2(40, 40), spawn_position, 5)
	
	for spawn_location in spawn_locations:
		var unit : Unit = unit_scene.instantiate()
		unit.add_to_group(&"enemy")
		unit.enemy_unit_tag = &"player"
		unit.ally_unit_tag = &"enemy"
		unit.target_x = -1920 / 2
		unit.color = Color.RED
		unit.charge_radius = 300
		unit.init_stats(1.0, 1.0)
		unit.global_position = spawn_location
		spawning_parent.add_child(unit)
