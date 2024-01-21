extends Button
class_name NewPowerOption


signal clicked(power: Power)


@onready var new_power_container = %NewPowerContainer
@onready var power: Power


func _on_pressed():
	AudioBus.play("NewPower")
	clicked.emit(power)


func new_power(blueprint):
	power = preload("res://scenes/power.tscn").instantiate()
	new_power_container.add_child(power)
	power.add_to_group("new_power")
	power.blueprint = blueprint
	power.clicked.connect(get_tree().current_scene._on_power_clicked)
