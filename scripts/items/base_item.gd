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
	var mouse_pos := get_global_mouse_position()
	var cell := BuildSpace.world_to_grid(mouse_pos)
	var view := get_tree().get_first_node_in_group("build_space_view")
	if BuildSpace.is_valid_cell(cell):
		global_position = BuildSpace.grid_to_world(cell) + Vector2(BuildSpace.CELL_SIZE, BuildSpace.CELL_SIZE) / 2.0
		if view:
			view.highlight_cell(cell)
	else:
		global_position = mouse_pos
		if view:
			view.clear_highlight()

func _try_drop() -> void:
	var cell := BuildSpace.world_to_grid(global_position)
	if BuildSpace.is_valid_cell(cell):
		place(cell)
		_dragging = false
		var view := get_tree().get_first_node_in_group("build_space_view")
		if view:
			view.clear_highlight()
	# if not over the grid, nothing happens — stays attached to the mouse.
	# this is what makes it "drop only on the BuildSpace"

func place(cell: Vector2i) -> void:
	grid_position = cell
	is_placed = true
	position = BuildSpace.grid_to_world(cell) + Vector2(BuildSpace.CELL_SIZE, BuildSpace.CELL_SIZE) / 2.0

func pick_up() -> void:
	is_placed = false
