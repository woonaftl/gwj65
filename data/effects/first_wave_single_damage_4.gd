extends Effect


func apply(target: Enemy) -> void:
	if target.coords.x == 0:
		target.hp_current -= 4


func is_target_valid(target: Enemy) -> bool:
	return target.coords.x == 0
