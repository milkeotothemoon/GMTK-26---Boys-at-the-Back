extends Node
class_name ScoringSystem

static func calculate_stars(total_decibels: float, config: LevelConfig) -> int:
	if config == null:
		return 0
	if total_decibels >= config.star3_threshold_db:
		return 3
	if total_decibels >= config.star2_threshold_db:
		return 2
	if total_decibels >= config.star1_threshold_db:
		return 1
	return 0
