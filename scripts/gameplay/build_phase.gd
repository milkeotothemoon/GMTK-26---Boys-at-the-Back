extends Node2D

signal build_locked

@onready var timer: Timer = $Timer
@onready var level_label: Label = $UpperRightCorner/LevelLabel
@onready var transition: CanvasLayer = $PhaseTransition
@onready var click_player = $ClickPlayer
@onready var item_count_label: Label = $ItemCount
@onready var alarm_hand: Node2D = $AlarmHand
var _digit_textures: Array[Texture2D] = []
var _build_started: bool = false
var _placed_items: Node = null

func _ready() -> void:
	_connect_buttons(self)
	level_label.text = "%d" % GameState.current_level_index
	for i in range(10):
		_digit_textures.append(load("res://assets/fonts/digits/digit_%d.png" % i))
	_placed_items = get_tree().get_first_node_in_group("placed_items_container")
	if LevelData.active_config == null:
		LevelData.load_level(GameState.current_level_index)
	GameState.set_phase(GameState.Phase.TRANSITION)

	await ScreenTransition.open()

	var tut := get_node_or_null("TutorialPanel")
	if tut and GameState.current_level_index == 0 and not GameState.has_played_tutorial:
		tut.start()
		await tut.tutorial_finished
		GameState.has_played_tutorial = true

	await transition.play_start_countdown()
	start_build_phase()

func start_build_phase() -> void:
	GameState.set_phase(GameState.Phase.BUILD)
	var sleeper := get_tree().get_first_node_in_group("sleeper_portrait")
	if sleeper:
		sleeper.reset_to_sleeping()
	_build_started = true
	timer.start(60.0)

func _process(_delta: float) -> void:
	_update_item_count()
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

func _update_item_count() -> void:
	if item_count_label == null or _placed_items == null:
		return
	var cap := 999
	if LevelData.active_config != null:
		cap = LevelData.active_config.item_cap
	var used := _placed_items.get_child_count()
	item_count_label.text = "%d / %d" % [used, cap]
	item_count_label.modulate = Color(1, 0.45, 0.4) if used >= cap else Color.WHITE

func _on_timer_timeout() -> void:
	GameState.set_phase(GameState.Phase.TRANSITION)
	$TimerDisplay/DigitSec1.texture = _digit_textures[0]
	$TimerDisplay/DigitSec0.texture = _digit_textures[0]
	await transition.play_build_to_run()
	$TimerDisplay.visible = false
	item_count_label.visible = false
	build_locked.emit()

func _connect_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(_play_click)
		_connect_buttons(child)

func _play_click():
	click_player.play()
