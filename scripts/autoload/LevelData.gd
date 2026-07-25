extends Node

const MAX_LEVEL_INDEX := 3

var active_config: Resource = null

func load_level(level_index: int) -> void:
	if level_index < 0 or level_index > MAX_LEVEL_INDEX:
		push_error("load_level(%d) out of range 0..%d" % [level_index, MAX_LEVEL_INDEX])
		active_config = null
		return
	var path := "res://resources/level_configs/level%d_config.tres" % level_index
	active_config = load(path)
	if active_config == null:
		push_error("Failed to load level config: %s" % path)
