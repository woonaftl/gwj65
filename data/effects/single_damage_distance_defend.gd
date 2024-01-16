extends Effect


func apply(target: Enemy) -> void:
	var damage_dealt: int = clamp(target.coords.x + 1, 0, target.hp_current)
	target.hp_current -= damage_dealt
	Player.defend += damage_dealt
