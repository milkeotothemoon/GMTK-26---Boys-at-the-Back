extends SoundItem

@export var bonus_per_object: float = 5.0

func _compute_decibels() -> float:
	var total := decibel_value
	var slot := get_node_or_null("ContentsArea") as Area2D
	if slot:
		for b in slot.get_overlapping_bodies():
			if b is PhysicsItem:
				total += bonus_per_object
	return total
