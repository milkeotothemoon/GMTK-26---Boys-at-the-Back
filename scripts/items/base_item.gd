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
			view.highlight_cell(cell)
	else:
		position = local_mouse
		if view:
			view.clear_highlight()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_placed and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if not GameState.is_build_locked:
			queue_free()

func _try_drop() -> void:
	var cell: Vector2i = GridUtils.world_to_grid(position)
	if GridUtils.is_valid_cell(cell):
		place(cell)
		_dragging = false
		var view := get_tree().get_first_node_in_group("build_space_view")
		if view:
			view.clear_highlight()

func place(cell: Vector2i) -> void:
	grid_position = cell
	is_placed = true
	position = GridUtils.grid_to_world(cell) + Vector2(GridUtils.CELL_SIZE, GridUtils.CELL_SIZE) / 2.0
	if self is ModifierItem:
		for n in get_parent().get_children():
			if n is SoundItem and n.is_placed and n.grid_position.distance_to(cell) <= 1.5:
				(self as ModifierItem).attach_to(n)
				break

func pick_up() -> void:
	is_placed = false
