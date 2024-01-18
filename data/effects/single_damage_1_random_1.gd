extends Effect


func apply(target: Enemy) -> void:
	target.hp_current -= 1
	var eligible_enemies = EnemyHelper.get_all_enemies_except_one(target)
	if len(eligible_enemies) > 0:
		eligible_enemies.pick_random().hp_current -= 1
