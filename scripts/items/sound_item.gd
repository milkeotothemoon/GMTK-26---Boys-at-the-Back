extends BaseItem
class_name SoundItem

@export var decibel_value: float = 10.0
signal sound_finished

func trigger() -> void:
	var p: AudioStreamPlayer2D = $AudioStreamPlayer2D
	if p.stream == null:
		await get_tree().create_timer(0.4).timeout
		sound_finished.emit()
		return
	p.play()
	await p.finished
	sound_finished.emit()
