extends Control

@export var bar_width: float = 60.0
@export var draw_outline: bool = false   # the art already frames it

var _current: float = 0.0
var _max: float = 100.0
var _t1: float = 0.0
var _t2: float = 0.0
var _t3: float = 0.0

func _ready() -> void:
	add_to_group("score_bar")
	AudioManager.decibels_changed.connect(_on_changed)
	_load_thresholds()
	queue_redraw()

func _load_thresholds() -> void:
	# Children _ready() before parents, so build_phase.gd hasn't loaded the
	# config yet. Load it here too or the ticks never draw under F6.
	if LevelData.active_config == null:
		LevelData.load_level(GameState.current_level_index)
	var cfg: LevelConfig = LevelData.active_config
	if cfg == null:
		return
	_t1 = cfg.star1_threshold_db
	_t2 = cfg.star2_threshold_db
	_t3 = cfg.star3_threshold_db
	_max = maxf(cfg.star3_threshold_db * 1.15, 1.0)   # guard /0

func _on_changed(total: float) -> void:
	_current = total
	queue_redraw()

func _draw() -> void:
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, Vector2(bar_width, h)), Color(0, 0, 0, 0.35), true)

	var pct: float = clampf(_current / _max, 0.0, 1.0)
	var fill_h := h * pct
	draw_rect(Rect2(Vector2(0, h - fill_h), Vector2(bar_width, fill_h)), _fill_color(), true)

	for t in [_t1, _t2, _t3]:
		if t <= 0.0:
			continue
		var y := h - h * clampf(t / _max, 0.0, 1.0)
		draw_line(Vector2(-6, y), Vector2(bar_width + 6, y), Color.WHITE, 3)

	if draw_outline:
		draw_rect(Rect2(Vector2.ZERO, Vector2(bar_width, h)), Color.BLACK, false, 2)

## Fill colour tracks the star tier you've currently earned.
func _fill_color() -> Color:
	if _t3 > 0.0 and _current >= _t3:
		return Color(0.45, 0.9, 0.4)
	if _t2 > 0.0 and _current >= _t2:
		return Color(0.95, 0.75, 0.2)
	if _t1 > 0.0 and _current >= _t1:
		return Color(0.95, 0.55, 0.2)
	return Color(0.8, 0.35, 0.3)
