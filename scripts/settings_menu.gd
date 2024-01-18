extends Window


@onready var display_mode_button: OptionButton = %DisplayModeButton as OptionButton
@onready var display_option_container: HBoxContainer = %DisplayOptionContainer as HBoxContainer
@onready var language_button: OptionButton = %LanguageButton as OptionButton
@onready var speed_slider: HSlider = %SpeedSlider as HSlider


func _ready() -> void:
	display_option_container.visible = not OS.has_feature("web")
	speed_slider.value = UserSettings.game_speed
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			display_mode_button.select(1)
		_:
			display_mode_button.select(0)
	match TranslationServer.get_locale().substr(0, 2):
		"ru":
			language_button.select(1)
		_:
			language_button.select(0)


func _process(_delta: float) -> void:
	move_to_center()


func _on_back_button_pressed() -> void:
	AudioBus.play("Click")
	queue_free()


func _on_display_mode_button_item_selected(index: int) -> void:
	match index:
		0:
			UserSettings.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			UserSettings.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_language_button_item_selected(index: int) -> void:
	match index:
		0:
			UserSettings.set_locale("en")
		1:
			UserSettings.set_locale("ru")


func _on_speed_slider_value_changed(value: float) -> void:
	UserSettings.game_speed = value
