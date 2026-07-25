extends Node2D

signal build_locked

@onready var timer: Timer = $Timer
@onready var level_label: Label = $UpperRightCorner/LevelLabel
@onready var transition: CanvasLayer = $PhaseTransition
var _digit_textures: Array[Texture2D] = []
var _build_started: bool = false

func _ready() -> void:
	level_label.text = "%d" % GameState.current_level_index
	for i in range(10):
		_digit_textures.append(load("res://assets/fonts/digits/digit_%d.png" % i))
	if LevelData.active_config == null:
		LevelData.load_level(GameState.current_level_index)
	GameState.set_phase(GameState.Phase.BUILD)
	await ScreenTransition.open()
	await transition.play_start_countdown()
	start_build_phase()

func start_build_phase() -> void:
	var sleeper := get_tree().get_first_node_in_group("sleeper_portrait")
	if sleeper:
		sleeper.reset_to_sleeping()
	_build_started = true
	timer.start(60.0)

func _process(_delta: float) -> void:
	if not _build_started:
		return
	if GameState.current_phase != GameState.Phase.BUILD:
		return
	var seconds := int(ceil(timer.time_left))
	if seconds < 0:
		seconds = 0
	@warning_ignore("integer_division")
	$TimerDisplay/DigitSec1.texture = _digit_textures[(seconds / 10) % 10]
	$TimerDisplay/DigitSec0.texture = _digit_textures[seconds % 10]

func _on_timer_timeout() -> void:
	GameState.set_phase(GameState.Phase.TRANSITION)
	$TimerDisplay/DigitSec1.texture = _digit_textures[0]
	$TimerDisplay/DigitSec0.texture = _digit_textures[0]
	await transition.play_build_to_run()
	$TimerDisplay.visible = false
	build_locked.emit()
