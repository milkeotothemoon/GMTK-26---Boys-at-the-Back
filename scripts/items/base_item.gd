extends RigidBody2D
class_name BaseItem

@export var item_id: String
@export var display_name: String = ""

## Does this item fall and roll during the run phase?
@export var is_dynamic: bool = false

## How many grid cells this item occupies (width x height).
@export var cell_size: Vector2i = Vector2i(1, 1)

var grid_position: Vector2i
var is_placed: bool = false
var _dragging: bool = false

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
	var out: Array[Vector2i] = []
	for x in range(cell_size.x):
		for y in range(cell_size.y):
			out.append(grid_position + Vector2i(x, y))
	return out

func _cells_for(origin: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for x in range(cell_size.x):
		for y in range(cell_size.y):
			out.append(origin + Vector2i(x, y))
	return out

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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_drop()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not _dragging:
		return
	var parent := get_parent() as Node2D
	var local_mouse := parent.to_local(get_global_mouse_position())
	var cell: Vector2i = GridUtils.world_to_grid(local_mouse)
	var view := get_tree().get_first_node_in_group("build_space_view")
	if GridUtils.is_valid_cell(cell):
		modulate = Color.WHITE
		global_position = parent.to_global(_origin_world(cell))
		if view:
			if _can_place_at(cell):
				view.highlight_cells(_cells_for(cell), false)
			else:
				view.highlight_cells(_cells_for(cell), true)
	else:
		global_position = get_global_mouse_position()
		modulate = Color(1.0, 0.4, 0.4, 0.6)
		if view:
			view.clear_highlight()

func _origin_world(cell: Vector2i) -> Vector2:
	var top_left := GridUtils.grid_to_world(cell)
	var span := Vector2(cell_size.x, cell_size.y) * GridUtils.CELL_SIZE
	return top_left + span / 2.0

func _try_drop() -> void:
	var parent := get_parent() as Node2D
	var cell: Vector2i = GridUtils.world_to_grid(parent.to_local(global_position))
	
	if not GridUtils.is_valid_cell(cell):
		_discard()
		return
	
	if not _can_place_at(cell):
		return
	
	place(cell)
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
	if self is ModifierItem:
		(self as ModifierItem).attached_to = null
	if self is SoundItem:
		for n in get_parent().get_children():
			if n is ModifierItem and n.attached_to == self:
				n.attached_to = null

func _play_visual(anim: String) -> void:
	var s := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if s == null or s.sprite_frames == null:
		return
	if s.sprite_frames.has_animation(anim):
		s.play(anim)

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
