extends Sprite2D


signal transition




func start_transition() -> void:
	$AnimationPlayer.play("Transition")


func do_transition() -> void:
	transition.emit()
