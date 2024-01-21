extends Panel
class_name Power


signal clicked(power: Power)


@onready var energy_label = %EnergyLabel
@onready var uses_label = %UsesLabel
@onready var name_label = %NameLabel
@onready var sprite = %Sprite2D


@onready var blueprint: PowerBlueprint:
	set(new_value):
		blueprint = new_value
		uses_left = blueprint.uses_max
		sprite.texture = blueprint.texture
		var sprite_scale = 220 / blueprint.texture.get_size().x
		sprite.scale = Vector2(sprite_scale, sprite_scale)
		custom_minimum_size.y = blueprint.texture.get_size().y * sprite_scale + 20


@onready var uses_left: int:
	set(new_value):
		uses_left = clamp(new_value, 0, blueprint.uses_max)
		if uses_left == 0:
			remove_from_group("selected_power")


func _process(_delta: float) -> void:
	tooltip_text = "%s\n\n%s:\n%s" % [
		tr(blueprint.description),
		tr("OVERLOAD_IN_POWER_TOOLTIP"),
		tr(blueprint.overload_description)
	]
	energy_label.text = "%s: %s" % [tr("ENERGY"), str(blueprint.energy)]
	uses_label.text = "%s: %s / %s" % [tr("USES"), uses_left, blueprint.uses_max]
	name_label.text = tr(blueprint.name)
	if is_in_group("selected_power"):
		modulate = Color.CYAN
	elif uses_left == 0 or is_in_group("available_power") and get_tree().current_scene.state != Game.State.CHOOSE_POWERS:
		modulate = Color.WEB_GRAY
	else:
		modulate = Color.WHITE
	if is_in_group("new_power") or is_in_group("unavailable_power"):
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_in_group("available_power") or (is_in_group("active_power") and uses_left > 0):
			clicked.emit(self)


func use(target: Enemy) -> void:
	if uses_left > 0:
		if Player.is_overloaded():
			if blueprint.effect_overload.is_target_valid(target):
				blueprint.effect_overload.apply(target)
				uses_left -= 1
		else:
			if blueprint.effect.is_target_valid(target):
				blueprint.effect.apply(target)
				uses_left -= 1
