@tool
class_name SpawnArea
extends Area2D


@export var size : Vector2 :
	set(new_value):
		size = new_value
		if ($CollisionShape2D):
			var shape: RectangleShape2D = $CollisionShape2D.shape
			shape.size = size


@export var unit_scenes : Dictionary[Unit.Type, PackedScene]

@export var spawning_parent : Node2D



func _ready() -> void:
	assert(spawning_parent)
	size  = size




func get_spawn_locations(unit_size: Vector2, spawn_position: Vector2, count: int) -> Array[Vector2]:
	if count < 1:
		return []
	
	var total_unit_spawn_size = unit_size.y * (count - 1)
	
	spawn_position.y = clamp(spawn_position.y, \
		global_position.y - size.y / 2 + total_unit_spawn_size, global_position.y + size.y / 2 - total_unit_spawn_size)
	
	var spawn_locations: Array[Vector2] = []
	var next_spawn_position = spawn_position
	next_spawn_position.y = spawn_position.y - unit_size.y * (count - 1) / 2
	

	
	for i in range(count):
		spawn_locations.append(next_spawn_position)
		
		next_spawn_position.x = spawn_position.x + unit_size.x * randf_range(-1, 1)
		next_spawn_position.y += unit_size.y
		
	return spawn_locations
	
	
