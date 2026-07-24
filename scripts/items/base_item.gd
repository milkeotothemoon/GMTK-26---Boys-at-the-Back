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
	var cell := BuildSpace.world_to_grid(local_mouse)
	var view := get_tree().get_first_node_in_group("build_space_view")
	if BuildSpace.is_valid_cell(cell):
		position = BuildSpace.grid_to_world(cell) + Vector2(BuildSpace.CELL_SIZE, BuildSpace.CELL_SIZE) / 2.0
		if view:
			view.highlight_cell(cell)
	else:
		position = local_mouse
		if view:
			view.clear_highlight()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_placed and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		queue_free()

func _try_drop() -> void:
	var cell := BuildSpace.world_to_grid(position)
	if BuildSpace.is_valid_cell(cell):
		place(cell)
		_dragging = false
		var view := get_tree().get_first_node_in_group("build_space_view")
		if view:
			view.clear_highlight()

func place(cell: Vector2i) -> void:
	grid_position = cell
	is_placed = true
	position = BuildSpace.grid_to_world(cell) + Vector2(BuildSpace.CELL_SIZE, BuildSpace.CELL_SIZE) / 2.0

func pick_up() -> void:
	is_placed = false
