extends BaseItem
class_name ConnectorItem

@export var snaps_on_hit: bool = false
@export var snap_impulse_threshold: float = 60.0

var _snapped: bool = false

func _run_collision_layer() -> int:
	return 1 << 4  # connectors

func _ready() -> void:
	super._ready()
	if snaps_on_hit:
		contact_monitor = true
		max_contacts_reported = 4
		body_entered.connect(_on_hit)

func _on_hit(body: Node) -> void:
	if GameState.current_phase != GameState.Phase.RUN or _snapped:
		return
	if body is RigidBody2D and (body as RigidBody2D).linear_velocity.length() >= snap_impulse_threshold:
		_snap()

func _snap() -> void:
	_snapped = true
	_play_visual("break")
	await get_tree().create_timer(0.3).timeout
	queue_free()
