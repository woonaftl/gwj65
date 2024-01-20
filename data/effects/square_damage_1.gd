extends Effect


func apply(target: Enemy) -> void:
	for enemy in EnemyHelper.get_square_shape(target.coords):
		enemy.hp_current -= 1


func get_damaged_targets(target: Enemy) -> Array:
	return EnemyHelper.get_square_shape(target.coords)
