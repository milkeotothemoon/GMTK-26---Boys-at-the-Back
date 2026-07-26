extends CanvasLayer

signal tutorial_finished

@onready var body: Label = $Panel/Body
@onready var next_button: Button = $Panel/NextButton

var _step: int = 0

const STEPS := [
	"Someone's asleep downstairs.\nYour job is to wake them up.",
	"Drag items from the tray onto the grid.\nYou have 60 seconds to build.",
	"Press R to rotate an item while you're holding it,\nand F to flip it. Some items only work facing the right way.",
	"Drop an item outside the grid to throw it away.\nRight-click a placed item to delete it.",
	"When the timer runs out, physics takes over.\nThe marble falls — everything it hits makes noise.",
	"Louder is better. Fill the bar on the right\nto earn stars. Good luck."
]

func _ready() -> void:
	visible = false
	next_button.pressed.connect(_advance)

func start() -> void:
	_step = 0
	body.text = STEPS[0]
	next_button.text = "Next"
	visible = true

func _advance() -> void:
	_step += 1
	if _step >= STEPS.size():
		visible = false
		tutorial_finished.emit()
		return
	body.text = STEPS[_step]
	if _step == STEPS.size() - 1:
		next_button.text = "Let's go"
