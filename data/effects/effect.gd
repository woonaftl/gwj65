extends Resource
class_name Effect


func apply(_target: Enemy) -> void:
	pass


func is_target_valid(_target: Enemy) -> bool:
	return true


func get_damaged_targets(target: Enemy) -> Array:
	return [target]
