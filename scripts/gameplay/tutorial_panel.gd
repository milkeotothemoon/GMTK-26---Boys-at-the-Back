extends CanvasLayer

signal tutorial_finished

@onready var body: Label = $Panel/Body
@onready var next_button: Button = $Panel/NextButton

var _step: int = 0

const STEPS := [
	"Looks like this kid is still deep asleep!",
	"Drag items from the tray onto the grid, quick!\nYou have 60 seconds to build.",
	"Simply click an item and put it onto the alarm.",
	"Drop an item outside the grid to throw it away.",
	"When the timer runs out, the alarm rings and gravity takes over!\nAnything that falls makes some noise.",
    "Louder is better. Fill the bar on the right\nto earn stars. Wakey wakey!!"
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
