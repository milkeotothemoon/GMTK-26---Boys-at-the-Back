extends Node2D

var _active_sound_items: Array[SoundItem] = []
var _run_started: bool = false
var _placed_items: Node = null

func start_run() -> void:
	if _run_started:
		return
	_run_started = true
	AudioManager.reset()

	_placed_items = get_tree().get_first_node_in_group("placed_items_container")
	if _placed_items == null:
		_finish_run()
		return

	_active_sound_items.clear()
	for child in _placed_items.get_children():
		if child is SoundItem:
			_active_sound_items.append(child)
			child.sound_finished.connect(_on_sound_finished.bind(child))

	if _active_sound_items.is_empty():
		_finish_run()
		return

	for child in _placed_items.get_children():
		if child is UtilItem:
			child.activate()

	_run_chain()

func _run_chain() -> void:
	var remaining := _active_sound_items.duplicate()
	var connectors: Array[ConnectorItem] = []
	for child in _placed_items.get_children():
		if child is ConnectorItem and child.is_placed:
			connectors.append(child)

	while not remaining.is_empty():
		var current: SoundItem = remaining.pop_front()
		_trigger_sound_item(current)

		# Follow any connector out of this item to the next sound item.
		var hop_delay := -1.0
		var next_item: SoundItem = null
		for c in connectors:
			for candidate in remaining:
				if c.links(current, candidate):
					next_item = candidate
					hop_delay = c.link_delay
					break
			if next_item != null:
				break

		if next_item != null:
			remaining.erase(next_item)
			remaining.push_front(next_item)
			if hop_delay > 0.0:
				await get_tree().create_timer(hop_delay).timeout
		else:
			# No connector out of this item — brief pause before the next
			# unconnected group so the run has an audible rhythm.
			if not remaining.is_empty():
				await get_tree().create_timer(0.25).timeout

func _trigger_sound_item(item: SoundItem) -> void:
	var mult := 1.0
	for sibling in _placed_items.get_children():
		if sibling is ModifierItem and sibling.attached_to == item:
			mult *= 1.5
		elif sibling is ConnectorItem and sibling.is_placed:
			if sibling.grid_position.distance_to(item.grid_position) <= 1.5:
				mult *= 1.25
	AudioManager.combo_multiplier = mult
	AudioManager.add_decibels(item.decibel_value)
	item.trigger()

func _on_sound_finished(item: SoundItem) -> void:
	_active_sound_items.erase(item)
	if _active_sound_items.is_empty():
		_finish_run()

func _finish_run() -> void:
	var star_count := ScoringSystem.calculate_stars(AudioManager.decibel_total, LevelData.active_config)
	var sleeper := get_tree().get_first_node_in_group("sleeper_portrait")
	if sleeper:
		sleeper.react_to_stars(star_count)
	var score_hud := get_tree().get_first_node_in_group("score_hud")
	if score_hud:
		score_hud.show_result(star_count)
