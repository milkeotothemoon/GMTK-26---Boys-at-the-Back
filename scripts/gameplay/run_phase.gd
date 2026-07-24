extends Node

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

	for item in _active_sound_items:
		_trigger_sound_item(item)

func _trigger_sound_item(item: SoundItem) -> void:
	var mult := 1.0
	for sibling in _placed_items.get_children():
		if sibling is ModifierItem and sibling.attached_to == item:
			mult *= 1.5
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


func _on_level_0_build_locked() -> void:
	pass # Replace with function body.
