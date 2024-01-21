extends Sprite2D


func _process(delta):
	var scale_wrong = Vector2(get_window().size) / texture.get_size()
	var mm = max(scale_wrong.x, scale_wrong.y)
	scale = Vector2(mm, mm)
