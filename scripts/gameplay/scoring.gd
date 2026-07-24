extends Node
class_name ScoringSystem

static func calculate_stars(total_decibels: float, config: LevelConfig) -> int:
	if config == null or total_decibels < config.star1_threshold_db:
		return 0
	if total_decibels >= config.star3_threshold_db:
		return 3
	var midpoint := (config.star1_threshold_db + config.star3_threshold_db) / 2.0
	return 2 if total_decibels >= midpoint else 1
