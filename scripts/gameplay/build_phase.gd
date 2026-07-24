extends Node2D

signal build_locked

@onready var timer: Timer = $Timer
@onready var level_label: Label = $UpperRightCorner/LevelLabel
var _digit_textures: Array[Texture2D] = []

func _ready() -> void:
	level_label.text = "%d" % GameState.current_level_index
	for i in range(10):
		_digit_textures.append(load("res://assets/fonts/digits/digit_%d.png" % i))
	start_build_phase()

func start_build_phase() -> void:
	GameState.is_build_locked = false
	get_tree().get_first_node_in_group("sleeper_portrait").reset_to_sleeping()
	timer.start(60.0)

func _process(_delta: float) -> void:
	var seconds := int(ceil(timer.time_left))
	if seconds < 0:
		seconds = 0
	@warning_ignore("integer_division")
	$TimerDisplay/DigitSec1.texture = _digit_textures[(seconds / 10) % 10]
	$TimerDisplay/DigitSec0.texture = _digit_textures[seconds % 10]

func _on_timer_timeout() -> void:
	GameState.is_build_locked = true
	$TimerDisplay/DigitSec1.texture = _digit_textures[0]
	$TimerDisplay/DigitSec0.texture = _digit_textures[0]
	build_locked.emit()
