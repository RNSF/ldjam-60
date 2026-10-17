extends Node

class_name SimilarityManager

@export var draw_canvas: DrawTexture
@export var intended_enemy_type: String
@export var diff_sprite: TextureRect
@export var similarity_text: Label
@export var pixel_matcher_settings: PixelMatchSettings

var intended_image: Image
var pixel_matcher := PixelMatcher.new()
var _output: Image
var _output_texture: ImageTexture


func _ready() -> void:
	var size: int = draw_canvas.canvas_size

	var tex := load("res://sprites/%s.png" % intended_enemy_type) as Texture2D
	intended_image = tex.get_image()
	if intended_image.is_compressed():
		intended_image.decompress()
	intended_image.clear_mipmaps()
	intended_image.convert(Image.FORMAT_RGBA8)
	intended_image.resize(size, size)

	_output = Image.create(size, size, false, Image.FORMAT_RGBA8)
	_output_texture = ImageTexture.create_from_image(_output)
	diff_sprite.texture = _output_texture


func _process(_delta: float) -> void:
	var size: int = draw_canvas.canvas_size
	var start := Time.get_ticks_usec()
	var diff_pixels := pixel_matcher.diff(draw_canvas.image, intended_image, _output, size, size, pixel_matcher_settings)
	if diff_pixels < 0:
		push_error("Comparison failed; see the error above for the reason.")
		return

	similarity_text.text = "# of different pixels: %d" % diff_pixels
	_output_texture.update(_output)

	var elapsed_ms := (Time.get_ticks_usec() - start) / 1000.0
	#print("diff took %.2f ms" % elapsed_ms)
	
func shape_similarity(drawing: Image, target: Image, grid := 32) -> float:
	var a := _ink_mask(drawing, grid)
	var b := _ink_mask(target, grid)
	var inter := 0
	var union := 0
	for i in a.size():
		if a[i] or b[i]:
			union += 1
		if a[i] and b[i]:
			inter += 1
	return 1.0 if union == 0 else float(inter) / union  # 0 = no overlap, 1 = identical shape

func _ink_mask(img: Image, grid: int) -> PackedByteArray:
	var copy := img.duplicate() as Image  # leave the caller's image untouched
	var used := copy.get_used_rect()       # bounding box of non-transparent pixels
	if used.size != Vector2i.ZERO:
		copy = copy.get_region(used)
	copy.resize(grid, grid, Image.INTERPOLATE_LANCZOS)
	var mask := PackedByteArray()
	mask.resize(grid * grid)
	for y in grid:
		for x in grid:
			mask[y * grid + x] = 1 if copy.get_pixel(x, y).a > 0.2 else 0
	return mask
