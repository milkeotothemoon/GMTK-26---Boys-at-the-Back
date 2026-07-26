extends CharacterBody2D

func _ready() -> void:
	var s: AnimatedSprite2D = $AnimatedSprite2D
	if s.sprite_frames and s.sprite_frames.has_animation("idle"):
		s.play("idle")
