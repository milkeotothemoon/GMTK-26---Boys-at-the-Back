extends Control

const DEMO_LAST_LEVEL := 0
const OUTRO_SCENE := "res://scenes/main/Outro.tscn"
const LEVEL_SELECT_SCENE := "res://scenes/main/LevelSelection.tscn"

@onready var result_panel: Panel = $ResultPanel
@onready var score_label: Label = $ResultPanel/ScoreLabel
@onready var result_label: Label = $ResultPanel/ResultLabel
@onready var stars: Array[TextureRect] = [
	$ResultPanel/StarsDisplay/Star1,
	$ResultPanel/StarsDisplay/Star2,
	$ResultPanel/StarsDisplay/Star3,
]
@onready var primary_button: Button = $ResultPanel/PrimaryButton
@onready var secondary_button: Button = $ResultPanel/SecondaryButton
@onready var result_face: TextureRect = $ResultPanel/ResultFace

var star_filled: Texture2D = preload("res://assets/sprites/ui/star_filled.png")
var star_empty: Texture2D = preload("res://assets/sprites/ui/star_empty.png")

var _star_count: int = 0
var _leaving: bool = false

const FACE_HAPPY := preload("res://assets/sprites/ui/goblin_happy.png")
const FACE_SAD := preload("res://assets/sprites/ui/goblin_sad.png")

func _ready() -> void:
	add_to_group("score_hud")
	visible = false
	primary_button.pressed.connect(_on_primary_pressed)
	secondary_button.pressed.connect(_on_secondary_pressed)

func _is_demo_end() -> bool:
	return GameState.current_level_index >= DEMO_LAST_LEVEL

func show_result(star_count: int) -> void:
	_star_count = star_count
	result_face.texture = FACE_SAD if star_count == 0 else FACE_HAPPY

	GameState.star_results[GameState.current_level_index] = max(
		GameState.star_results.get(GameState.current_level_index, 0), star_count
	)
	if GameState.current_level_index == 0:
		GameState.has_played_tutorial = true

	for i in range(3):
		stars[i].texture = star_filled if i < star_count else star_empty

	score_label.text = "%.0f pts" % AudioManager.decibel_total
	result_label.text = "You Failed" if star_count == 0 else "You Did It!"

	if star_count == 0:
		primary_button.text = "Retry"
		secondary_button.text = "Go Back"
	elif _is_demo_end():
		primary_button.text = "Finish Demo"
		secondary_button.text = "Retry"
	else:
		primary_button.text = "Continue"
		secondary_button.text = "Retry"

	visible = true

func _on_primary_pressed() -> void:
	if _leaving:
		return
	if _star_count == 0:
		_leaving = true
		get_tree().reload_current_scene()
	else:
		await _go_to_outro()

func _on_secondary_pressed() -> void:
	if _leaving:
		return
	if _star_count == 0:
		await _go_to_outro()
	else:
		_leaving = true
		get_tree().reload_current_scene()

func _go_to_outro() -> void:
	_leaving = true
	await ScreenTransition.close()
	get_tree().change_scene_to_file(OUTRO_SCENE)

func _go_to(path: String) -> void:
	_leaving = true
	await ScreenTransition.close()
	get_tree().change_scene_to_file(path)
