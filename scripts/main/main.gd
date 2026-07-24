extends Node2D

func _ready() -> void:
	call_deferred("_go_to_intro")

func _go_to_intro() -> void:
	get_tree().change_scene_to_file("res://scenes/main/Intro.tscn")
