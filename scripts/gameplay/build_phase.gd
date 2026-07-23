extends Node2D

signal build_locked

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $TimerLabel
@onready var level_label: Label = $Panel/LevelLabel

func _ready() -> void:
	level_label.text = "%02d" % GameState.current_level_index
	start_build_phase()

func start_build_phase() -> void:
	GameState.is_build_locked = false
	timer.start(60.0)

func _process(_delta: float) -> void:
	var seconds := int(ceil(timer.time_left))
	if seconds < 0:
		seconds = 0
	@warning_ignore("integer_division")
	timer_label.text = "%02d:%02d" % [seconds / 60, seconds % 60]

func _on_timer_timeout() -> void:
	GameState.is_build_locked = true
	timer_label.text = "00:00"
	build_locked.emit()
