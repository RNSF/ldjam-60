class_name HealthBar
extends HBoxContainer


@export var heart_scene : PackedScene

var max_health : int = 10 :
	set(new_value):
		max_health = new_value
		for child in get_children():
			child.queue_free()
		
		for i in range(max_health):
			var heart : Heart = heart_scene.instantiate()
			add_child(heart)
			heart.variation = randi_range(0, 2)
		health = min(max_health, health)
		
var health : int = 10 :
	set(new_value):
		health = new_value
		for i in get_child_count():
			var heart: Heart = get_child(i)
			heart.is_full = i <= health


func _ready() -> void:
	max_health = max_health
