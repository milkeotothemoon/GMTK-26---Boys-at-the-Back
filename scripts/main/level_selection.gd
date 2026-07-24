extends Node2D

func _ready() -> void:
	var locked := not GameState.has_played_tutorial
	for btn in [$Level1Button, $Level2Button, $Level3Button, $Level4Button, $Level5Button]:
		btn.disabled = locked
		btn.modulate = Color(0.45, 0.45, 0.45, 1) if locked else Color.WHITE

func _select_level(index: int) -> void:
	if index != 0 and not GameState.has_played_tutorial:
		return
	GameState.current_level_index = index
	LevelData.load_level(index)
	get_tree().change_scene_to_file("res://scenes/levels/Level%d.tscn" % index)
