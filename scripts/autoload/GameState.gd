extends Node

enum Phase { BUILD, TRANSITION, RUN, SCORE }

signal phase_changed(new_phase: Phase)

var is_build_locked: bool = false
var has_played_tutorial: bool = false
var current_level_index: int = 0
var star_results: Dictionary = {}

var current_phase: Phase = Phase.BUILD

func set_phase(p: Phase) -> void:
	current_phase = p
	is_build_locked = p != Phase.BUILD
	phase_changed.emit(p)
