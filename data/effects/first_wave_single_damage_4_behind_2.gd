extends Effect


func apply(target: Enemy) -> void:
	if target.coords.x == 0:
		target.hp_current -= 4
		var enemy_behind = EnemyHelper.get_enemy_by_coords(target.coords + Vector2i.RIGHT)
		if is_instance_valid(enemy_behind) and not enemy_behind.is_queued_for_deletion():
			enemy_behind.hp_current -= 2


func is_target_valid(target: Enemy) -> bool:
	return target.coords.x == 0


func get_damaged_targets(target: Enemy) -> Array:
	var result = [target]
	var enemy_behind = EnemyHelper.get_enemy_by_coords(target.coords + Vector2i.RIGHT)
	if is_instance_valid(enemy_behind) and not enemy_behind.is_queued_for_deletion():
		result.append(enemy_behind)
	return result
