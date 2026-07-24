extends Node

const CELL_SIZE := 67
const GRID_WIDTH := 10
const GRID_HEIGHT := 10

func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / float(CELL_SIZE)), floori(world_pos.y / float(CELL_SIZE)))

func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT
