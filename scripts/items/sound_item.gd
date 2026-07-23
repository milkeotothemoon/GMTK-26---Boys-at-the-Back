extends BaseItem
class_name SoundItem

@export var decibel_value: float = 10.0
signal sound_finished

func trigger() -> void:
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	sound_finished.emit()
