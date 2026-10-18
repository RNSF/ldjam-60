@tool
class_name PlayerSpawnArea
extends SpawnArea


var amount_to_add := {
	Unit.Type.Spear: {
		Unit.Quality.Fail: 0,
		Unit.Quality.Ok: 2,
		Unit.Quality.Good: 4,
		Unit.Quality.Great: 6,
		Unit.Quality.Opus: 10,
	},
	Unit.Type.Archer: {
		Unit.Quality.Fail: 0,
		Unit.Quality.Ok: 2,
		Unit.Quality.Good: 4,
		Unit.Quality.Great: 6,
		Unit.Quality.Opus: 10,
	},
	Unit.Type.Beast: {
		Unit.Quality.Fail: 0,
		Unit.Quality.Ok: 1,
		Unit.Quality.Good: 2,
		Unit.Quality.Great: 3,
		Unit.Quality.Opus: 10,
	}
}


func summon_from_texture(texture: Texture, strength: float, quality: Unit.Quality, type: Unit.Type) -> void:
	var unit_scene : PackedScene = unit_scenes.get(type)
	if !unit_scene: 
		return
	
	
	
	var spawn_position := global_position + Vector2(randf(), randf()) * size - size / 2
	
	var spawn_locations := get_spawn_locations(Vector2(40, 40), spawn_position, amount_to_add.get(type).get(quality))
	
	for spawn_location in spawn_locations:
		var unit := unit_scenes[type].instantiate()
		unit.add_to_group(&"player")
		unit.enemy_unit_tag = &"enemy"
		unit.ally_unit_tag = &"player"
		unit.target_x = 0
		unit.charge_radius = 4000
		unit.init_stats(strength, strength)
		unit.global_position = spawn_location
		spawning_parent.add_child(unit)
		unit.sprite.texture = texture
		unit.sprite.scale = 0.4 * Vector2.ONE


#func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#var mouse_event : InputEventMouseButton = event
		#if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			#
			#var spawn_position: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * mouse_event.global_position
			#
			#var spawn_locations := get_spawn_locations(Vector2(40, 40), spawn_position, 5)
			#
			#for spawn_location in spawn_locations:
				#var unit := unit_scenes[Unit.Type.Spear].instantiate()
				#unit.add_to_group(&"player")
				#unit.enemy_unit_tag = &"enemy"
				#unit.ally_unit_tag = &"player"
				#unit.target_x = 0
				#unit.charge_radius = 4000
				#unit.init_stats(1.0, 1.0)
				#unit.global_position = spawn_location
				#spawning_parent.add_child(unit)
