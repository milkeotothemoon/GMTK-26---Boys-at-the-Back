extends CanvasLayer

@onready var rect: ColorRect = $Mask

func _ready() -> void:
	layer = 100
	rect.visible = false

func close(duration: float = 0.7) -> void:
	var mat := rect.material as ShaderMaterial
	mat.set_shader_parameter("radius", 2.0)
	rect.visible = true
	var t := create_tween()
	t.tween_method(
		func(v: float) -> void: mat.set_shader_parameter("radius", v),
		2.0, 0.0, duration)
	await t.finished

func open(duration: float = 0.7) -> void:
	var mat := rect.material as ShaderMaterial
	mat.set_shader_parameter("radius", 0.0)
	rect.visible = true
	var t := create_tween()
	t.tween_method(
		func(v: float) -> void: mat.set_shader_parameter("radius", v),
		0.0, 2.0, duration)
	await t.finished
	rect.visible = false
