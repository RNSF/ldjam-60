extends TextureRect

@export var noise_speed: float = 10.0      # How fast the flicker changes
@export var min_alpha: float = 0.3       # Lowest alpha value during flicker
@export var max_alpha: float = 1.0       # Highest alpha value during flicker

var noise: FastNoiseLite = FastNoiseLite.new()
var time_passed: float = 0.0

func _ready() -> void:
	# Initialize the noise generator
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 1.0

func _process(delta: float) -> void:
	time_passed += delta * noise_speed
	
	# Get a noise value between -1.0 and 1.0
	var noise_val = noise.get_noise_1d(time_passed)
	
	# Remap the noise value from [-1, 1] to [0, 1], then map to your min/max alpha range
	var normalized_noise = (noise_val + 1.0) * 0.5
	var target_alpha = lerp(min_alpha, max_alpha, normalized_noise)
	
	# Update the shader uniform parameter
	if material is ShaderMaterial:
		material.set_shader_parameter("alpha", target_alpha)
