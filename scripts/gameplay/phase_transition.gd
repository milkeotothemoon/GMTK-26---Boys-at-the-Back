extends CanvasLayer

signal transition_finished

@onready var label: Label = $Message

func _ready() -> void:
	visible = false

func play_build_to_run() -> void:
	visible = true
	await _show("TIME'S UP", 0.9)
	var grid := get_tree().get_first_node_in_group("build_space_view")
	if grid and grid.has_method("set_grid_visible"):
		grid.set_grid_visible(false)
	await _show("3", 0.5)
	await _show("2", 0.5)
	await _show("1", 0.5)
	await _show("GO!", 0.5)
	visible = false
	transition_finished.emit()

func _show(text: String, seconds: float) -> void:
	label.text = text
	await get_tree().create_timer(seconds).timeout
