extends SoundItem

const EGG_SCENE := preload("res://scenes/items/physics/Egg.tscn")

@export var egg_speed: float = 500.0
@export var fire_direction: Vector2 = Vector2.RIGHT

func _fire() -> void:
	super._fire()
	_lay_egg()

func _lay_egg() -> void:
	var egg := EGG_SCENE.instantiate()
	get_parent().add_child(egg)
	egg.global_position = global_position + fire_direction.normalized() * 40.0
	egg.is_placed = true
	egg.gravity_scale = 0.0
	egg.call_deferred("_enter_run_mode")
	egg.call_deferred("apply_central_impulse", fire_direction.normalized() * egg_speed)
