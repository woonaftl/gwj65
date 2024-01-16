extends Window


signal closed

@onready var choose_return_button = %ChooseReturnButton
@onready var choose_add_button = %ChooseAddButton


func _on_about_to_popup():
	choose_return_button.disabled = Player.hp <= 1


func _on_choose_return_button_pressed():
	Player.hp -= 1
	for power: Node in get_tree().get_nodes_in_group("unavailable_power"):
		power.remove_from_group("unavailable_power")
		power.add_to_group("available_power")
		power.uses_left = power.blueprint.uses_max
	for power: Node in get_tree().get_nodes_in_group("new_power"):
		power.queue_free()
	closed.emit(false)


func _on_choose_add_button_pressed():
	Player.hp += 1
	for power: Node in get_tree().get_nodes_in_group("new_power"):
		power.remove_from_group("new_power")
		power.add_to_group("available_power")
		power.uses_left = power.blueprint.uses_max
	closed.emit(true)
