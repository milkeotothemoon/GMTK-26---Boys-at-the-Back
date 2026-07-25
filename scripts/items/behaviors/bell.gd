extends SoundItem

var _dropped: bool = false

func _ready() -> void:
	super._ready()
	can_retrigger = true
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_landed)

func activate(source: Node = null) -> void:
	if GameState.current_phase != GameState.Phase.RUN:
		return
	super.activate(source)
	if not _dropped:
		_drop()

func _drop() -> void:
	_dropped = true
	is_dynamic = true
	freeze = false
	set_deferred("collision_layer", 1 << 1)  # join physics_objects

func _on_landed(body: Node) -> void:
	if not _dropped or GameState.current_phase != GameState.Phase.RUN:
		return
	if body.has_method("activate"):
		body.activate(self)
	activate(self)
	set_deferred("contact_monitor", false)
