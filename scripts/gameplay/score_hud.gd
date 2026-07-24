extends Control

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

var star_filled: Texture2D = preload("res://assets/sprites/star_filled.png")
var star_empty: Texture2D = preload("res://assets/sprites/star_empty.png")

var _star_count: int = 0

func _ready() -> void:
	add_to_group("score_hud")
	visible = false
	primary_button.pressed.connect(_on_primary_pressed)
	secondary_button.pressed.connect(_on_secondary_pressed)

func show_result(star_count: int) -> void:
	_star_count = star_count

	GameState.star_results[GameState.current_level_index] = max(
		GameState.star_results.get(GameState.current_level_index, 0), star_count
	)
	if GameState.current_level_index == 0:
		GameState.has_played_tutorial = true

	for i in range(3):
		stars[i].texture = star_filled if i < star_count else star_empty

	score_label.text = "%.0f pts" % AudioManager.decibel_total
	result_label.text = "You Failed" if star_count == 0 else "You Did It!"
	primary_button.text = "Retry" if star_count == 0 else "Continue"
	secondary_button.text = "Go Back" if star_count == 0 else "Retry"

	visible = true

func _on_primary_pressed() -> void:
	if _star_count == 0:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/main/LevelSelection.tscn")

func _on_secondary_pressed() -> void:
	if _star_count == 0:
		get_tree().change_scene_to_file("res://scenes/main/LevelSelection.tscn")
	else:
		get_tree().reload_current_scene()
