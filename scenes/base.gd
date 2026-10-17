class_name Base
extends Area2D

@export var max_health := 10
@export var health_bar: HealthBar

var health := 10 :
	set(new_value):
		health = new_value
		health_bar.health = health


func _ready() -> void:
	health_bar.max_health = max_health
	health = max_health


func damage(amount: int) -> void:
	health -= amount
	
	if health <= 0:
		Global.go_to_end_screen(false)
