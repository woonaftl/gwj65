extends Effect


func apply(target: Enemy) -> void:
	for enemy in EnemyHelper.get_square_shape(target.coords):
		enemy.hp_current -= 1
