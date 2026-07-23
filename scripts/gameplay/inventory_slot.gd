extends Area2D
class_name InventorySlot

## Drag threshold in pixels before we count this as a real drag (avoids
## spawning an item on an accidental single click).
const DRAG_THRESHOLD := 6.0

@export var item_scene: PackedScene
@export var item_label: String = ""

var _press_pos: Vector2
var _pressed: bool = false
var _spawned: BaseItem = null

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressed = true
			_press_pos = event.global_position
		else:
			_pressed = false

func _process(_delta: float) -> void:
	if not _pressed or _spawned != null:
		return
	if get_global_mouse_position().distance_to(_press_pos) < DRAG_THRESHOLD:
		return
	_spawn_and_start_drag()

func _spawn_and_start_drag() -> void:
	if item_scene == null:
		push_warning("InventorySlot '%s' has no item_scene assigned." % name)
		return

	var container := get_tree().get_first_node_in_group("placed_items_container")
	if container == null:
		push_warning("No PlacedItems container found (missing 'placed_items_container' group).")
		return

	_spawned = item_scene.instantiate()
	container.add_child(_spawned)
	_spawned.global_position = get_global_mouse_position()
	_spawned.start_drag()
	_pressed = false
	_spawned = null
