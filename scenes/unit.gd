class_name Unit
extends Area2D

enum MoveState {
	CHARGE,
	WALK,
	FIGHT
}

const WALK_FORCE = 10.0
const ARENA_BOTTOM = 1080 / 2
const ARENA_TOP = -100 / 2

@export var size: Vector2
@export var attack_scene: PackedScene

@export var target_x := 400.0
@export var ally_unit_tag : StringName
@export var enemy_unit_tag : StringName 


var speed := 100.0
var attack_period := 1.0
var attack_radius_low := 400.0 # the distance the target unit needs to be 
									 # within to enter the attacking state
var attack_radius_high := 20000.0 # the distance the target unit needs to be
									  # away to exit the attacking state
var attack_strength := 1.0
var health := 5.0 :
	set(new_value):
		health = new_value
		if health <= 0.0:
			die()

@export var charge_radius := 0.0 # the distance a unit must be within for this unit to 
								 # start charging at it

@export var color := Color.BLACK

@onready var attack_timer := $AttackTimer;


@onready var cohesion_zone := $CohesionZone
@onready var separation_zone := $CohesionZone
@onready var alignment_zone := $CohesionZone

@onready var sprites = $Sprites
@onready var sprite_variation = $Sprites/SpriteVariation
@onready var sprite = $Sprites/SpriteVariation/Sprite
@onready var animation_player = $AnimationPlayer
@onready var attack_origin := $Sprites/AttackOrigin

enum Type {
	Spear,
	Archer,
	Beast
}

enum Quality {
	Fail,
	Ok,
	Good,
	Great,
	Opus
}

var hit_flash_percent = 0.0 :
	set(new_value):
		hit_flash_percent = new_value
		modulate = color.lerp(Color.WHITE, hit_flash_percent)
		modulate.a = 0.8


var move_state: MoveState = MoveState.WALK :
	set(new_value):
		if (move_state == new_value): return
		
		match move_state:
			MoveState.FIGHT:
				attack_timer.stop()
		
		move_state = new_value
		
		match move_state:
			MoveState.FIGHT:
				attack_timer.start(attack_period)
		
		is_running = move_state != MoveState.FIGHT

var is_running := false :
	set(new_value):
		is_running = new_value
		if is_running:
			animation_player.play("walk")
		else:
			animation_player.stop()

var target_unit: Unit = null
var velocity : Vector2


func _ready() -> void:
	assert(attack_radius_low <= attack_radius_high)
	color = color.lightened(randf_range(0.0, 0.2))
	sprite_variation.scale.x = exp(randf_range(-0.2, 0.2))
	sprite_variation.scale.y = exp(randf_range(-0.2, 0.2))
	sprite_variation.rotation = randf_range(-0.2, 0.2)
	pass # Replace with function body.


# dummy function
func init_stats(upper_body: float, lower_body: float) -> void:
	assert(upper_body >= 0.0 and upper_body <= 1.0)
	assert(lower_body >= 0.0 and lower_body <= 1.0)
	return


func init_texture(texture: Texture) -> void:
	sprites.texture = texture


func _find_new_target_unit():
	var enemy_units := get_tree().get_nodes_in_group(enemy_unit_tag).filter(
		func(x: Unit): return x.global_position.distance_to(global_position) < charge_radius)
	
	enemy_units.sort_custom(func(a: Unit, b: Unit): 
		return (a.global_position - global_position).length_squared() < (b.global_position - global_position).length_squared())
	
	if enemy_units.size():
		target_unit = enemy_units.front()


func _process(delta: float) -> void:
	hit_flash_percent = lerp(hit_flash_percent, 0.0, 20 * delta)
	
	if velocity.x > 0:
		sprites.scale.x = 1
	elif velocity.x < 0:
		sprites.scale.x = -1

