extends Unit



func init_stats(upper_body: float, lower_body: float) -> void:
	super.init_stats(upper_body, lower_body)
	
	
	speed = lerp(0, 80, lower_body)
	attack_period = 1
	attack_strength = lerp(0, 8, upper_body)
	health = 5.0
	attack_radius_low = 500.0
	attack_radius_high = 800.0
	
	return
