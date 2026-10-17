extends Node

class_name SimilarityManager

enum EnemyType {
	SPEAR,
	ARCHER,
	BEAST
}

class EnemyBinding:
	var callback: Callable
	var completeness_threshold: float
	var accuracy_threshold: float
	var triggered := false

	func _init(p_callback: Callable, p_completeness_threshold: float, p_accuracy_threshold: float) -> void:
		callback = p_callback
		completeness_threshold = p_completeness_threshold
		accuracy_threshold = p_accuracy_threshold

@export var draw_canvas: DrawTexture
@export var enemy_types: Array[EnemyType]
@export var sprite_path_format := "res://sprites/%s.png"  # %s = lowercase enum name, e.g. spear
@export var grid_size := 48
@export var recall_tolerance := 1     # how close a stroke must be for part of the enemy to count as drawn
@export var precision_tolerance := 2  # how far a stroke can stray from the enemy before it counts as wrong
@export var falloff := 3.0            # cells beyond the tolerance over which credit drops to zero

@export_group("Debug")
@export var is_debug := true:
	set(value):
		is_debug = value
		_update_debug_visibility()
@export var diff_sprite: TextureRect  # optional, only used when is_debug is on
@export var similarity_text: Label    # optional, only used when is_debug is on
@export var recall_weight := 2.0      # weighting for the overall similarity shown in the debug text

var _targets := {}   # EnemyType -> { "mask": PackedByteArray, "dist": PackedInt32Array }
var _bindings := {}  # EnemyType -> Array of EnemyBinding


## Calls `callback(enemy_type, completeness, accuracy)` once each time the drawing reaches both
## thresholds (0 to 1) for `enemy_type`. Completeness is how much of the enemy was drawn,
## accuracy is how much of the drawing lies on the enemy. It can fire again after either
## value drops back below its threshold. Any number of callbacks can share a type.
func bind_to_enemy_drawn(callback: Callable, enemy_type: EnemyType, completeness_threshold: float, accuracy_threshold: float) -> void:
	if not enemy_types.has(enemy_type):
		push_error("Enemy type %s is not in enemy_types." % _type_name(enemy_type))
		return
	if not _bindings.has(enemy_type):
		_bindings[enemy_type] = []
	_bindings[enemy_type].append(EnemyBinding.new(callback, completeness_threshold, accuracy_threshold))


## Removes every binding of `callback` for `enemy_type`.
func unbind_from_enemy_drawn(callback: Callable, enemy_type: EnemyType) -> void:
	if not _bindings.has(enemy_type):
		return
	var list: Array = _bindings[enemy_type]
	for i in range(list.size() - 1, -1, -1):
		if list[i].callback == callback:
			list.remove_at(i)
	if list.is_empty():
		_bindings.erase(enemy_type)


func _ready() -> void:
	for enemy_type in enemy_types:
		if _targets.has(enemy_type):
			continue
		var mask := _load_target_mask(enemy_type)
		if mask.is_empty():
			continue
		_targets[enemy_type] = { "mask": mask, "dist": _distance_field(mask, grid_size) }

	if is_instance_valid(diff_sprite):
		diff_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_update_debug_visibility()


func _process(_delta: float) -> void:
	if not is_debug and _bindings.is_empty():
		return

	var drawing_mask := _prepare(draw_canvas.image)
	var drawing_dist := _distance_field(drawing_mask, grid_size)

	var lines: PackedStringArray = []
	var best_type := -1
	var best_score := -1.0
	for enemy_type in _targets:
		if not is_debug and not _bindings.has(enemy_type):
			continue

		var target: Dictionary = _targets[enemy_type]
		var accuracy := _coverage(drawing_mask, target["dist"], precision_tolerance)
		var completeness := _coverage(target["mask"], drawing_dist, recall_tolerance)
		_notify(enemy_type, completeness, accuracy)

		if is_debug:
			var similarity := _weighted_f_score(accuracy, completeness, recall_weight)
			lines.append("%s: %.0f%%  (completeness %.0f%%, accuracy %.0f%%)" % [
				_type_name(enemy_type), similarity * 100.0, completeness * 100.0, accuracy * 100.0])
			if similarity > best_score:
				best_score = similarity
				best_type = enemy_type

	if is_debug:
		_update_debug_view(lines, drawing_mask, drawing_dist, best_type)


func _notify(enemy_type: int, completeness: float, accuracy: float) -> void:
	if not _bindings.has(enemy_type):
		return
	var list: Array = _bindings[enemy_type]
	for binding: EnemyBinding in list.duplicate():
		if not list.has(binding):
			continue  # unbound by an earlier callback this frame
		if not binding.callback.is_valid():
			list.erase(binding)  # its object was freed
			continue
		var passed := completeness >= binding.completeness_threshold and accuracy >= binding.accuracy_threshold
		if passed:
			if not binding.triggered:
				binding.triggered = true
				binding.callback.call(enemy_type, completeness, accuracy)
		else:
			binding.triggered = false


func _load_target_mask(enemy_type: int) -> PackedByteArray:
	var path := sprite_path_format % _type_name(enemy_type).to_lower()
	if not ResourceLoader.exists(path):
		push_error("No sprite for %s at %s" % [_type_name(enemy_type), path])
		return PackedByteArray()
	var target := (load(path) as Texture2D).get_image()
	if target.is_compressed():
		target.decompress()
	target.convert(Image.FORMAT_RGBA8)
	return _prepare(target)


func _type_name(enemy_type: int) -> String:
	return EnemyType.keys()[enemy_type]


# Ink -> filled shape -> boundary, so outline drawings and solid sprites compare fairly.
func _prepare(img: Image) -> PackedByteArray:
	var mask := _ink_mask(img, grid_size)
	mask = _silhouette(mask, grid_size)
	return _outline(mask, grid_size)


