extends BaseItem
class_name UtilItem

@export var effect_strength: float = 1.0
@export var effect_kind: String = "amplify"  # "amplify" | "repeat"
signal effect_applied

func activate() -> void:
	_apply_effect()
	effect_applied.emit()

func _apply_effect() -> void:
	match effect_kind:
		"amplify":
			AudioManager.decibel_total += 5.0 * effect_strength
		"repeat":
			for n in get_parent().get_children():
				if n is SoundItem and n.grid_position.distance_to(grid_position) <= 1.5:
					AudioManager.add_decibels(n.decibel_value * 0.5)
