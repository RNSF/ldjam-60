extends Attack

const SPEED := 2000.0

var is_active := false
var damage : float
var target : Unit

func _physics_process(delta: float) -> void:
	
	
	
	if !is_active:
		return
	
	if !is_instance_valid(target): 
		queue_free()
		return
	
	var target_direction = (target.global_position - global_position).normalized()
	global_position += target_direction * min((target.global_position - global_position).length(), SPEED * delta)
	rotation = target_direction.angle()
	
	
	
	if (global_position - target.global_position).length() < 0.001:
		target.damage(damage)
		queue_free()


func attack(target_unit: Unit, strength: float) -> void:
	is_active = true
	damage = strength
	target = target_unit
	pass # dummy function, changed in inherited classes
