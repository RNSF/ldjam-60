@tool
class_name HitText
extends Node2D

@onready var text_shadow_label := $TextShadow
@onready var text_label := $Text
@onready var timer := $Timer

@export var height := 0.0 :
	set(new_value):
		height = new_value
		if !is_node_ready(): return
		text_label.position.y = text_shadow_label.position.y - height
		text_shadow_label.scale = Vector2.ONE * exp(-height * 0.0001)

@export var text : String = "Wave 1" :
	set(new_value):
		text = new_value
		if !is_node_ready(): return
		text_label.text = new_value
		text_shadow_label.text = new_value


var velocity : Vector2
var is_falling := false


func show_text(text_to_show: String):
	height = 300
	text = text_to_show
	is_falling = true
	visible = true
	

func _ready() -> void:
	height = 0
	Global.hit_text = self
	text = ""
	visible = false


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if !is_falling: return
	
	velocity.y += -delta * 2000
	var new_height := height + velocity.y * delta
	
	
	
	if new_height < 0:
		new_height = 0
		velocity.y = 0
		Global.shake_camera(1.0)
		print("BOOM")
		is_falling = false
		timer.start(3.0)
		text_shadow_label.visible = false
		
	height = new_height



func _on_timer_timeout() -> void:
	visible = false
