extends Unit




func init_stats(upper_body: float, lower_body: float) -> void:
	assert(upper_body >= 0.0 and upper_body <= 1.0)
	assert(lower_body >= 0.0 and lower_body <= 1.0)
	var body := Vector2(lower_body, upper_body).length()
	speed = lerp(0, 120, lower_body)
	attack_strength = lerp(0, 6, lower_body)
	health = lerp(0, 10, body)
