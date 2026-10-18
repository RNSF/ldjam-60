extends Attack


@onready var area2d := $Area2D

var damage : float
var hit_tag : StringName

func attack(target_unit: Unit, strength: float) -> void:
	area2d.monitoring = true
	damage = strength
	global_position = target_unit.global_position
	hit_tag = target_unit.ally_unit_tag



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Unit and area.is_in_group(hit_tag):
		var unit := area
		unit.damage(damage)
		print("MAMMOTH HIT")
		print(damage)


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
	pass # Replace with function body.
