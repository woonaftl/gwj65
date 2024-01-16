extends Control
class_name Power


signal clicked(power: Power)


@onready var energy_label = %EnergyLabel
@onready var uses_label = %UsesLabel
@onready var description_label = %DescriptionLabel


@onready var blueprint: PowerBlueprint:
	set(new_value):
		blueprint = new_value
		energy_label.text = str(blueprint.energy)
		uses_left = blueprint.uses_max
		uses_label.text = "%s / %s" % [uses_left, blueprint.uses_max]


@onready var uses_left: int:
	set(new_value):
		uses_left = clamp(new_value, 0, blueprint.uses_max)
		uses_label.text = "%s / %s" % [uses_left, blueprint.uses_max]
		if uses_left == 0:
			remove_from_group("selected_power")


func _process(_delta: float) -> void:
	if Player.is_overloaded():
		description_label.text = blueprint.overload_description
		description_label.add_theme_color_override("default_color", Color.YELLOW)
	else:
		description_label.text = blueprint.description
		description_label.remove_theme_color_override("default_color")
	if is_in_group("selected_power"):
		modulate = Color.RED
	elif uses_left == 0:
		modulate = Color.DARK_GRAY
	else:
		modulate = Color.WHITE


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if uses_left > 0:
			clicked.emit(self)


func use(target: Enemy) -> void:
	if uses_left > 0:
		if Player.is_overloaded():
			blueprint.effect_overload.apply(target)
		else:
			blueprint.effect.apply(target)
		uses_left -= 1
