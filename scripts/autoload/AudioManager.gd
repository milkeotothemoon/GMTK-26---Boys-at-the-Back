extends Node
var decibel_total: float = 0.0
var combo_multiplier: float = 1.0

func add_decibels(amount: float) -> void:
	decibel_total += amount * combo_multiplier

func reset() -> void:
	decibel_total = 0.0
	combo_multiplier = 1.0
