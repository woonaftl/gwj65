extends Control


const ALL_POWER_BLUEPRINTS = [
	preload("res://data/powers/damage_first_row.tres"),
	preload("res://data/powers/damage_higher_farther.tres"),
	preload("res://data/powers/damage_multiple_enemies.tres"),
	preload("res://data/powers/damage_multiple_uses.tres"),
]


enum State {CHOOSE_POWERS, CHOOSE_TARGETS, ENEMY_TURN}


@onready var wave: int = 0


@onready var active_container = %ActiveContainer
@onready var available_container = %AvailableContainer
@onready var discard_container = %DiscardContainer
@onready var new_power_container = %NewPowerContainer
@onready var reward_window = %RewardWindow
@onready var col_0_row_0 = %Col0Row0
@onready var col_0_row_1 = %Col0Row1
@onready var col_0_row_2 = %Col0Row2
@onready var col_0_row_3 = %Col0Row3
@onready var col_1_row_0 = %Col1Row0
@onready var col_1_row_1 = %Col1Row1
@onready var col_1_row_2 = %Col1Row2
@onready var col_1_row_3 = %Col1Row3
@onready var col_2_row_0 = %Col2Row0
@onready var col_2_row_1 = %Col2Row1
@onready var col_2_row_2 = %Col2Row2
@onready var col_2_row_3 = %Col2Row3
@onready var col_3_row_0 = %Col3Row0
@onready var col_3_row_1 = %Col3Row1
@onready var col_3_row_2 = %Col3Row2
@onready var col_3_row_3 = %Col3Row3
@onready var overload_bar = %OverloadBar
@onready var overload_bar_label = %OverloadBarLabel
@onready var player_hp_label = %PlayerHpLabel
@onready var defend_label = %DefendLabel
@onready var quit_button = %QuitButton
@onready var end_turn_button = %EndTurnButton
@onready var overload_label = %OverloadLabel


@onready var grid: Dictionary = {
	Vector2i(0, 0): col_0_row_0,
	Vector2i(0, 1): col_0_row_1,
	Vector2i(0, 2): col_0_row_2,
	Vector2i(0, 3): col_0_row_3,
	Vector2i(1, 0): col_1_row_0,
	Vector2i(1, 1): col_1_row_1,
	Vector2i(1, 2): col_1_row_2,
	Vector2i(1, 3): col_1_row_3,
	Vector2i(2, 0): col_2_row_0,
	Vector2i(2, 1): col_2_row_1,
	Vector2i(2, 2): col_2_row_2,
	Vector2i(2, 3): col_2_row_3,
	Vector2i(3, 0): col_3_row_0,
	Vector2i(3, 1): col_3_row_1,
	Vector2i(3, 2): col_3_row_2,
	Vector2i(3, 3): col_3_row_3,
}


@onready var state: State = State.CHOOSE_POWERS:
	set(new_value):
		state = new_value
		end_turn_button.disabled = state == State.ENEMY_TURN
		match state:
			State.CHOOSE_POWERS:
				end_turn_button.text = "ACTIVATE"
			State.CHOOSE_TARGETS:
				end_turn_button.text = "END TURN"
			State.ENEMY_TURN:
				end_turn_button.text = "ENEMY TURN"


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)
	quit_button.visible = not OS.has_feature("web")
	Player.defend = 0
	Player.hp = 3
	for x in range(3):
		add_power("available_power")
	for x in range(0, 4):
		spawn_wave(x)


func add_power(group: String) -> void:
	if len(ALL_POWER_BLUEPRINTS) > 0:
		var power: Power = preload("res://power.tscn").instantiate()
		new_power_container.add_child(power)
		power.add_to_group(group)
		power.clicked.connect(_on_power_clicked)
		power.blueprint = ALL_POWER_BLUEPRINTS.pick_random()


func _process(_delta: float) -> void:
	defend_label.text = str(Player.defend)
	player_hp_label.text = str(Player.hp)
	if Player.hp == 0:
		game_over()
	overload_bar.max_value = Player.hp
	var active_energy = Player.get_active_energy()
	overload_bar.value = active_energy
	overload_bar_label.text = "%s / %s" % [active_energy, Player.hp]
	overload_label.modulate.a = (1. + active_energy) / (1. + Player.hp)
	if Player.is_overloaded():
		overload_label.add_theme_constant_override("outline_size", 5)
	else:
		overload_label.remove_theme_constant_override("outline_size")
	for power in get_tree().get_nodes_in_group("available_power"):
		if not power.get_parent() == available_container:
			power.reparent(available_container, false)
	for power in get_tree().get_nodes_in_group("active_power"):
		if not power.get_parent() == active_container:
			power.reparent(active_container, false)
	for power in get_tree().get_nodes_in_group("unavailable_power"):
		if not power.get_parent() == discard_container:
			power.reparent(discard_container, false)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy.get_parent() == grid[enemy.coords]:
			enemy.reparent(grid[enemy.coords])


