extends HSlider


func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))


func _on_value_changed(_value: float) -> void:
	var db: float = linear_to_db(value)
	UserSettings.set_master_volume(db)
