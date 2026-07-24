extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/main/LevelSelection.tscn")

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/main/Credits.tscn")
