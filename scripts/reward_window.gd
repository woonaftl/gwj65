extends Window


signal closed


@onready var return_option = %ReturnOption
@onready var discard_scroll_container = %DiscardScrollContainer
@onready var cannot_return_label = %CannotReturnLabel


func _on_about_to_popup():
	discard_scroll_container.visible = Player.hp > 1
	return_option.disabled = Player.hp == 1
	cannot_return_label.visible = Player.hp == 1


func _on_return_option_pressed() -> void:
	if Player.hp > 1:
		Player.hp -= 1
		for power: Node in get_tree().get_nodes_in_group("unavailable_power"):
			power.remove_from_group("unavailable_power")
			power.add_to_group("available_power")
			power.uses_left = power.blueprint.uses_max
		for power: Node in get_tree().get_nodes_in_group("new_power"):
			power.queue_free()
		closed.emit()


func add_option(power: Power) -> void:
	Player.hp += 1
	power.remove_from_group("new_power")
	power.add_to_group("available_power")
	power.uses_left = power.blueprint.uses_max
	for new_power: Node in get_tree().get_nodes_in_group("new_power"):
		new_power.queue_free()
	closed.emit()


func _on_new_power_option_clicked(power: Power) -> void:
	add_option(power)


func _on_new_power_option_2_clicked(power: Power) -> void:
	add_option(power)


func _on_new_power_option_3_clicked(power: Power) -> void:
	add_option(power)
