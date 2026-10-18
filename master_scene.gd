class_name MasterScene
extends Node



var next_scene : String

@onready var current_scene := $CurrentScene


func _ready() -> void:
	next_scene = "res://scenes/start_scene.tscn"
	goto_scene()
	Global.master_scene = self

func start_transition(target_scene: String) -> void:
	if $CanvasLayer/FireTransition/AnimationPlayer.is_playing(): return
	next_scene = target_scene
	$CanvasLayer/FireTransition.start_transition()


func _on_fire_transition_transition() -> void:
	goto_scene()


func goto_scene() -> void:
	for child in current_scene.get_children():
		current_scene.remove_child(child)
	
	var packed_scene : PackedScene = load(next_scene)
	current_scene.add_child(packed_scene.instantiate())
