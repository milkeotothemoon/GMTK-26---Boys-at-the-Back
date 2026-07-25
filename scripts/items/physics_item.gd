extends BaseItem
class_name PhysicsItem

## Physics objects activate whatever they collide with.
@export var activates_on_contact: bool = true
@export var breaks_on_impact: bool = false
@export var min_impact_speed: float = 40.0

var _broken: bool = false

func _ready() -> void:
	super._ready()
	is_dynamic = true
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

func _run_collision_layer() -> int:
	return 1 << 1  # physics_objects

func _on_body_entered(body: Node) -> void:
	if GameState.current_phase != GameState.Phase.RUN or _broken:
		return
	if activates_on_contact and body.has_method("activate"):
		body.activate(self)
	if breaks_on_impact and linear_velocity.length() >= min_impact_speed:
		_break()

func _break() -> void:
	_broken = true
	set_deferred("freeze", true)
	await get_tree().create_timer(0.1).timeout
	queue_free()
