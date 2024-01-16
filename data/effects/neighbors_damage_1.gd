extends Effect


func apply(target: Enemy) -> void:
	for enemy in EnemyHelper.get_plus_shape(target.coords):
		enemy.hp_current -= 1
