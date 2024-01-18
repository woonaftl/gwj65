extends Control


const WAVE_COUNT = 19
const ALL_POWER_BLUEPRINTS = [
	preload("res://data/powers/damage_first_row.tres"),
	preload("res://data/powers/damage_first_row_defend.tres"),
	preload("res://data/powers/damage_higher_farther.tres"),
	preload("res://data/powers/damage_multiple_enemies.tres"),
	preload("res://data/powers/damage_multiple_uses.tres"),
	preload("res://data/powers/mind_control.tres"),
	preload("res://data/powers/pull_and_defend.tres"),
]


enum State {CHOOSE_POWERS, CHOOSE_TARGETS, CHOOSE_NEW_CARD, ENEMY_TURN, ENDED}


@onready var enemy_points: int = 6
@onready var active_container = %ActiveContainer
@onready var available_container = %AvailableContainer
@onready var discard_container = %DiscardContainer
@onready var reward_window = %RewardWindow
@onready var new_power_option_1 = %NewPowerOption
@onready var new_power_option_2 = %NewPowerOption2
@onready var new_power_option_3 = %NewPowerOption3
@onready var overload_bar = %OverloadBar
@onready var overload_bar_label = %OverloadBarLabel
@onready var player_hp_label = %PlayerHpLabel
@onready var defend_label = %DefendLabel
@onready var settings_button = %SettingsButton
@onready var quit_button = %QuitButton
@onready var end_turn_button = %EndTurnButton
@onready var overload_label = %OverloadLabel
@onready var waves_label = %WavesLabel
@onready var player_sprite = %PlayerSprite
@onready var enemy_grid_origin = %EnemyGridOrigin


@onready var wave: int = 0:
	set(new_value):
		wave = new_value
		waves_label.text = "%s: %s" % [tr("WAVES LEFT"), clamp(WAVE_COUNT - wave, 0, 999)]


@onready var state: State = State.CHOOSE_POWERS:
	set(new_value):
		state = new_value
		end_turn_button.disabled = state == State.ENEMY_TURN
		settings_button.disabled = state == State.ENEMY_TURN
		match state:
			State.CHOOSE_POWERS:
				end_turn_button.text = tr("ACTIVATE")
			State.CHOOSE_TARGETS:
				end_turn_button.text = tr("END TURN")
			State.ENEMY_TURN:
				end_turn_button.text = tr("ENEMY TURN")
			State.CHOOSE_NEW_CARD:
				end_turn_button.text = tr("CHOOSE REWARD")


func _ready() -> void:
	Player.defend = 0
	Player.hp = 3
	add_starting_power(preload("res://data/powers/damage_multiple_uses.tres"))
	add_starting_power(preload("res://data/powers/damage_first_row_defend.tres"))
	add_starting_power(preload("res://data/powers/damage_multiple_enemies.tres"))
	for x in range(0, 4):
		spawn_wave(x)


func _process(_delta: float) -> void:
	EnemyHelper.enemy_grid_origin = enemy_grid_origin.global_position
	defend_label.text = str(Player.defend)
	player_hp_label.text = str(Player.hp)
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


func add_starting_power(blueprint: PowerBlueprint) -> void:
	var power: Power = preload("res://scenes/power.tscn").instantiate()
	available_container.add_child(power)
	power.add_to_group("available_power")
	power.clicked.connect(_on_power_clicked)
	power.blueprint = blueprint


func add_new_power(new_power_option: NewPowerOption, blueprint: PowerBlueprint) -> void:
	var power: Power = preload("res://scenes/power.tscn").instantiate()
	new_power_option.power = power
	power.add_to_group("new_power")
	power.clicked.connect(_on_power_clicked)
	power.blueprint = blueprint


func deselect_all() -> void:
	for power in get_tree().get_nodes_in_group("selected_power"):
		power.remove_from_group("selected_power")


func enemy_turn() -> void:
	for y in range(4):
		var enemy: Node = EnemyHelper.get_enemy_by_coords(Vector2i(0, y))
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			enemy.attack()
			if state == State.ENEMY_TURN:
				await get_tree().create_timer(UserSettings.get_time_between_attacks()).timeout
	if state == State.ENEMY_TURN:
		await get_tree().create_timer(UserSettings.get_time_between_waves()).timeout
		for x in range(1, 4):
			for y in range(4):
				var enemy: Node = EnemyHelper.get_enemy_by_coords(Vector2i(x, y))
				if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
					enemy.coords += Vector2i.LEFT
			await get_tree().create_timer(UserSettings.get_time_between_waves()).timeout
		spawn_wave(3)
		await get_tree().create_timer(UserSettings.get_time_between_waves()).timeout
		if not await check_win():
			Player.defend = 0
			discard_used_powers()
			prepare_power_options()
			reward_window.popup_on_parent(get_rect())
			state = State.CHOOSE_NEW_CARD


