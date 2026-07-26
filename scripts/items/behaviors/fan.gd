extends UtilItem

## Sweep order. Ping-pong across three poses, endpoints not duplicated.
const SWEEP: Array[Vector2] = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.UP]

@export var seconds_per_step: float = 0.6

var _step: int = 0
var _step_time: float = 0.0

func _ready() -> void:
	super._ready()
	direction = SWEEP[0]

func _physics_process(delta: float) -> void:
	if _powered and GameState.current_phase == GameState.Phase.RUN:
		_step_time += delta
		if _step_time >= seconds_per_step:
			_step_time = 0.0
			_step = (_step + 1) % SWEEP.size()
			direction = SWEEP[_step]
	super._physics_process(delta)
