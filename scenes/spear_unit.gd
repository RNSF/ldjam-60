extends Unit




func init_stats(upper_body: float, lower_body: float) -> void:
	super.init_stats(upper_body, lower_body)
	var body := Vector2(lower_body, upper_body).length()
	
	speed = lerp(0, 120, lower_body)
	attack_period = 0.3
	attack_strength = lerp(0, 2, upper_body)
	health = lerp(0, 6, body)
	attack_radius_low = 50.0
	attack_radius_high = 200.0
	
	
	
	
