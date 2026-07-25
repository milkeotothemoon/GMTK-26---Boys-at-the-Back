extends SoundItem

@export var power_radius: float = 2.5

func _fire() -> void:
	super._fire()
	_power_nearby_utils()

func _power_nearby_utils() -> void:
	for n in get_parent().get_children():
		if n is UtilItem and n.is_placed:
			if n.grid_position.distance_to(grid_position) <= power_radius:
				(n as UtilItem).power_on()
