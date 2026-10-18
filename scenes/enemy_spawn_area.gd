@tool
class_name EnemySpawnArea
extends SpawnArea

var enemy_bank := [ # unit type, count, delay until next spawn
	[ # wave 1
		[Unit.Type.Spear, 0, 5],
		[Unit.Type.Spear, 5, 10],
		[Unit.Type.Archer, 3, 20],
		[Unit.Type.Spear, 10, 20],
		[Unit.Type.Archer, 5, 20],
		[Unit.Type.Beast, 1, 20],
	],
	[ # wave 2
		[Unit.Type.Spear, 0, 5],
		[Unit.Type.Spear, 5, 0],
		[Unit.Type.Archer, 5, 20],
		[Unit.Type.Beast, 2, 0],
		[Unit.Type.Spear, 5, 20],
		[Unit.Type.Archer, 10, 10],
		[Unit.Type.Spear, 10, 10],
		[Unit.Type.Beast, 3, 0],
		[Unit.Type.Spear, 10, 20],
	],
	[ # wave 3
		[Unit.Type.Spear, 0, 5],
		[Unit.Type.Spear, 10, 0],
		[Unit.Type.Spear, 10, 10],
		[Unit.Type.Archer, 10, 0],
		[Unit.Type.Spear, 10, 10],
		[Unit.Type.Beast, 5, 10],
		[Unit.Type.Spear, 10, 10],
		[Unit.Type.Archer, 10, 30],
		[Unit.Type.Beast, 5, 0],
		[Unit.Type.Beast, 5, 0],
		[Unit.Type.Beast, 5, 0],
		[Unit.Type.Beast, 5, 0],
	]
]

var wave_number := 0
var wave_index := 0

@onready var timer: Timer = $Timer # Adjust node path if your Timer has a different name

@onready var first_wave_sound := $FirstWave
@onready var second_wave_sound := $SecondWave
@onready var third_wave_sound := $ThirdWave

func is_fresh() -> bool:
	return wave_number == 0 and wave_index == 0

func start_wave() -> void:
	Global.update_wave(wave_number)
	wave_index = 0
	if wave_number < enemy_bank.size():
		process_wave_step()
		Global.show_hit_text(["Wave 1", "Wave 2", "Final Wave"][wave_number])
		[first_wave_sound, second_wave_sound, third_wave_sound][wave_number].play()
	else:
		print("All waves completed!")
		timer.stop()


func process_wave_step() -> void:
	var current_wave = enemy_bank[wave_number]
	
	# Check if the current wave is finished
	if wave_index >= current_wave.size():
		return
		#wave_number += 1
		#wave_index = 0
		#start_wave()
		#return
		
	# Get current entry [UnitType, Count, Delay]
	var entry = current_wave[wave_index]
	var unit_type = entry[0]
	var count = entry[1]
	var delay = entry[2]
	
	# Spawn the units for this entry
	spawn_unit_batch(unit_type, count)
	
	# Advance to the next entry index
	wave_index += 1
	
	# Configure timer for the next delay (if 0, trigger almost immediately)
	timer.wait_time = max(delay, 0.01)
	timer.start()


func spawn_unit_batch(unit_type: Unit.Type, count: int) -> void:
	var unit_scene = unit_scenes[unit_type]
	
	
	var spawn_position := global_position + Vector2(randf(), randf()) * size - size / 2
	var spawn_locations := get_spawn_locations(Vector2(40, 40), spawn_position, count)
	
	for spawn_location in spawn_locations:
		var unit : Unit = unit_scene.instantiate()
		unit.add_to_group(&"enemy")
		unit.enemy_unit_tag = &"player"
		unit.ally_unit_tag = &"enemy"
		unit.target_x = -1920 / 2
		unit.color = Color.RED
		unit.charge_radius = 300
		unit.init_stats(0.7, 0.7)
		unit.global_position = spawn_location
		unit.tree_exited.connect(_check_for_next_wave)
		spawning_parent.add_child(unit)

func _check_for_next_wave():
	if !get_tree(): return
	if wave_index >= enemy_bank[wave_number].size() and get_tree().get_nodes_in_group(&"enemy").size() == 0:
		wave_number += 1
		wave_index = 0
		start_wave()

func _on_timer_timeout() -> void:
	process_wave_step()
