extends GridContainer

var _cells: Array[Panel] = []
var _base_style: StyleBoxFlat
var _hover_style: StyleBoxFlat

func _ready() -> void:
	add_to_group("build_space_view")
	columns = BuildSpace.GRID_WIDTH
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)

	_base_style = StyleBoxFlat.new()
	_base_style.bg_color = Color(0, 0, 0, 0)
	_base_style.border_width_left = 2
	_base_style.border_width_top = 2
	_base_style.border_width_right = 2
	_base_style.border_width_bottom = 2
	_base_style.border_color = Color.BLACK

	_hover_style = _base_style.duplicate()
	_hover_style.bg_color = Color(0.5, 0.5, 0.5, 0.5)

	for i in range(BuildSpace.GRID_WIDTH * BuildSpace.GRID_HEIGHT):
		var cell := Panel.new()
		cell.custom_minimum_size = Vector2(BuildSpace.CELL_SIZE, BuildSpace.CELL_SIZE)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_theme_stylebox_override("panel", _base_style)
		add_child(cell)
		_cells.append(cell)

func highlight_cell(cell: Vector2i) -> void:
	clear_highlight()
	var index := cell.y * BuildSpace.GRID_WIDTH + cell.x
	if index >= 0 and index < _cells.size():
		_cells[index].add_theme_stylebox_override("panel", _hover_style)

func clear_highlight() -> void:
	for cell in _cells:
		cell.add_theme_stylebox_override("panel", _base_style)
