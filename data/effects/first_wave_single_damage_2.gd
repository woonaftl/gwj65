extends Effect


func apply(target: Enemy) -> void:
	if target.coords.x == 0:
		target.hp_current -= 2
