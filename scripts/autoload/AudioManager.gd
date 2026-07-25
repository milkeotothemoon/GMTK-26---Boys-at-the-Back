extends Node

signal decibels_changed(new_total: float)
signal sound_fired(source_name: String, amount: float)

var decibel_total: float = 0.0
var combo_multiplier: float = 1.0

func add_decibels(amount: float) -> void:
	decibel_total += amount * combo_multiplier
	decibels_changed.emit(decibel_total)

func report_sound(source_name: String, amount: float) -> void:
	add_decibels(amount)
	sound_fired.emit(source_name, amount)

func reset() -> void:
	decibel_total = 0.0
	combo_multiplier = 1.0
	decibels_changed.emit(0.0)
