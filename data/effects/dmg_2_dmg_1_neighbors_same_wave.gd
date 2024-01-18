extends Effect


func apply(target: Enemy) -> void:
	target.hp_current -= 2
	for enemy in EnemyHelper.get_all_enemies_except_one(target).filter(
		func(e):
			var distance: Vector2i = e.coords.y - target.y
			return distance.length_squared() == 1 and e.coords.x == target.x
	):
		enemy.hp_current -= 1