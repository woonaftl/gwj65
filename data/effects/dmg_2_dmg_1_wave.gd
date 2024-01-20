extends Effect


func apply(target: Enemy) -> void:
	target.hp_current -= 2
	for enemy in EnemyHelper.get_all_enemies_except_one(target).filter(
		func(e):
			return e.coords.x == target.x
	):
		enemy.hp_current -= 1


func get_damaged_targets(target: Enemy) -> Array:
	var result = [target]
	for enemy in EnemyHelper.get_all_enemies_except_one(target).filter(
		func(e):
			return e.coords.x == target.x
	):
		result.append(enemy)
	return result
