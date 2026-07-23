extends Node2D

var _highlighted_cell: Vector2i = Vector2i(-1, -1)
var _has_highlight: bool = false

func _ready() -> void:
	pass

func highlight_cell(cell: Vector2i) -> void:
	_highlighted_cell = cell
	_has_highlight = true
	queue_redraw()

func clear_highlight() -> void:
	_has_highlight = false
	queue_redraw()

func _draw() -> void:
	var w := BuildSpace.GRID_WIDTH
	var h := BuildSpace.GRID_HEIGHT
	var cs := BuildSpace.CELL_SIZE
	for x in range(w + 1):
		draw_line(Vector2(x * cs, 0), Vector2(x * cs, h * cs), Color.BLACK, 2)
	for y in range(h + 1):
		draw_line(Vector2(0, y * cs), Vector2(w * cs, y * cs), Color.BLACK, 2)
	if _has_highlight:
		var top_left := Vector2(_highlighted_cell.x * cs, _highlighted_cell.y * cs)
		draw_rect(Rect2(top_left, Vector2(cs, cs)), Color(1, 1, 0, 0.35), true)