# Crops to the content, scales it to fit the grid without stretching, and centers it.
@warning_ignore("integer_division")
func _ink_mask(img: Image, grid: int) -> PackedByteArray:
	var mask := PackedByteArray()
	mask.resize(grid * grid)
	var used := img.get_used_rect()
	if used.size == Vector2i.ZERO:
		return mask

	var region := img.get_region(used)
	var scale := float(grid) / maxi(used.size.x, used.size.y)
	var w := clampi(roundi(used.size.x * scale), 1, grid)
	var h := clampi(roundi(used.size.y * scale), 1, grid)
	region.resize(w, h, Image.INTERPOLATE_LANCZOS)

	var ox := (grid - w) / 2
	var oy := (grid - h) / 2
	for y in h:
		for x in w:
			if region.get_pixel(x, y).a > 0.2:
				mask[(y + oy) * grid + (x + ox)] = 1
	return mask


# Fills enclosed areas: empty cells reachable from the grid's edges are outside,
# everything else (ink plus anything it encloses) is part of the shape.
@warning_ignore("integer_division")
func _silhouette(mask: PackedByteArray, grid: int) -> PackedByteArray:
	var outside := PackedByteArray()
	outside.resize(grid * grid)
	var stack: Array[int] = []
	for i in grid:
		stack.append(i)
		stack.append((grid - 1) * grid + i)
		stack.append(i * grid)
		stack.append(i * grid + grid - 1)

	while not stack.is_empty():
		var idx: int = stack.pop_back()
		if outside[idx] or mask[idx]:
			continue
		outside[idx] = 1
		var x := idx % grid
		var y := idx / grid
		if x > 0:
			stack.append(idx - 1)
		if x < grid - 1:
			stack.append(idx + 1)
		if y > 0:
			stack.append(idx - grid)
		if y < grid - 1:
			stack.append(idx + grid)

	var shape := PackedByteArray()
	shape.resize(grid * grid)
	for i in shape.size():
		shape[i] = 0 if outside[i] else 1
	return shape


# Keeps only the boundary of a shape: filled cells touching an empty cell or the grid edge.
func _outline(mask: PackedByteArray, grid: int) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(grid * grid)
	for y in grid:
		for x in grid:
			var i := y * grid + x
			if not mask[i]:
				continue
			if x == 0 or y == 0 or x == grid - 1 or y == grid - 1 \
					or not mask[i - 1] or not mask[i + 1] or not mask[i - grid] or not mask[i + grid]:
				out[i] = 1
	return out


# For every cell, the distance in cells to the nearest set cell of the mask.
@warning_ignore("integer_division")
func _distance_field(mask: PackedByteArray, grid: int) -> PackedInt32Array:
	var dist := PackedInt32Array()
	dist.resize(grid * grid)
	dist.fill(grid * 2)
	var queue: Array[int] = []
	for i in mask.size():
		if mask[i]:
			dist[i] = 0
			queue.append(i)

	var head := 0
	while head < queue.size():
		var idx := queue[head]
		head += 1
		var x := idx % grid
		var y := idx / grid
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var nx := x + dx
				var ny := y + dy
				if nx < 0 or ny < 0 or nx >= grid or ny >= grid:
					continue
				var n := ny * grid + nx
				if dist[n] > dist[idx] + 1:
					dist[n] = dist[idx] + 1
					queue.append(n)
	return dist


# Average credit for the set cells of `cells`: full credit within `tol` cells of the other
# shape, fading to zero over `falloff` more cells.
func _coverage(cells: PackedByteArray, dist: PackedInt32Array, tol: int) -> float:
	var total := 0.0
	var count := 0
	for i in cells.size():
		if not cells[i]:
			continue
		count += 1
		var d := dist[i]
		if d <= tol:
			total += 1.0
		else:
			total += maxf(0.0, 1.0 - float(d - tol) / falloff)
	return 0.0 if count == 0 else total / count


func _weighted_f_score(precision: float, recall: float, beta: float) -> float:
	var b2 := beta * beta
	var denom := b2 * precision + recall
	return 0.0 if denom == 0.0 else (1.0 + b2) * precision * recall / denom


func _update_debug_visibility() -> void:
	if is_instance_valid(diff_sprite):
		diff_sprite.visible = is_debug
	if is_instance_valid(similarity_text):
		similarity_text.visible = is_debug


func _update_debug_view(lines: PackedStringArray, drawing_mask: PackedByteArray, drawing_dist: PackedInt32Array, best_type: int) -> void:
	if is_instance_valid(similarity_text):
		similarity_text.text = "\n".join(lines)
	if is_instance_valid(diff_sprite) and best_type != -1:
		_show_masks(drawing_mask, drawing_dist, _targets[best_type])


# Debug view for the best-matching enemy: green = enemy parts you drew, red = enemy parts
# you missed, blue = strokes off the enemy, grey = strokes close to the enemy.
@warning_ignore("integer_division")
func _show_masks(drawing: PackedByteArray, drawing_dist: PackedInt32Array, target: Dictionary) -> void:
	var target_mask: PackedByteArray = target["mask"]
	var target_dist: PackedInt32Array = target["dist"]
	var grid := grid_size
	var img := Image.create(grid, grid, false, Image.FORMAT_RGBA8)
	for i in drawing.size():
		var c := Color.TRANSPARENT
		if drawing[i]:
			c = Color.BLUE if target_dist[i] > precision_tolerance else Color(1, 1, 1, 0.35)
		if target_mask[i]:
			c = Color.GREEN if drawing_dist[i] <= recall_tolerance else Color.RED
		img.set_pixel(i % grid, i / grid, c)
	diff_sprite.texture = ImageTexture.create_from_image(img)
