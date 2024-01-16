extends Effect


func apply(target: Enemy) -> void:
	target.hp_current -= target.coords.x + 1
