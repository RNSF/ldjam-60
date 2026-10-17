extends Button

@export var draw_canvas: DrawTexture
@export var reference_canvas: ReferenceCanvas
@export var similarity_manager: SimilarityManager
@export var player_spawn_area : PlayerSpawnArea
@export var enemy_spawn_area : EnemySpawnArea


func get_quality(strength: float) -> Unit.Quality:
	
	if strength < 0.5:
		return Unit.Quality.Fail
	if strength < 0.65:
		return Unit.Quality.Ok
	if strength < 0.75:
		return Unit.Quality.Good
	if strength < 0.9:
		return Unit.Quality.Great
	
	return Unit.Quality.Opus
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var similarity_score := similarity_manager.compare(draw_canvas.image, reference_canvas.texture.get_image())
			var texture : Texture2D = ImageTexture.create_from_image(draw_canvas.image.duplicate())
			
			
			draw_canvas.clear()
			var strength : float = min(similarity_score.similarity, similarity_score.completeness, similarity_score.accuracy)
			
			var quality := get_quality(strength)
			
			if quality != Unit.Quality.Fail:
				
				print(strength)
				print(quality)
				Global.texture_cache.append(texture)
				player_spawn_area.summon_from_texture(texture, strength, quality, reference_canvas.unit_type)
				
				if enemy_spawn_area.is_fresh():
					enemy_spawn_area.start_wave()
			
			reference_canvas.randomize_image_variation()
			
		
