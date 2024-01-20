extends Effect


func apply(target: Enemy) -> void:
	target.hp_current -= 2
	for enemy in EnemyHelper.get_all_enemies_except_one(target).filter(
		func(e):
			var distance: Vector2i = e.coords - target
			return distance.length_squared() == 1 and e.coords.x == target.x
	):
		enemy.hp_current -= 1


func get_damaged_targets(target: Enemy) -> Array:
	var result = [target]
	for enemy in EnemyHelper.get_all_enemies_except_one(target).filter(
		func(e):
			var distance: Vector2i = e.coords - target.coords
			return distance.length_squared() == 1 and e.coords.x == target.coords.x
	):
		result.append(enemy)
	return result
