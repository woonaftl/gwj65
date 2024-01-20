extends Button
class_name NewPowerOption


signal clicked(power: Power)


@onready var new_power_container = %NewPowerContainer


@onready var power: Power:
	set(new_value):
		power = new_value
		new_power_container.add_child(power)


func _on_pressed():
	clicked.emit(power)
