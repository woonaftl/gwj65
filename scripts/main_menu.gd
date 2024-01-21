extends Control

@onready var start_button: Button = %StartButton as Button
@onready var settings_button: Button = %SettingsButton as Button
@onready var english_button: Button = %EnglishButton as Button
@onready var russian_button: Button = %RussianButton as Button
@onready var credits_button: Button = %CreditsButton as Button
@onready var quit_button: Button = %QuitButton as Button


func _ready() -> void:
	quit_button.visible = not OS.has_feature("web")


func _process(_delta: float) -> void:
	start_button.visible = UserSettings.language_chosen
	settings_button.visible = UserSettings.language_chosen
	credits_button.visible = UserSettings.language_chosen
	english_button.visible = not UserSettings.language_chosen
	russian_button.visible = not UserSettings.language_chosen
	quit_button.visible = UserSettings.language_chosen
	var locale: String = TranslationServer.get_locale().substr(0, 2)
	english_button.disabled = UserSettings.language_chosen and locale == "en"
	russian_button.disabled = UserSettings.language_chosen and locale == "ru"


func _on_start_button_pressed() -> void:
	AudioBus.play("Click")
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_credits_button_pressed() -> void:
	AudioBus.play("Click")
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_settings_button_pressed() -> void:
	AudioBus.play("Click")
	var settings: Window = preload("res://scenes/settings.tscn").instantiate()
	add_child(settings)
	settings.popup_centered()


func _on_quit_button_pressed() -> void:
	if not OS.has_feature("web"):
		get_tree().quit()


func _on_english_button_pressed():
	AudioBus.play("Click")
	UserSettings.language_chosen = true
	UserSettings.set_locale("en")


func _on_russian_button_pressed():
	AudioBus.play("Click")
	UserSettings.language_chosen = true
	UserSettings.set_locale("ru")
