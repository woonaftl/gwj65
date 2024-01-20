extends Node


const ENEMY_MOVEMENT_SPEED_BASE: float = 350.
const TIME_BETWEEN_ATTACKS_BASE: float = 0.4
const TIME_BETWEEN_WAVES_BASE: float = 0.8


var game_speed: float = 1.0
var language_chosen = false
var is_victory: bool = false


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)
	set_master_volume(-10)


func set_master_volume(new_value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_value)


func window_set_mode(new_value: DisplayServer.WindowMode) -> void:
	DisplayServer.window_set_mode(new_value)


func set_locale(new_value: String) -> void:
	TranslationServer.set_locale(new_value)


func get_enemy_movement_speed() -> float:
	return ENEMY_MOVEMENT_SPEED_BASE * game_speed


func get_time_between_attacks() -> float:
	return TIME_BETWEEN_ATTACKS_BASE / game_speed


func get_time_between_waves() -> float:
	return TIME_BETWEEN_WAVES_BASE / game_speed
