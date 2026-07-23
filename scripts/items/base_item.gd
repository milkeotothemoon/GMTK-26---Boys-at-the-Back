extends Area2D
class_name BaseItem

@export var item_id: String
var grid_position: Vector2i
var is_placed: bool = false
var _dragging: bool = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		_dragging = true
	elif event is InputEventMouseButton and not event.pressed and _dragging:
		_dragging = false
		_try_drop()

func _process(_delta: float) -> void:
	if _dragging:
		global_position = get_global_mouse_position()

func start_drag() -> void:
	_dragging = true

func _try_drop() -> void:
	var cell: Vector2 = BuildSpace.world_to_grid(global_position)
	if BuildSpace.is_valid_cell(cell):
		place(cell)
	else:
		pick_up()

func place(cell: Vector2i) -> void:
	grid_position = cell
	is_placed = true
	position = BuildSpace.grid_to_world(cell)

func pick_up() -> void:
	is_placed = false
