extends Node


var enemy_grid_origin: Vector2
var enemy_grid_cell_size: Vector2


func get_grid_target_position(coords: Vector2i) -> Vector2:
	return enemy_grid_origin + Vector2(coords) * enemy_grid_cell_size


func get_all_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemy")


func get_all_enemies_except_one(exception: Node) -> Array:
	return get_all_enemies().filter(
		func(enemy):
			return enemy != exception
	)


func get_enemies_in_wave(x: int) -> Array:
	return get_all_enemies().filter(
		func(enemy):
			return enemy.coords.x == x
	)


func get_enemies_in_front_of(target_coords: Vector2i) -> Array:
	return get_all_enemies().filter(
		func(enemy):
			return enemy.coords.x < target_coords.x and enemy.coords.y == target_coords.y
	)


func get_enemy_by_coords(coords: Vector2i) -> Node:
	var valid_enemies = get_all_enemies().filter(
		func(enemy):
			return enemy.coords == coords
	)
	if len(valid_enemies) > 0:
		return valid_enemies.front()
	else:
		return null


func get_plus_shape(coords: Vector2i) -> Array:
	return get_all_enemies().filter(
		func(enemy):
			var distance = coords - enemy.coords
			return distance.length_squared() <= 1
	)


func get_square_shape(coords: Vector2i) -> Array:
	return get_all_enemies().filter(
		func(enemy):
			var distance = coords - enemy.coords
			return distance.length_squared() <= 2
	)