func deselect_all() -> void:
	for power in get_tree().get_nodes_in_group("selected_power"):
		power.remove_from_group("selected_power")


func enemy_turn() -> void:
	for y in range(4):
		var children: Array = grid[Vector2i(0, y)].get_children()
		if len(children) > 0:
			var enemy: Node = children.front()
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy is Enemy:
				enemy.attack()
				await get_tree().create_timer(0.25).timeout
	await get_tree().create_timer(0.5).timeout
	for x in range(1, 4):
		for y in range(4):
			var children: Array = grid[Vector2i(x, y)].get_children()
			if len(children) > 0:
				var enemy: Node = children.front()
				if is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy is Enemy:
					enemy.coords += Vector2i.LEFT
		await get_tree().create_timer(0.5).timeout
	spawn_wave(3)
	await get_tree().create_timer(0.5).timeout
	discard_used_powers()
	add_power("new_power")
	reward_window.popup_centered()
	await reward_window.closed
	reward_window.hide()
	state = State.CHOOSE_POWERS


func discard_used_powers() -> void:
	for power: Node in get_tree().get_nodes_in_group("active_power"):
		power.remove_from_group("active_power")
		power.add_to_group("unavailable_power")
		power.uses_left = power.blueprint.uses_max


func spawn_wave(x: int) -> void:
	for y in range(4):
		spawn_enemy(Vector2i(x, y))
	wave += 1


func spawn_enemy(coords: Vector2i) -> void:
	if randf() > 1. / 3.:
		var enemy: Enemy = preload("res://enemy.tscn").instantiate()
		grid[Vector2i(coords)].add_child(enemy)
		enemy.coords = coords
		enemy.clicked.connect(_on_enemy_clicked)
		enemy.attacked_player.connect(_on_enemy_attacked_player)
		if randf() > 2. / 3.:
			enemy.blueprint = preload("res://data/enemies/basic.tres")
		elif randf() > 1. / 3.:
			enemy.blueprint = preload("res://data/enemies/armored.tres")
		else:
			enemy.blueprint = preload("res://data/enemies/thief.tres")


func game_over() -> void:
	get_tree().quit()


func _on_power_clicked(power: Power) -> void:
	if state == State.CHOOSE_POWERS and power.is_in_group("available_power"):
		power.remove_from_group("available_power")
		power.add_to_group("active_power")
	elif state == State.CHOOSE_POWERS and power.is_in_group("active_power"):
		power.remove_from_group("active_power")
		power.add_to_group("available_power")
	elif state == State.CHOOSE_TARGETS and power.get_parent() == active_container:
		deselect_all()
		power.add_to_group("selected_power")


func _on_enemy_clicked(enemy: Enemy) -> void:
	var selected_power = get_tree().get_first_node_in_group("selected_power")
	if is_instance_valid(selected_power) and not selected_power.is_queued_for_deletion():
		selected_power.use(enemy)


func _on_enemy_attacked_player(damage: int, power_loss: int) -> void:
	var damage_done = clamp(damage - Player.defend, 0, 9999)
	Player.hp -= damage_done
	Player.defend -= damage - damage_done
	for lost_power in range(power_loss):
		lose_power()


func lose_power() -> void:
	var all_powers: Array = []
	all_powers.append_array(get_tree().get_nodes_in_group("unavailable_power").filter(
		func(x):
			return not x.is_queued_for_deletion()
	))
	all_powers.append_array(get_tree().get_nodes_in_group("available_power").filter(
		func(x):
			return not x.is_queued_for_deletion()
	))
	all_powers.append_array(get_tree().get_nodes_in_group("active_power").filter(
		func(x):
			return not x.is_queued_for_deletion()
	))
	if len(all_powers) > 0:
		var lost_power = all_powers.pick_random()
		lost_power.queue_free()


func _on_end_turn_button_pressed() -> void:
	deselect_all()
	match state:
		State.CHOOSE_POWERS:
			state = State.CHOOSE_TARGETS
		State.CHOOSE_TARGETS:
			state = State.ENEMY_TURN
			enemy_turn()


func _on_settings_button_pressed() -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()
