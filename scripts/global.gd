extends Node


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)


func show_floating_text(global_pos: Vector2, text: String, color: Color, move_up: bool = true) -> void:
	var new_floating_text = preload("res://scenes/floating_hint.tscn").instantiate()
	get_tree().current_scene.add_child(new_floating_text)
	new_floating_text.global_position = global_pos
	new_floating_text.text = text
	new_floating_text.add_theme_color_override("font_color", color)
	if move_up:
		new_floating_text.vec = Vector2(0, -0.75)
