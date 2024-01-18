extends HSlider


var preview: bool = false


func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	preview = true


func _on_value_changed(_value: float) -> void:
	var db: float = linear_to_db(value)
	if preview and AudioBus.get_node("Click").get_playback_position() == 0:
		AudioBus.play("Click")
	UserSettings.set_master_volume(db)
