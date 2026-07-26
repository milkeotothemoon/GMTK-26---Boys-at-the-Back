extends RigidBody2D
class_name BaseItem

@export var item_id: String
@export var display_name: String = ""
@export var is_dynamic: bool = false
@export var can_rotate: bool = false
@export var can_flip: bool = false
@export var cell_size: Vector2i = Vector2i(1, 1)

var grid_position: Vector2i
var is_placed: bool = false
var _dragging: bool = false
var rot_step: int = 0 
var flipped: bool = false
var _hover_cell: Vector2i = Vector2i(-1, -1)
var _hover_valid: bool = false

func _ready() -> void:
	add_to_group("items")
	_enter_build_mode()
	GameState.phase_changed.connect(_on_phase_changed)
	_play_visual("idle")

func _on_phase_changed(p: int) -> void:
	if p == GameState.Phase.RUN:
		_enter_run_mode()

func _enter_build_mode() -> void:
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)

func _enter_run_mode() -> void:
	set_deferred("collision_layer", _run_collision_layer())
	set_deferred("collision_mask", _run_collision_mask())
	if is_dynamic:
		freeze = false
	else:
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_STATIC

func _run_collision_layer() -> int:
	return 1 << 0

func _run_collision_mask() -> int:
	return 0xFFFFFFFF

func occupied_cells() -> Array[Vector2i]:
	return _cells_for(grid_position)

func _cells_for(origin: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var cs := effective_cell_size()
	for x in range(cs.x):
		for y in range(cs.y):
			out.append(origin + Vector2i(x, y))
	return out

func _footprint_on_grid(origin: Vector2i) -> bool:
	for c in _cells_for(origin):
		if not GridUtils.is_valid_cell(c):
			return false
	return true

func _anchor_offset() -> Vector2i:
	var cs := effective_cell_size()
	@warning_ignore("integer_division")
	return Vector2i(cs.x / 2, cs.y / 2)

func _can_place_at(origin: Vector2i) -> bool:
	var want := _cells_for(origin)
	for c in want:
		if not GridUtils.is_valid_cell(c):
			return false
	for n in get_parent().get_children():
		if n == self or not (n is BaseItem) or not n.is_placed:
			continue
		for c in (n as BaseItem).occupied_cells():
			if c in want:
				return false
	return true

func start_drag() -> void:
	_dragging = true

func _unhandled_input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			rotate_step()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F:
			flip_item()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_drop()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not _dragging:
		return
	var parent := get_parent() as Node2D
	var local_mouse := parent.to_local(get_global_mouse_position())
	var origin: Vector2i = GridUtils.world_to_grid(local_mouse) - _anchor_offset()
	var view := get_tree().get_first_node_in_group("build_space_view")

	_hover_cell = origin
	_hover_valid = _footprint_on_grid(origin)

	if _hover_valid:
		modulate = Color.WHITE
		global_position = parent.to_global(_origin_world(origin))
		if view:
			view.highlight_cells(_cells_for(origin), not _can_place_at(origin))
	else:
		global_position = get_global_mouse_position()
		modulate = Color(1.0, 0.4, 0.4, 0.6)
		if view:
			view.clear_highlight()

func _origin_world(cell: Vector2i) -> Vector2:
	var top_left := GridUtils.grid_to_world(cell)
	var cs := effective_cell_size()
	var span := Vector2(cs.x, cs.y) * GridUtils.CELL_SIZE
	return top_left + span / 2.0

func _try_drop() -> void:
	if not _hover_valid:
		_discard()
		return
	if not _can_place_at(_hover_cell):
		return
	place(_hover_cell)
	_dragging = false
	var view := get_tree().get_first_node_in_group("build_space_view")
	if view:
		view.clear_highlight()

func _discard() -> void:
	_dragging = false
	var view := get_tree().get_first_node_in_group("build_space_view")
	if view:
		view.clear_highlight()
	queue_free()

func place(cell: Vector2i) -> void:
	grid_position = cell
	is_placed = true
	position = _origin_world(cell)
	_resolve_attachments()

func pick_up() -> void:
	is_placed = false
	if get("attached_to") != null:
		set("attached_to", null)
	for n in get_parent().get_children():
		if n == self:
			continue
		if n.get("attached_to") == self:
			n.set("attached_to", null)

func _play_visual(anim: String) -> void:
	var s := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if s == null or s.sprite_frames == null:
		return
	if s.sprite_frames.has_animation(anim):
		s.play(anim)

func rotate_step() -> void:
	if not can_rotate:
		return
	rot_step = (rot_step + 1) % 4
	_apply_orientation()

func flip_item() -> void:
	if not can_flip:
		return
	flipped = not flipped
	_apply_orientation()

func _apply_orientation() -> void:
	var angle := rot_step * (PI / 2.0)

	var s := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if s:
		s.flip_h = flipped
		s.rotation = angle

	var shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape:
		shape.rotation = angle

	# Without this you can't click a rotated beam to pick it back up.
	var click := get_node_or_null("ClickArea/CollisionShape2D") as CollisionShape2D
	if click:
		click.rotation = angle

func effective_cell_size() -> Vector2i:
	if rot_step % 2 == 1:
		return Vector2i(cell_size.y, cell_size.x)
	return cell_size

func _resolve_attachments() -> void:
	pass

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if GameState.is_build_locked or not is_placed:
		return
	if event.button_index == MOUSE_BUTTON_RIGHT:
		queue_free()
	elif event.button_index == MOUSE_BUTTON_LEFT:
		pick_up()
		start_drag()
		get_viewport().set_input_as_handled()
