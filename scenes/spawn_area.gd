@tool
class_name SpawnArea
extends Area2D


@export var size : Vector2 :
	set(new_value):
		size = new_value
		if ($CollisionShape2D):
			var shape: RectangleShape2D = $CollisionShape2D.shape
			shape.size = size

@export var unit_scene : PackedScene

func _ready() -> void:
	size  = size


func spawn_at(base_unit: Unit, spawn_position: Vector2, count: int) -> void:
	
	if (count < 1): return
	
	
	
	var next_spawn_position = spawn_position
	next_spawn_position.y = spawn_position.y - base_unit.size.y * (count - 1) / 2
	
	for i in range(count):
		var new_unit := base_unit.duplicate()
		get_parent().add_child(new_unit)
		new_unit.global_position = next_spawn_position
		
		next_spawn_position.x = spawn_position.x + base_unit.size.x * randf_range(-1, 1)
		next_spawn_position.y += base_unit.size.y
	
	
