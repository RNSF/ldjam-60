class_name Camera
extends Camera2D

@export_category("Shake Settings")
@export var decay_rate: float = 6.0          # How fast the shake fades out (higher = faster fade)
@export var max_offset: Vector2 = Vector2(25, 25) # Maximum pixel offset on X and Y
@export var noise_speed: float = 40.0        # Speed of the noise sample traversal

var shake_strength: float = 0.0
var noise: FastNoiseLite = FastNoiseLite.new()
var noise_i: float = 0.0                     # Tracks noise position over time

func _ready() -> void:
	# Configure noise generator for smooth motion
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 2.0
	Global.camera = self

func _process(delta: float) -> void:
	if shake_strength > 0.0:
		# Frame-rate independent exponential decay
		shake_strength = lerp(shake_strength, 0.0, decay_rate * delta)
		
		# Advance noise time based on speed and strength
		noise_i += noise_speed * delta
		
		# Generate smooth random offsets using noise
		# We sample noise at different coordinates to get independent X and Y movement
		var x = max_offset.x * shake_strength * noise.get_noise_2d(noise_i, 0.0)
		var y = max_offset.y * shake_strength * noise.get_noise_2d(0.0, noise_i)
		
		offset = Vector2(x, y)
		
		# Clean up when shake is negligible to avoid micro-jitters
		if shake_strength < 0.001:
			shake_strength = 0.0
			offset = Vector2.ZERO
	else:
		offset = Vector2.ZERO

## Call this function from anywhere (e.g., player taking damage, explosions) to add shake energy.
## 'amount' should typically be between 0.0 and 1.0.
func add_shake(amount: float) -> void:
	shake_strength = clamp(shake_strength + amount, 0.0, 1.0)
