extends Node


signal wave_started(wave_number: int)

var camera : Camera
var texture_cache : Array[Texture2D]
var did_win := false
var hit_text : HitText
var master_scene : MasterScene

var brush = load("res://sprites/brush1.png")
var brush_painting = load("res://sprites/brush2.png")

func _ready() -> void:
	randomize()

func shake_camera(amount: float) -> void:
	if is_instance_valid(camera):
		camera.add_shake(amount)

func show_hit_text(text: String) -> void:
	if is_instance_valid(hit_text):
		hit_text.show_text(text)


func reset_game():
	master_scene.start_transition("res://scenes/game.tscn")
	did_win = false
	texture_cache.clear()


func go_to_end_screen(new_did_win: bool):
	did_win = new_did_win
	master_scene.start_transition("res://scenes/end_scene.tscn")


func update_wave(new_wave: int) -> void:
	wave_started.emit(new_wave)
