extends SoundItem

func activate(source: Node = null) -> void:
	if GameState.current_phase != GameState.Phase.RUN:
		return
	super.activate(source)
	_drop()

func _drop() -> void:
	is_dynamic = true
	freeze = false
