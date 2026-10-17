extends Attack


func attack(target_unit: Unit, strength: float) -> void:
	target_unit.damage(strength)
	queue_free()
