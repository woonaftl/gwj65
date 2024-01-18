extends Node


var defend: int:
	set(new_value):
		defend = clamp(new_value, 0, 9999)


var hp: int:
	set(new_value):
		hp = clamp(new_value, 0, 9999)


func get_active_energy() -> int:
	var result: int = 0
	for power in get_tree().get_nodes_in_group("active_power"):
		result += power.blueprint.energy
	return result


func is_overloaded() -> bool:
	return get_active_energy() >= hp
