extends Attack


@onready var area2d := $Area2D
@onready var life_timer := $LifeTimer

var damage : float
var hit_tag : StringName

func attack(target_unit: Unit, strength: float) -> void:
	area2d.monitoring = true
	damage = strength
	life_timer.start(0.1)
	global_position = target_unit.global_position
	hit_tag = target_unit.ally_unit_tag



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Unit and area.is_in_group(hit_tag):
		var unit := area
		unit.damage(damage)


func _on_life_timer_timeout() -> void:
	queue_free()
