extends PanelContainer


signal enemy_selection_canceled
signal enemy_slected(who: RpgEnemy)


const RpgEnemy = preload("res://scenes/day_ex/game/rpg_enemy.gd")

const EnemyScene = preload("res://scenes/day_ex/game/rpg_enemy.tscn")


@onready var _background_texture_rect: TextureRect = %BackgroundTextureRect
@onready var _back_row: HBoxContainer = %BackRow
@onready var _front_row: HBoxContainer = %FrontRow


func setup(enemy_party: BattleParty, background: Texture2D) -> void:
	_background_texture_rect.texture = background
	
	var tally := {}
	var enemy_ocurrences_count = enemy_party.count_enemy_ocurrences()
	_setup_enemy_row(enemy_party.get_front_row_enemies(), 
			_front_row, tally, enemy_ocurrences_count)
	_setup_enemy_row(enemy_party.get_back_row_enemies(),
			 _back_row, tally, enemy_ocurrences_count)
	_setup_enemy_focus_neighbors()


func teardown() -> void:
	_background_texture_rect.texture = null
	_clear_enemy_row(_front_row)
	_clear_enemy_row(_back_row)


func _setup_enemy_row(
		enemies: Array[BattleEnemyData],
		row: HBoxContainer, 
		tally: Dictionary,
		enemy_ocurrences_count: Dictionary) -> void:
	
	for enemy_data: BattleEnemyData in enemies:
		var new_enemy_node: RpgEnemy = EnemyScene.instantiate()
		
		var enemy_name: String = enemy_data.get_enemy_name()
		if tally.has(enemy_name):
			tally[enemy_name] += 1
		else:
			tally[enemy_name] = 1
		var unique: bool = enemy_ocurrences_count[enemy_name] == 1
		var enemy_ocurrence: int = -1 if unique else tally[enemy_name]
		new_enemy_node.set_enemy_data(enemy_data, enemy_ocurrence)
		
		new_enemy_node.selected.connect(_on_enemy_selected)
		new_enemy_node.selection_canceled.connect(_on_enemy_selection_canceled)
		row.add_child(new_enemy_node)


func _clear_enemy_row(row: HBoxContainer) -> void:
	for child_node: Node in row.get_children():
		child_node.queue_free()


func _setup_enemy_focus_neighbors() -> void:
	var has_enemies_on_the_back_row: int = _back_row.get_child_count() > 0
	var front_row_max_index: int = _front_row.get_child_count() - 1
	var back_row_max_index: int = _back_row.get_child_count() - 1
	
	for index: int in _front_row.get_child_count():
		var enemy_node := _front_row.get_child(index) as Control
		var enemy_node_path = enemy_node.get_path()
		enemy_node.focus_neighbor_bottom = enemy_node_path
		if not has_enemies_on_the_back_row:
			enemy_node.focus_neighbor_top = enemy_node_path
		if index == 0:
			enemy_node.focus_neighbor_left = enemy_node_path
		if index == front_row_max_index:
			enemy_node.focus_neighbor_right = enemy_node_path
	
	for index: int in _back_row.get_child_count():
		var enemy_node := _back_row.get_child(index) as Control
		var enemy_node_path = enemy_node.get_path()
		enemy_node.focus_neighbor_top = enemy_node_path
		if index == 0:
			enemy_node.focus_neighbor_left = enemy_node_path
		if index == back_row_max_index:
			enemy_node.focus_neighbor_right = enemy_node_path


func _on_enemy_selected(who) -> void:
	print(who.get_full_name(), " selected")
	enemy_slected.emit(who)


func _on_enemy_selection_canceled() -> void:
	print("enemy selection canceled")
	enemy_selection_canceled.emit()


func _on_focus_entered() -> void:
	var front_row_children := _front_row.get_children()
	if not front_row_children.is_empty():
		front_row_children[0].call_deferred("grab_focus")
