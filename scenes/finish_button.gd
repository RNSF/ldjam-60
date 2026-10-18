extends TextureButton

@export var draw_canvas: DrawTexture
@export var reference_canvas: ReferenceCanvas
@export var similarity_manager: SimilarityManager
@export var player_spawn_area : PlayerSpawnArea
@export var enemy_spawn_area : EnemySpawnArea


@onready var fail_sound := $Fail
@onready var ok_sound := $Ok
@onready var good_sound := $Good
@onready var great_sound := $Great
@onready var magnum_opus_sound := $MagnumOpus

var is_started := false

func get_quality(strength: float) -> Unit.Quality:
	
	if strength < 0.5:
		return Unit.Quality.Fail
	if strength < 0.65:
		return Unit.Quality.Ok
	if strength < 0.75:
		return Unit.Quality.Good
	if strength < 0.9 or not is_started:
		return Unit.Quality.Great
	
	return Unit.Quality.Opus
	



func _on_pressed() -> void:
	
	$ClickSound.play()
	
	
	var similarity_score := similarity_manager.compare(draw_canvas.image, reference_canvas.texture.get_image())
	var texture : Texture2D = ImageTexture.create_from_image(draw_canvas.image.duplicate())
	
	
	draw_canvas.clear()
	var strength : float = min(similarity_score.similarity, similarity_score.completeness, similarity_score.accuracy)
	
	var quality := get_quality(strength)
	
	match quality:
		Unit.Quality.Fail:
			fail_sound.play()
		Unit.Quality.Ok:
			ok_sound.play()
		Unit.Quality.Good:
			good_sound.play()
		Unit.Quality.Great:
			great_sound.play()
		Unit.Quality.Opus:
			magnum_opus_sound.play()
			Global.show_hit_text("Magnum Opus")
	
	if quality != Unit.Quality.Fail:
		
		print(strength)
		print(quality)
		Global.texture_cache.append(texture)
		player_spawn_area.summon_from_texture(texture, strength, quality, reference_canvas.unit_type)
		
		if enemy_spawn_area.is_fresh() and not is_started:
			is_started = true
			await get_tree().create_timer(2.0).timeout
			enemy_spawn_area.start_wave()
	
	reference_canvas.randomize_image_variation()
	
	pass # Replace with function body.
