extends Node2D

func _ready() -> void:
	if $AnimatedSprite2D.sprite_frames and $AnimatedSprite2D.sprite_frames.has_animation("default"):
		$AnimatedSprite2D.play("default")
