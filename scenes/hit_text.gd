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
		

@export var text : String = "Wave 1" :
	set(new_value):
		text = new_value
		if !is_node_ready(): return
		text_label.text = text
		text_shadow_label.text = text
		text_shadow_label.position = -text_shadow_label.size / 2


var velocity : Vector2
var is_falling := false


func show_text(text_to_show: String):
	if is_falling: return
	height = 300
	is_falling = true
	visible = true
	text = text_to_show
	timer.stop()

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
		
	height = new_height



func _on_timer_timeout() -> void:
	visible = false
