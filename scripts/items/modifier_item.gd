extends BaseItem
class_name ModifierItem

@export var area_radius: int = 1  # 1 = 3x3, 2 = 5x5
@export var replays_on_hit: bool = false

var attached_to: SoundItem = null  # legacy, unused by area amps
var _captured: float = 0.0
var _has_replayed: bool = false

func _run_collision_layer() -> int:
	return 1 << 2

func _ready() -> void:
	super._ready()
	AudioManager.sound_fired.connect(_on_any_sound_fired)

func _on_any_sound_fired(_src: String, amount: float) -> void:
	if GameState.current_phase != GameState.Phase.RUN:
		return
	_captured += amount

func _in_area(other: BaseItem) -> bool:
	var d := other.grid_position - grid_position
	return abs(d.x) <= area_radius and abs(d.y) <= area_radius

func activate(_source: Node = null) -> void:
	if GameState.current_phase != GameState.Phase.RUN:
		return
	if not replays_on_hit and _has_replayed:
		return
	_replay()

func _replay() -> void:
	var total := 0.0
	for n in get_parent().get_children():
		if n is SoundItem and n.is_placed and _in_area(n):
			total += (n as SoundItem).decibel_value
	if total <= 0.0:
		return
	_has_replayed = true
	_play_visual("active")
	AudioManager.report_sound(item_id + "_replay", total)
