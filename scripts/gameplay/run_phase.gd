extends Node2D

signal run_completed

const SETTLE_SPEED := 12.0
const SETTLE_HOLD := 1.0
const HARD_TIMEOUT := 30.0

var _running: bool = false
var _placed_items: Node = null
var _settle_timer: float = 0.0
var _elapsed: float = 0.0

func start_run() -> void:
	if _running:
		return
	_placed_items = get_tree().get_first_node_in_group("placed_items_container")
	if _placed_items == null:
		_finish_run()
		return
	AudioManager.reset()
	_running = true
	_settle_timer = 0.0
	_elapsed = 0.0
	GameState.set_phase(GameState.Phase.RUN)
	_kickoff()

func _kickoff() -> void:
	# Anything that self-starts at run begin goes here.
	# Dynamic items simply fall once unfrozen by BaseItem._enter_run_mode().
	pass

func _physics_process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	if _elapsed >= HARD_TIMEOUT:
		_finish_run()
		return
	if _everything_settled():
		_settle_timer += delta
		if _settle_timer >= SETTLE_HOLD:
			_finish_run()
	else:
		_settle_timer = 0.0

func _everything_settled() -> bool:
	for n in _placed_items.get_children():
		if n is RigidBody2D:
			var rb := n as RigidBody2D
			if not rb.freeze and rb.linear_velocity.length() > SETTLE_SPEED:
				return false
		if n is SoundItem and (n as SoundItem).is_busy():
			return false
	return true

func _finish_run() -> void:
	if not _running and _placed_items != null:
		return
	_running = false
	GameState.set_phase(GameState.Phase.SCORE)
	run_completed.emit()
	var star_count := ScoringSystem.calculate_stars(AudioManager.decibel_total, LevelData.active_config)
	var sleeper := get_tree().get_first_node_in_group("sleeper_portrait")
	if sleeper:
		sleeper.react_to_stars(star_count)
	var score_hud := get_tree().get_first_node_in_group("score_hud")
	if score_hud:
		score_hud.show_result(star_count)
