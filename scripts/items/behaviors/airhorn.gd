extends SoundItem

@export var charge_per_tick: float = 5.0
@export var tick_seconds: float = 0.25
@export var max_decibels: float = 50.0

var _charge: float = 10.0
var _timer: float = 0.0
var _spent: bool = false

func _ready() -> void:
	super._ready()
	can_retrigger = false
	_charge = decibel_value

func _physics_process(delta: float) -> void:
	if GameState.current_phase != GameState.Phase.RUN or _spent:
		return
	var top := get_node_or_null("TopArea") as Area2D
	if top == null:
		return
	var pressed := false
	for b in top.get_overlapping_bodies():
		if b is RigidBody2D and b != self:
			pressed = true
			break
	if not pressed:
		return
	_timer += delta
	if _timer >= tick_seconds:
		_timer = 0.0
		_charge = min(_charge + charge_per_tick, max_decibels)
		if _charge >= max_decibels:
			_blow()

func _compute_decibels() -> float:
	return _charge

func _blow() -> void:
	if _spent:
		return
	_spent = true
	activate(self)
	await get_tree().create_timer(0.3).timeout
	queue_free()

func can_still_fire() -> bool:
	return not _spent
