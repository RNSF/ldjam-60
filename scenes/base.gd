class_name Base
extends Area2D

@export var max_health := 10

var health := 10 :
	set(new_value):
		health = new_value
		health_bar.value = health

@onready var health_bar := $ProgressBar

func _ready() -> void:
	health_bar.max_value = max_health
	health = max_health


func damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		get_tree().reload_current_scene()
