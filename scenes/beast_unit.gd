extends Unit



func init_stats(upper_body: float, lower_body: float) -> void:
	super.init_stats(upper_body, lower_body)
	
	speed = lerp(0, 80, lower_body)
	attack_period = 2.0
	attack_strength = lerp(0, 2, upper_body)
	health = 20.0
	attack_radius_low = 200.0
	attack_radius_high = 400.0
	
	return
