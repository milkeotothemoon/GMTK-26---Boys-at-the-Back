extends Node
var active_config: Resource = null

func load_level(level_index: int) -> void:
	active_config = load("res://resources/level_configs/level%d_config.tres" % level_index)
