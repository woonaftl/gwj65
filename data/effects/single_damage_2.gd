extends Effect


func apply(target: Enemy) -> void:
	target.hp_current -= 2
