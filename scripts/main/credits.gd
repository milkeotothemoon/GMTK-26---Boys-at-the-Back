extends Node2D

func _ready() -> void:
	ScreenTransition.open()

func _on_back_button_pressed() -> void:
	await ScreenTransition.close()
	get_tree().change_scene_to_file("res://scenes/main/Home.tscn")
