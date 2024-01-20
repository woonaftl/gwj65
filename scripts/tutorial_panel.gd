extends Panel


signal closed


@onready var label = %Label


@onready var text: String:
	set(new_value):
		text = new_value
		label.text = text


func close():
	visible = false
	closed.emit()
