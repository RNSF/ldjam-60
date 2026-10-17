extends Node

class_name SimilarityManager

@export var draw_canvas: DrawTexture
@export var intended_enemy_type: String
var intended_image: Image
@export var matcher_threshold := 0.1
@export var matcher_count_aa := false
@export var diff_sprite: TextureRect
@export var similarity_text: Label
var pixel_matcher := PixelMatcher.new()

func _ready() -> void:
	intended_image = Image.load_from_file("res://sprites/%s.png" % intended_enemy_type)
	intended_image.resize(draw_canvas.canvas_size, draw_canvas.canvas_size)
	pixel_matcher.threshold = matcher_threshold
	pixel_matcher.include_aa = matcher_count_aa

func _process(delta: float) -> void:
	var start := Time.get_ticks_usec()
	var output = Image.create(draw_canvas.canvas_size, draw_canvas.canvas_size, false, Image.FORMAT_RGBA8)
	var diff_pixels := pixel_matcher.diff(draw_canvas.image, intended_image, output, draw_canvas.canvas_size, draw_canvas.canvas_size)
	if diff_pixels < 0:
		push_error("Comparison failed, maybe a size diff between size of the images?")
		return
	print("%d pixels differ" % diff_pixels)
	similarity_text.text = "# of different pixels: %d" % diff_pixels
	diff_sprite.texture = ImageTexture.create_from_image(output)
	var elapsed_ms := (Time.get_ticks_usec() - start) / 1000.0
	print("diff took %.2f ms" % elapsed_ms)
