extends BaseItem
class_name UtilItem

@export var effect_kind: String = "push"  # push | lift | blow | launch
@export var effect_strength: float = 400.0
@export var direction: Vector2 = Vector2.RIGHT
@export var one_shot: bool = false
@export var power_radius: float = 2.5

signal effect_applied

var _powered: bool = false
var _used: bool = false

func _run_collision_layer() -> int:
	return 1 << 3  # utils

func power_on() -> void:
	_powered = true

func has_engine_nearby() -> bool:
	for n in get_parent().get_children():
		if n is SoundItem and n.item_id == "engine" and n.is_placed:
			if n.grid_position.distance_to(grid_position) <= power_radius:
				return true
	return false

func activate(_source: Node = null) -> void:
	if has_engine_nearby():
		power_on()

func _physics_process(_delta: float) -> void:
	if GameState.current_phase != GameState.Phase.RUN or not _powered:
		return
	if one_shot and _used:
		return
	var area := get_node_or_null("EffectArea") as Area2D
	if area == null:
		return
	for body in area.get_overlapping_bodies():
		if body is RigidBody2D and not (body as RigidBody2D).freeze:
			_apply_to(body as RigidBody2D)
			_used = true
			effect_applied.emit()
			if one_shot:
				return

func _apply_to(body: RigidBody2D) -> void:
	match effect_kind:
		"push":
			body.apply_central_impulse(direction.normalized() * effect_strength)
		"blow":
			body.apply_central_force(direction.normalized() * effect_strength)
		"lift":
			body.apply_central_force(Vector2.UP * effect_strength)
		"launch":
			var d := Vector2(direction.normalized().x, -1).normalized()
			body.apply_central_impulse(d * effect_strength)
