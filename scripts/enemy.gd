extends Control
class_name Enemy


signal clicked(enemy: Enemy)
signal attacked_player(damage: int, power_loss: int)


@onready var hp_bar = %HitPointsBar
@onready var hp_label = %HitPointsLabel
@onready var description_label = %DescriptionLabel
@onready var description_panel = %DescriptionPanel
@onready var sprite = %Sprite2D
@onready var coords: Vector2i


@onready var blueprint: EnemyBlueprint:
	set(new_value):
		blueprint = new_value
		hp_bar.max_value = blueprint.hp_max
		hp_current = blueprint.hp_max
		sprite.texture = blueprint.texture


@onready var hp_current: int = 1:
	set(new_value):
		if new_value < hp_current:
			modulate = Color.RED
			Global.show_floating_text(
				global_position + Vector2(48., -32.),
				str(new_value - hp_current),
				Color.RED
			)
			await get_tree().create_timer(0.1).timeout
			modulate = Color.WHITE
		hp_current = clamp(new_value, 0, blueprint.hp_max)
		hp_bar.value = hp_current
		hp_label.text = "%s / %s" % [hp_current, blueprint.hp_max]
		if hp_current == 0:
			queue_free()


func _ready() -> void:
	add_to_group("enemy")


func _process(delta: float) -> void:
	# change position
	var target_position = EnemyHelper.get_grid_target_position(coords)
	var distance = global_position - target_position
	if distance.length_squared() <= 128**2:
		global_position = global_position.move_toward(
			target_position,
			delta * UserSettings.get_enemy_movement_speed()
		)
	else:
		global_position = target_position
	# change description
	var description: String = "%s\n" % tr(blueprint.name)
	if blueprint.damage > 0:
		description += "%s: %s" % [tr("DAMAGE"), blueprint.damage]
	if blueprint.power_loss > 0:
		description += "%s %s %s" % [
			tr("LOSE_POWER_PART_1"),
			blueprint.power_loss,
			tr("LOSE_POWER_PART_2")
		]
	description_label.text = description


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func attack() -> void:
	attacked_player.emit(blueprint.damage, blueprint.power_loss)
	hp_current = 0


func _on_mouse_entered():
	description_panel.visible = true


func _on_mouse_exited():
	description_panel.visible = false
