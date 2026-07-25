extends Control

@export var bar_width: float = 60.0

var _current: float = 0.0
var _max: float = 100.0
var _t1: float = 0.0
var _t2: float = 0.0
var _t3: float = 0.0

func _ready() -> void:
	add_to_group("score_bar")
	AudioManager.decibels_changed.connect(_on_changed)
	var cfg: LevelConfig = LevelData.active_config
	if cfg:
		_t1 = cfg.star1_threshold_db
		_t2 = cfg.star2_threshold_db
		_t3 = cfg.star3_threshold_db
		_max = cfg.star3_threshold_db * 1.15
	queue_redraw()

func _on_changed(total: float) -> void:
	_current = total
	queue_redraw()

func _draw() -> void:
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, Vector2(bar_width, h)), Color(0, 0, 0, 0.35), true)
	var pct: float = clampf(_current / _max, 0.0, 1.0)
	var fill_h := h * pct
	draw_rect(Rect2(Vector2(0, h - fill_h), Vector2(bar_width, fill_h)), Color(0.95, 0.75, 0.2), true)
	for t in [_t1, _t2, _t3]:
		if t <= 0.0:
			continue
		var y := h - h * clampf(t / _max, 0.0, 1.0)
		draw_line(Vector2(-6, y), Vector2(bar_width + 6, y), Color.WHITE, 3)
	draw_rect(Rect2(Vector2.ZERO, Vector2(bar_width, h)), Color.BLACK, false, 2)
