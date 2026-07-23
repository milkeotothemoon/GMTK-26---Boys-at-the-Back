extends Area2D
class_name InventorySlot

@export var item_scene: PackedScene
@export var item_label: String = ""
@export var is_locked: bool = false

func _ready() -> void:
	var lbl := get_node_or_null("Label")
	if lbl:
		lbl.text = _get_initials(item_label)
	if is_locked:
		modulate = Color(0.45, 0.45, 0.45, 0.6)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_locked or GameState.is_build_locked:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_spawn_and_start_drag()

func _spawn_and_start_drag() -> void:
	if item_scene == null:
		push_warning("InventorySlot '%s' has no item_scene assigned." % name)
		return

	var container := get_tree().get_first_node_in_group("placed_items_container")
	if container == null:
		push_warning("No PlacedItems container found.")
		return

	var cap := 999
	if LevelData.active_config != null:
		cap = LevelData.active_config.item_cap

	if container.get_child_count() >= cap:
		push_warning("Item cap reached (%d/%d) — can't place more this level." % [container.get_child_count(), cap])
		return

	var spawned: BaseItem = item_scene.instantiate()
	container.add_child(spawned)
	spawned.global_position = get_global_mouse_position()
	spawned.start_drag()

func _get_initials(text: String) -> String:
	var words := text.split(" ", false)
	var initials := ""
	for w in words:
		if w.length() > 0:
			initials += w[0].to_upper()
	return initials
