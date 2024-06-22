extends PanelContainer


signal target_selection_canceled
signal target_selected(target: Fighter)


const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

const FighterScene = preload("res://scenes/day_ex/game/fighter.tscn")

var _members: Array[Fighter]

@onready var _background_texture_rect: TextureRect = %BackgroundTextureRect
@onready var _back_row: HBoxContainer = %BackRow
@onready var _front_row: HBoxContainer = %FrontRow


func setup(party: BattleParty, background: Texture2D) -> void:
	_background_texture_rect.texture = background
	
	var tally := {}
	var member_ocurrences_count = party.count_member_ocurrences()
	_setup_row(party.get_front_row_members(), 
			_front_row, tally, member_ocurrences_count)
	_setup_row(party.get_back_row_members(),
			 _back_row, tally, member_ocurrences_count)
	_setup_member_focus_neighbors()


func get_members() -> Array[Fighter]:
	return _members


func is_party_defeated() -> bool:
	var front_row_children: Array[Node] = _front_row.get_children()
	var back_row_children: Array[Node] = _back_row.get_children()
	var front_row_defeated: bool = front_row_children.all(func(fighter: Fighter):
			return fighter.is_dead())
	var back_row_defeated: bool = back_row_children.all(func(fighter: Fighter):
			return fighter.is_dead())
	return front_row_defeated and back_row_defeated


func teardown() -> void:
	_background_texture_rect.texture = null
	_members.clear()
	_clear_row(_front_row)
	_clear_row(_back_row)


func _setup_row(
		members: Array[FighterData],
		row: HBoxContainer, 
		tally: Dictionary,
		member_ocurrences_count: Dictionary) -> void:
	
	for fighter_data: FighterData in members:
		var new_fighter_node: Fighter = FighterScene.instantiate()
		
		var fighter_name: String = fighter_data.get_char_name()
		if tally.has(fighter_name):
			tally[fighter_name] += 1
		else:
			tally[fighter_name] = 1
		var unique: bool = member_ocurrences_count[fighter_name] == 1
		var fighter_ocurrence: int = -1 if unique else tally[fighter_name]
		new_fighter_node.set_fighter_data(fighter_data, fighter_ocurrence)
		_members.append(new_fighter_node)
		
		new_fighter_node.selected.connect(_on_fighter_selected)
		new_fighter_node.selection_canceled.connect(_on_fighter_selection_canceled)
		row.add_child(new_fighter_node)


func _clear_row(row: HBoxContainer) -> void:
	for child_node: Node in row.get_children():
		child_node.queue_free()


func _setup_member_focus_neighbors() -> void:
	var has_members_on_the_back_row: int = _back_row.get_child_count() > 0
	var front_row_max_index: int = _front_row.get_child_count() - 1
	var back_row_max_index: int = _back_row.get_child_count() - 1
	
	for index: int in _front_row.get_child_count():
		var fighter_node := _front_row.get_child(index) as Control
		var fighter_node_path = fighter_node.get_path()
		fighter_node.focus_neighbor_bottom = fighter_node_path
		if not has_members_on_the_back_row:
			fighter_node.focus_neighbor_top = fighter_node_path
		if index == 0:
			fighter_node.focus_neighbor_left = fighter_node_path
		if index == front_row_max_index:
			fighter_node.focus_neighbor_right = fighter_node_path
	
	for index: int in _back_row.get_child_count():
		var fighter_node := _back_row.get_child(index) as Control
		var fighter_node_path = fighter_node.get_path()
		fighter_node.focus_neighbor_top = fighter_node_path
		if index == 0:
			fighter_node.focus_neighbor_left = fighter_node_path
		if index == back_row_max_index:
			fighter_node.focus_neighbor_right = fighter_node_path


func _on_fighter_selected(target: Fighter) -> void:
	print(target.get_full_name(), " selected")
	target_selected.emit(target)


func _on_fighter_selection_canceled() -> void:
	print("fighter selection canceled")
	target_selection_canceled.emit()


func _on_focus_entered() -> void:
	var front_row_children: Array[Node] = _front_row.get_children()
	for fighter: Fighter in front_row_children:
		if not fighter.is_dead():
			fighter.call_deferred("grab_focus")
			return
	var back_row_children: Array[Node] = _back_row.get_children()
	for fighter: Fighter in back_row_children:
		if not fighter.is_dead():
			fighter.call_deferred("grab_focus")
			return
	release_focus()
