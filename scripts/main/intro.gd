extends Node2D

@onready var video_player: VideoStreamPlayer = $VideoPlayer

func _ready() -> void:
	video_player.finished.connect(_go_to_home)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_go_to_home()

func _go_to_home() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/main/Home.tscn")
