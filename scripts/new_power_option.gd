extends PanelContainer
class_name NewPowerOption


signal clicked(power: Power)


@onready var new_power_container = %NewPowerContainer


@onready var power: Power:
	set(new_value):
		power = new_value
		new_power_container.add_child(power)


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(power)
