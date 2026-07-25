extends Control

func _ready() -> void:
	ScreenTransition.open()

func _on_play_button_pressed() -> void:
	await ScreenTransition.close()
	get_tree().change_scene_to_file("res://scenes/main/LevelSelection.tscn")

func _on_credits_button_pressed() -> void:
	await ScreenTransition.close()
	get_tree().change_scene_to_file("res://scenes/main/Credits.tscn")
