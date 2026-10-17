class_name ReferenceCanvas
extends TextureRect



@export var reference_images : Dictionary[Unit.Type, Array]


var image_variation : int :
	set(new_value):
		image_variation = new_value
		_update_image()



var unit_type : Unit.Type :
	set(new_value):
		unit_type = new_value
		_update_image()



func _update_image() -> void:
	texture = reference_images[unit_type][image_variation]


func randomize_image_variation() -> void:
	var new_image_variation := randi_range(0, 2)
	while new_image_variation == image_variation:
		new_image_variation = randi_range(0, 2)
	image_variation = new_image_variation


func _on_spear_button_pressed() -> void:
	unit_type = Unit.Type.Spear

func _on_archer_button_pressed() -> void:
	unit_type = Unit.Type.Archer

func _on_beast_button_pressed() -> void:
	unit_type = Unit.Type.Beast
