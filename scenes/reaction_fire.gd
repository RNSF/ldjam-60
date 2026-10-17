extends Sprite2D



func _ready() -> void:
	Global.wave_started.connect(_on_wave_started)
	_on_wave_started(0)


func _on_wave_started(number: int) -> void:
	
	var shader_material : ShaderMaterial = material
	
	if number == 0:
		shader_material.set_shader_parameter("spread", 0.5)
	if number == 1:
		shader_material.set_shader_parameter("spread", 0.75)
	if number == 2:
		shader_material.set_shader_parameter("spread", 1.0)
