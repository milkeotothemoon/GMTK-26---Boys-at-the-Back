extends Node2D

const HOME_SCENE := "res://scenes/main/Home.tscn"
const FADE_IN := 1.2
const HOLD_SECONDS := 3.0

@onready var message: Label = $Message
@onready var sub: Label = $Sub
@onready var back_button: Button = $BackButton

var _leaving: bool = false

func _ready() -> void:
	message.modulate.a = 0.0
	sub.modulate.a = 0.0
	back_button.modulate.a = 0.0
	back_button.disabled = true

	ScreenTransition.open()

	var t := create_tween()
	t.tween_property(message, "modulate:a", 1.0, FADE_IN)
	t.tween_property(sub, "modulate:a", 1.0, 0.6)
	t.tween_property(back_button, "modulate:a", 1.0, 0.5)
	await t.finished

	back_button.disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance()
	elif event is InputEventKey and event.pressed and not event.is_echo():
		_advance()

func _advance() -> void:
	if _leaving:
		return
	_leaving = true
	GameState.reset_run()
	await ScreenTransition.close()
	get_tree().change_scene_to_file(HOME_SCENE)

func _on_back_button_pressed() -> void:
	if _leaving:
		return
	_leaving = true
	GameState.reset_run()
	await ScreenTransition.close()
	get_tree().change_scene_to_file(HOME_SCENE)
