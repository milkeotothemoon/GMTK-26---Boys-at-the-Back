extends AnimatedSprite2D

func _ready() -> void:
	add_to_group("sleeper_portrait")
	play("sleeping")

func reset_to_sleeping() -> void:
	play("sleeping")

func react_to_stars(star_count: int) -> void:
	match star_count:
		0: play("sleeping")
		1: play("eyes_open")
		2: play("annoyed")
		_: play("alert")
