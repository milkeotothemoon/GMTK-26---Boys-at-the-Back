extends GridContainer

var _cells: Array[Panel] = []
var _base_style: StyleBoxFlat
var _hover_style: StyleBoxFlat
var _blocked_style: StyleBoxFlat

func _ready() -> void:
	add_to_group("build_space_view")
	columns = GridUtils.GRID_WIDTH
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)

	_base_style = StyleBoxFlat.new()
	_base_style.bg_color = Color(0, 0, 0, 0)
	_base_style.border_width_left = 1
	_base_style.border_width_top = 1
	_base_style.border_width_right = 1
	_base_style.border_width_bottom = 1

	_base_style.border_color = Color(0.45, 0.35, 0.25, 0.25)

	_base_style.corner_radius_top_left = 3
	_base_style.corner_radius_top_right = 3
	_base_style.corner_radius_bottom_left = 3
	_base_style.corner_radius_bottom_right = 3
	
	_hover_style = _base_style.duplicate()
	_hover_style.bg_color = Color(0.5, 0.5, 0.5, 0.5)
	
	_blocked_style = _base_style.duplicate()
	_blocked_style.bg_color = Color(0.8, 0.2, 0.2, 0.5)

	for i in range(GridUtils.GRID_WIDTH * GridUtils.GRID_HEIGHT):
		var cell := Panel.new()
		cell.custom_minimum_size = Vector2(GridUtils.CELL_SIZE, GridUtils.CELL_SIZE)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_theme_stylebox_override("panel", _base_style)
		add_child(cell)
		_cells.append(cell)

func highlight_cells(cells: Array[Vector2i], blocked: bool) -> void:
	clear_highlight()
	var style := _blocked_style if blocked else _hover_style
	for c in cells:
		var index := c.y * GridUtils.GRID_WIDTH + c.x
		if index >= 0 and index < _cells.size():
			_cells[index].add_theme_stylebox_override("panel", style)

func clear_highlight() -> void:
	for cell in _cells:
		cell.add_theme_stylebox_override("panel", _base_style)

func set_grid_visible(v: bool) -> void:
	visible = v