func _on_hide_button_pressed():
	reward_window.hide()


func _on_reward_window_closed():
	reward_window.hide()
	state = State.CHOOSE_POWERS


func prepare_power_options() -> void:
	var power_pool: Array = ALL_POWER_BLUEPRINTS.duplicate()
	if len(power_pool) > 0:
		var option = power_pool.pick_random()
		add_new_power(new_power_option_1, option)
		power_pool.erase(option)
	if len(power_pool) > 0:
		var option = power_pool.pick_random()
		add_new_power(new_power_option_2, option)
		power_pool.erase(option)
	if len(power_pool) > 0:
		var option = power_pool.pick_random()
		add_new_power(new_power_option_3, option)
		power_pool.erase(option)


func discard_used_powers() -> void:
	for power: Node in get_tree().get_nodes_in_group("active_power"):
		power.remove_from_group("active_power")
		power.add_to_group("unavailable_power")
		power.uses_left = power.blueprint.uses_max


func spawn_wave(x: int) -> void:
	if wave < WAVE_COUNT:
		for y in range(4):
			spawn_enemy(Vector2i(x, y), choose_next_enemy_blueprint())
			enemy_points += wave + 3
		wave += 1


func choose_next_enemy_blueprint() -> EnemyBlueprint:
	if enemy_points > 25:
		enemy_points -= 25
		return preload("res://data/enemies/boss.tres")
	if randi_range(0, 8) > 7 - enemy_points:
		if randf() > 2. / 3.:
			enemy_points -= 7
			return preload("res://data/enemies/basic.tres")
		elif randf() > 1. / 3.:
			enemy_points -= 8
			return preload("res://data/enemies/armored.tres")
		else:
			enemy_points -= 4
			return preload("res://data/enemies/thief.tres")
	return null


func spawn_enemy(coords: Vector2i, blueprint: EnemyBlueprint) -> void:
	if blueprint != null:
		var enemy: Enemy = preload("res://scenes/enemy.tscn").instantiate()
		add_child(enemy)
		enemy.coords = coords
		enemy.global_position = EnemyHelper.get_grid_target_position(coords + Vector2i.RIGHT)
		enemy.clicked.connect(_on_enemy_clicked)
		enemy.attacked_player.connect(_on_enemy_attacked_player)
		enemy.blueprint = blueprint


func check_win() -> void:
	if len(EnemyHelper.get_all_enemies()) == 0 and wave >= WAVE_COUNT:
		state = State.ENDED
		await show_popup(tr("VICTORY"), 3.5)
		UserSettings.is_victory = true
		get_tree().change_scene_to_file("res://scenes/credits.tscn")


func check_game_over() -> void:
	if Player.hp == 0:
		state = State.ENDED
		await show_popup(tr("DEFEAT"), 3.5)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func show_popup(message: String, popup_time: float) -> void:
	var popup_label: Node = preload("res://scenes/popup_label.tscn").instantiate()
	add_child(popup_label)
	popup_label.life_span = popup_time
	popup_label.display_text(message)
	await popup_label.done


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
	if damage > 0:
		var damage_done = clamp(damage - Player.defend, 0, 9999)
		if Player.is_overloaded():
			damage_done = damage_done * 9999
		Global.show_floating_text(
			player_sprite.global_position + Vector2(0., -32.),
			"-%s" % damage_done,
			Color.RED
		)
		if damage_done > 0:
			player_sprite.modulate = Color.RED
		else:
			player_sprite.modulate = Color.SKY_BLUE
		await get_tree().create_timer(0.1).timeout
		player_sprite.modulate = Color.WHITE
		Player.hp -= damage_done
		Player.defend -= damage - damage_done
		await check_game_over()
	for lost_power in range(power_loss):
		Global.show_floating_text(
			player_sprite.global_position + Vector2(0., -32.),
			tr("POWER LOST"),
			Color.WHITE
		)
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
		State.CHOOSE_NEW_CARD:
			reward_window.popup_on_parent(get_rect())
		State.CHOOSE_POWERS:
			state = State.CHOOSE_TARGETS
		State.CHOOSE_TARGETS:
			state = State.ENEMY_TURN
			enemy_turn()


func _on_settings_button_pressed() -> void:
	if state == State.CHOOSE_POWERS or state == State.CHOOSE_TARGETS:
		AudioBus.play("Click")
		var settings: Window = preload("res://scenes/settings.tscn").instantiate()
		add_child(settings)
		settings.popup_centered()


func _on_quit_button_pressed() -> void:
	AudioBus.play("Click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
