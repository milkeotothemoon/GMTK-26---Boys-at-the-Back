extends BaseItem
class_name UtilItem

@export var effect_strength: float = 1.0
signal effect_applied

func activate() -> void:
	_apply_effect()
	effect_applied.emit()

func _apply_effect() -> void:
	pass
