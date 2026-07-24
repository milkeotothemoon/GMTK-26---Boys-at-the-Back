extends Control

@onready var score_label: Label = $ScoreLabel
@onready var result_panel: Panel = $ResultPanel
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
	result_panel.visible = false
	primary_button.pressed.connect(_on_primary_pressed)
	secondary_button.pressed.connect(_on_secondary_pressed)

func _process(_delta: float) -> void:
	if not result_panel.visible:
		score_label.text = "%.0f dB" % AudioManager.decibel_total

func show_result(star_count: int) -> void:
	_star_count = star_count

	GameState.star_results[GameState.current_level_index] = max(
		GameState.star_results.get(GameState.current_level_index, 0), star_count
	)
	if GameState.current_level_index == 0:
		GameState.has_played_tutorial = true

	for i in range(3):
		stars[i].texture = star_filled if i < star_count else star_empty

	if star_count == 0:
		result_label.text = "FAILED"
		primary_button.text = "Retry"
		secondary_button.text = "Back to Home"
	else:
		result_label.text = "%d STAR%s!" % [star_count, "S" if star_count > 1 else ""]
		primary_button.text = "Proceed" if GameState.current_level_index < 5 else "Finish"
		secondary_button.text = "Retry"

	result_panel.visible = true

func _on_primary_pressed() -> void:
	if _star_count == 0:
		get_tree().reload_current_scene()
	elif GameState.current_level_index < 5:
		var next := GameState.current_level_index + 1
		GameState.current_level_index = next
		LevelData.load_level(next)
		get_tree().change_scene_to_file("res://scenes/levels/Level%d.tscn" % next)
	else:
		get_tree().change_scene_to_file("res://scenes/main/Credits.tscn")

func _on_secondary_pressed() -> void:
	if _star_count == 0:
		get_tree().change_scene_to_file("res://scenes/main/Home.tscn")
	else:
		get_tree().reload_current_scene()
