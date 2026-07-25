extends Node2D

const MAX_LEVEL_INDEX := 3

@onready var panel: Panel = $LevelPanel
@onready var title_label: Label = $LevelPanel/TitleLabel
@onready var desc_label: Label = $LevelPanel/DescriptionLabel
@onready var play_button: Button = $LevelPanel/PlayButton

var _selected: int = -1

func _ready() -> void:
	panel.visible = false
	for i in range(MAX_LEVEL_INDEX + 1):
		var btn := get_node_or_null("Houses/House%d" % i)
		if btn == null:
			continue
		btn.pressed.connect(_on_house_pressed.bind(i))
		var locked := _is_locked(i)
		btn.disabled = locked
		btn.modulate = Color(0.45, 0.45, 0.45, 1.0) if locked else Color.WHITE
	ScreenTransition.open()

func _is_locked(index: int) -> bool:
	if index <= 0:
		return false
	var prev := index - 1
	return not GameState.star_results.has(prev) or GameState.star_results[prev] <= 0

func _on_house_pressed(index: int) -> void:
	_selected = index
	var cfg: LevelConfig = load("res://resources/level_configs/level%d_config.tres" % index)
	if cfg:
		title_label.text = cfg.level_name if cfg.level_name != "" else "Level %d" % index
		desc_label.text = cfg.description
	else:
		title_label.text = "Level %d" % index
		desc_label.text = ""
	panel.visible = true

func _on_close_pressed() -> void:
	panel.visible = false
	_selected = -1

func _on_play_pressed() -> void:
	if _selected < 0 or _selected > MAX_LEVEL_INDEX:
		return
	if _is_locked(_selected):
		return
	GameState.current_level_index = _selected
	LevelData.load_level(_selected)
	await ScreenTransition.close()
	get_tree().change_scene_to_file("res://scenes/levels/Level%d.tscn" % _selected)

func _on_back_pressed() -> void:
	await ScreenTransition.close()
	get_tree().change_scene_to_file("res://scenes/main/Home.tscn")
