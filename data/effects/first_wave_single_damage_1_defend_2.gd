extends Effect


func apply(target: Enemy) -> void:
	target.hp_current -= 1
	Player.defend += 2


func is_target_valid(target: Enemy) -> bool:
	return target.coords.x == 0
