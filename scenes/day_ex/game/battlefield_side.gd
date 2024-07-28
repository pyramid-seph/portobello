extends PanelContainer


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


func set_background(background: Texture2D) -> void:
	if is_node_ready():
		_background_texture_rect.texture = background


func get_members() -> Array[Fighter]:
	return _members


## Returns requested member. Returns null if the index is out of bounds.
## Front row members go first.
func get_member_at(idx: int) -> Fighter:
	return _members[idx] if idx > -1 and idx < _members.size() else null


func is_party_defeated() -> bool:
	if _members.is_empty():
		return true
	
	return _members.all(func(fighter: Fighter):
			return fighter.is_removed_from_battle())


func is_party_killed() -> bool:
	if _members.is_empty():
		return true
	
	return _members.all(func(fighter: Fighter):
			return fighter.is_dead()) 


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
		new_fighter_node.selected.connect(_on_fighter_selected)
		new_fighter_node.selection_canceled.connect(_on_fighter_selection_canceled)
		row.add_child(new_fighter_node)
		_members.append(new_fighter_node)


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


func _clear_row(row: HBoxContainer) -> void:
	for child_node: Node in row.get_children():
		child_node.queue_free()


func _on_fighter_selected(target: Fighter) -> void:
	print(target.get_full_name(), " selected")
	target_selected.emit(target)


func _on_fighter_selection_canceled() -> void:
	print("fighter selection canceled")
	target_selected.emit(null)


func _on_focus_entered() -> void:
	for fighter: Fighter in _members:
		if not fighter.is_removed_from_battle():
			fighter.call_deferred("grab_focus")
			return
	
	release_focus()
	_on_fighter_selection_canceled()