func _physics_process(delta: float) -> void:
	
	var old_position := global_position
	var target_walk_direction := Vector2.ZERO
	
	
	
	if !is_instance_valid(target_unit):
		target_unit = null
		move_state = MoveState.WALK
	
	if !target_unit:
		_find_new_target_unit()
	
	if target_unit:
		var distance_to_target := target_unit.global_position.distance_to(global_position)
		if distance_to_target < attack_radius_low:
			move_state = MoveState.FIGHT
		elif move_state == MoveState.FIGHT and distance_to_target < attack_radius_high:
			move_state = MoveState.FIGHT
		else:
			move_state = MoveState.CHARGE
	
	match move_state:
		MoveState.WALK:
			target_walk_direction = Vector2(sign(target_x - global_position.x), 0)
		MoveState.CHARGE:
			if target_unit:
				target_walk_direction = (target_unit.global_position - global_position).normalized()
			
			
		
		MoveState.FIGHT:
			pass
	
	
	if move_state != MoveState.FIGHT:
		var walk_vector = Vector2.ZERO
		
		var cohesion_units : Array[Unit]
		var separation_units : Array[Unit]
		var alignment_units : Array[Unit]
		
		cohesion_units.assign(cohesion_zone.get_overlapping_areas() \
			.filter(func(x: Unit): return x.ally_unit_tag == ally_unit_tag and x != self))
		
		separation_units.assign(separation_zone.get_overlapping_areas() \
			.filter(func(x: Unit): return x.ally_unit_tag == ally_unit_tag and x != self))
		
		alignment_units.assign(alignment_zone.get_overlapping_areas() \
			.filter(func(x: Unit): return x.ally_unit_tag == ally_unit_tag and x != self))
		
		var cohesion_target : Vector2 = cohesion_units.reduce(
			func(v: Vector2, x: Unit) -> Vector2: return v + x.global_position, Vector2.ZERO) / max(cohesion_units.size(), 1)
		
		var separation_vector : Vector2 = separation_units.reduce(
			func(v: Vector2, x: Unit): return v + (global_position - x.global_position).normalized(), Vector2.ZERO)
		
		var average_neighbor_speed : Vector2 = alignment_units.reduce(
			func(v: Vector2, x: Unit): return v + x.velocity, Vector2.ZERO) / max(alignment_units.size(), 1)
		
		
		#walk_vector += 1.0 * (cohesion_target - global_position)
		walk_vector += 30.0 * separation_vector
		walk_vector += 1.0 * (average_neighbor_speed - velocity)
		walk_vector += 100.0 * target_walk_direction
		walk_vector += 100.0 * (clamp(remap(abs(position.y - ARENA_TOP), 0, 200, 1, 0), 0, 1) * Vector2.DOWN \
			+ clamp(remap(abs(position.y - ARENA_BOTTOM), 0, 200, 1, 0), 0, 1) * Vector2.UP)
		
		velocity += walk_vector * WALK_FORCE * delta
		velocity = velocity.normalized() * min(velocity.length(), speed)
	else:
		velocity = Vector2.ZERO
	
	position += velocity * delta
	
	position.y = clamp(position.y, ARENA_TOP, ARENA_BOTTOM)


func _on_attack_timer_timeout() -> void:
	assert(move_state == MoveState.FIGHT)
	
	if !target_unit:
		_find_new_target_unit()
	
	if target_unit:
		var attack: Attack = attack_scene.instantiate()
		get_parent().add_child(attack)
		attack.global_position = attack_origin.global_position
		attack.modulate = color
		attack.attack(target_unit, attack_strength)
		animation_player.play("attack")
		$AttackSound.play()
		
		Global.shake_camera(0.05)
		
		#if target_unit.move_state != MoveState.FIGHT:
			#target_unit.target_unit = self


func damage(health_loss: float) -> void:
	health -= health_loss
	hit_flash_percent = 1.0

@onready var death_sound := $DeathSound

func die() -> void:
	remove_child(death_sound)
	get_parent().add_child(death_sound)
	death_sound.play()
	queue_free()
	Global.shake_camera(0.3)


func _on_area_entered(area: Area2D) -> void:
	if area is Base and ally_unit_tag == &"enemy":
		var base: Base = area
		base.damage(1)
		die()
