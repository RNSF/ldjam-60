extends TextureRect

class_name DrawTexture

var image: Image
var brush_radius := 4
var brush_color := Color.BLACK
var _last_pos := Vector2i(-1, -1)
@export var canvas_size := 512

@export var outline_color := Color.RED
@export var outline_width := 2.0

func _draw() -> void: 
	draw_rect(Rect2(Vector2.ZERO, size), outline_color, false, outline_width)

func _ready() -> void:
	image = Image.create(canvas_size, canvas_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	texture = ImageTexture.create_from_image(image)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_last_pos = Vector2i(event.position)
			_stamp(_last_pos)
			texture.update(image)
		else:
			_last_pos = Vector2i(-1, -1)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		var pos := Vector2i(event.position)
		_stroke(_last_pos, pos)
		_last_pos = pos
		texture.update(image)

# Fill the gaps between mouse events
func _stroke(from: Vector2i, to: Vector2i) -> void:
	var steps := maxi(maxi(absi(to.x - from.x), absi(to.y - from.y)), 1)
	for i in steps + 1:
		_stamp(Vector2i(Vector2(from).lerp(Vector2(to), float(i) / steps)))

func _stamp(center: Vector2i) -> void:
	for x in range(-brush_radius, brush_radius + 1):
		for y in range(-brush_radius, brush_radius + 1):
			if x * x + y * y > brush_radius * brush_radius:
				continue
			var p := center + Vector2i(x, y)
			if p.x >= 0 and p.y >= 0 and p.x < image.get_width() and p.y < image.get_height():
				image.set_pixelv(p, brush_color)

func clear() -> void:
	image.fill(Color(0, 0, 0, 0))
	texture.update(image)
