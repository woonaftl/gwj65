extends Effect


func apply(target: Enemy) -> void:
	target.coords += Vector2i.LEFT
	for enemy in EnemyHelper.get_enemies_in_wave(0):
		Player.defend += 1


func is_target_valid(target: Enemy) -> bool:
	return target.coords.x > 0 and len(EnemyHelper.get_enemies_in_front_of(target.coords)) == 0
