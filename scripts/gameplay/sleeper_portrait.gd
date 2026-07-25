extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("sleeper_portrait")
	sprite.play("sleeping")

func reset_to_sleeping() -> void:
	sprite.play("sleeping")

func react_to_stars(star_count: int) -> void:
	match star_count:
		0: sprite.play("sleeping")
		1: sprite.play("eyes_open")
		2: sprite.play("annoyed")
		_: sprite.play("alert")
