extends BaseItem
class_name SoundItem

@export var decibel_value: float = 10.0
@export var can_retrigger: bool = false
@export var consumed_on_fire: bool = false

signal sound_finished
signal fired(item: SoundItem, amount: float)

var _has_fired: bool = false
var _is_playing: bool = false

func _run_collision_layer() -> int:
	return 1 << 2  # sound_items

func activate(_source: Node = null) -> void:
	if GameState.current_phase != GameState.Phase.RUN:
		return
	if _has_fired and not can_retrigger:
		return
	_has_fired = true
	_fire()

func _fire() -> void:
	var amount := _compute_decibels()
	AudioManager.report_sound(item_id, amount)
	fired.emit(self, amount)
	_play_audio()
	if consumed_on_fire:
		_consume()

func _compute_decibels() -> float:
	return decibel_value

func _play_audio() -> void:
	var p := get_node_or_null("AudioStreamPlayer2D") as AudioStreamPlayer2D
	if p == null or p.stream == null:
		_is_playing = true
		await get_tree().create_timer(0.3).timeout
		_is_playing = false
		sound_finished.emit()
		return
	_is_playing = true
	p.play()
	await p.finished
	_is_playing = false
	sound_finished.emit()

func _consume() -> void:
	await get_tree().create_timer(0.35).timeout
	queue_free()

func is_busy() -> bool:
	return _is_playing

func can_still_fire() -> bool:
	if can_retrigger:
		return true
	return not _has_fired
