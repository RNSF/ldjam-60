extends Node



var camera : Camera



func shake_camera(amount: float) -> void:
	if camera:
		camera.add_shake(amount)
