extends SoundItem

@export var bounce_force: float = 600.0

func activate(source: Node = null) -> void:
	super.activate(source)
	if source is PhysicsItem:
		var p := source as PhysicsItem
		if p.item_id == "egg":
			return  # eggs break instead of bouncing
		var away := (p.global_position - global_position).normalized()
		if away == Vector2.ZERO:
			away = Vector2.UP
		p.apply_central_impulse(away * bounce_force)
