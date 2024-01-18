extends Effect


func apply(target: Enemy) -> void:
	var victim = EnemyHelper.get_enemy_by_coords(target.coords + Vector2i.RIGHT)
	victim.hp_current -= target.blueprint.damage


func is_target_valid(target: Enemy) -> bool:
	var victim = EnemyHelper.get_enemy_by_coords(target.coords + Vector2i.RIGHT)
	return target.blueprint.damage > 0 and is_instance_valid(victim)
