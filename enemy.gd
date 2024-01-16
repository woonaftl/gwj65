extends Control
class_name Enemy


signal clicked(enemy: Enemy)
signal attacked_player(damage: int, power_loss: int)


@onready var hp_bar = %HitPointsBar
@onready var hp_label = %HitPointsLabel
@onready var coords: Vector2i


@onready var blueprint: EnemyBlueprint:
	set(new_value):
		blueprint = new_value
		hp_bar.max_value = blueprint.hp_max
		hp_current = blueprint.hp_max


@onready var hp_current: int = 1:
	set(new_value):
		hp_current = clamp(new_value, 0, blueprint.hp_max)
		hp_bar.value = hp_current
		hp_label.text = "%s / %s" % [hp_current, blueprint.hp_max]
		if hp_current == 0:
			queue_free()


func _ready() -> void:
	add_to_group("enemy")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func attack() -> void:
	attacked_player.emit(blueprint.damage, blueprint.power_loss)
	hp_current = 0
