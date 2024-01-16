extends Node


func get_all_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemy")


func get_enemy_by_coords(coords: Vector2i) -> Node:
	var valid_enemies = get_all_enemies().filter(
		func(x):
			return x.coords == coords
	)
	if len(valid_enemies) > 0:
		return valid_enemies.front()
	else:
		return null


func get_plus_shape(coords: Vector2i) -> Array:
	return get_all_enemies().filter(
		func(x):
			var distance = coords - x.coords
			return distance.length_squared() <= 1
	)


func get_square_shape(coords: Vector2i) -> Array:
	return get_all_enemies().filter(
		func(x):
			var distance = coords - x.coords
			return distance.length_squared() <= 2
	)
