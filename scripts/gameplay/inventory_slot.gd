extends Area2D
class_name InventorySlot

@export var item_scene: PackedScene
@export var item_label: String = ""
@export var item_id: String = ""
@export var is_locked: bool = false

var _lock_overlay: Label = null

func _ready() -> void:
	var lbl := get_node_or_null("Label")
	if lbl:
		lbl.text = _get_initials(item_label)

	_resolve_lock_state()

	if is_locked:
		modulate = Color(0.45, 0.45, 0.45, 0.6)
		_add_lock_overlay()

func _resolve_lock_state() -> void:
	# An explicit is_locked = true in the scene always wins.
	if is_locked:
		return
	var cfg: LevelConfig = LevelData.active_config
	if cfg == null:
		return
	# Empty allowed list means "everything is available this level".
	if cfg.allowed_item_ids.is_empty():
		return
	var id := item_id if item_id != "" else item_label.to_lower()
	is_locked = not (id in cfg.allowed_item_ids)

func _add_lock_overlay() -> void:
	_lock_overlay = Label.new()
	_lock_overlay.text = "🔒"
	_lock_overlay.add_theme_font_size_override("font_size", 28)
	_lock_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lock_overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lock_overlay.offset_left = -25.0
	_lock_overlay.offset_top = -45.0
	_lock_overlay.offset_right = 25.0
	_lock_overlay.offset_bottom = -15.0
	_lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock_overlay.modulate = Color(1, 1, 1, 1)
	add_child(_lock_overlay)

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
