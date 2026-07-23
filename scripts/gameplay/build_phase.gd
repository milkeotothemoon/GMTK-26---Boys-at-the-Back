extends Node2D

signal build_locked

@onready var timer: Timer = $Timer

func start_build_phase() -> void:
	timer.start(60.0)

func _on_timer_timeout() -> void:
	build_locked.emit()
