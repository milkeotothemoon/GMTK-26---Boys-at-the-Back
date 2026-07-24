extends Area2D
class_name BaseItem

@export var item_id: String
var grid_position: Vector2i
var is_placed: bool = false
var _dragging: bool = false

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
		position = GridUtils.grid_to_world(cell) + Vector2(GridUtils.CELL_SIZE, GridUtils.CELL_SIZE) / 2.0
		if view:
			if _is_cell_occupied(cell):
				view.highlight_cell_blocked(cell)
			else:
				view.highlight_cell(cell)
	else:
		position = local_mouse
		if view:
			view.clear_highlight()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if GameState.is_build_locked:
		return
	if not is_placed:
		return
	if event.button_index == MOUSE_BUTTON_RIGHT:
		queue_free()
	elif event.button_index == MOUSE_BUTTON_LEFT:
		pick_up()
		start_drag()
		get_viewport().set_input_as_handled()

func _is_cell_occupied(cell: Vector2i) -> bool:
	for n in get_parent().get_children():
		if n == self:
			continue
		if n is BaseItem and n.is_placed and n.grid_position == cell:
			return true
	return false

func _try_drop() -> void:
	var cell: Vector2i = GridUtils.world_to_grid(position)
	if not GridUtils.is_valid_cell(cell):
		return
	if _is_cell_occupied(cell):
		return
	place(cell)
	_dragging = false
	var view := get_tree().get_first_node_in_group("build_space_view")
	if view:
		view.clear_highlight()

func _resolve_attachments() -> void:
	if self is ModifierItem:
		var m := self as ModifierItem
		if m.attached_to != null:
			return
		for n in get_parent().get_children():
			if n is SoundItem and n.is_placed and n.grid_position.distance_to(grid_position) <= 1.5:
				m.attach_to(n)
				return
	elif self is SoundItem:
		for n in get_parent().get_children():
			if n is ModifierItem and n.is_placed and n.attached_to == null:
				if n.grid_position.distance_to(grid_position) <= 1.5:
					n.attach_to(self as SoundItem)

func place(cell: Vector2i) -> void:
	grid_position = cell
	is_placed = true
	position = GridUtils.grid_to_world(cell) + Vector2(GridUtils.CELL_SIZE, GridUtils.CELL_SIZE) / 2.0
	_resolve_attachments()

func pick_up() -> void:
	is_placed = false
	if self is ModifierItem:
		(self as ModifierItem).attached_to = null
	if self is SoundItem:
		for n in get_parent().get_children():
			if n is ModifierItem and n.attached_to == self:
				n.attached_to = null
