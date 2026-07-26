extends Control
@onready var click_player = $ClickPlayer

func _ready() -> void:
	ScreenTransition.open()
	_connect_buttons(self)

func _on_play_button_pressed() -> void:
	await ScreenTransition.close()
	get_tree().change_scene_to_file("res://scenes/main/LevelSelection.tscn")

func _on_credits_button_pressed() -> void:
	await ScreenTransition.close()
	get_tree().change_scene_to_file("res://scenes/main/Credits.tscn")

func _connect_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(_play_click)
		_connect_buttons(child)

func _play_click():
	click_player.play()
