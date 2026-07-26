extends Node2D

const MAX_LEVEL_INDEX := 3

@onready var panel: Panel = $LevelPanel
@onready var panel_art: TextureRect = $LevelPanel/Image
@onready var play_button: Button = $LevelPanel/PlayButton
@onready var click_player = $ClickPlayer

var _selected: int = -1

const PANEL_IMAGES = [
	preload("res://assets/sprites/ui/level select/00 TRANSPARENT.png"),
	preload("res://assets/sprites/ui/level select/01 TRANSPARENT.png"),
	preload("res://assets/sprites/ui/level select/02 TRANSPARENT.png"),
	preload("res://assets/sprites/ui/level select/03 TRANSPARENT.png"),
]

func _ready() -> void:
	_connect_buttons(self)
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
	panel_art.texture = PANEL_IMAGES[index]
	panel.visible = true
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
	
func _connect_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(_play_click)
		_connect_buttons(child)

func _play_click():
	click_player.play()
