extends PanelContainer


signal target_selected(target: Fighter)

const UI_SOUND_FOCUS = preload("res://audio/ui/kenney_interface_sounds/drop_003.ogg")
const UI_SOUND_SELECT = preload("res://audio/ui/kenney_interface_sounds/drop_002.ogg")

const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

# WORKAROUND FighterScene.instantiate() returns null if 
# fighter.tscn is preloaded because there is a reference cycle between
# fighter.tscn and battle_side.tscn (via their custom scripts).
# This bad behaviour did not happen before Godot 4.4.
# Since this project is on maintenance mode, I don't feel like refactoring
# these scripts to break the reference cycle :P.
var FighterScene = load("res://scenes/day_ex/game/fighter.tscn")

var _members: Array[Fighter]
var _narrator: BattleNarrationBox
var _skip_focus_sound: bool

@onready var _background_texture_rect: TextureRect = %BackgroundTextureRect
@onready var _back_row: HBoxContainer = %BackRow
@onready var _front_row: HBoxContainer = %FrontRow


func setup(party: BattleParty, background: Texture2D = null) -> void:
	_background_texture_rect.texture = background
	
	var tally: Dictionary[String, int] = {}
	var member_ocurrences_count: Dictionary[String, int] = \
			party.count_member_ocurrences()
	_setup_row(party.get_front_row_members(),
			_front_row, tally, member_ocurrences_count)
	_setup_row(party.get_back_row_members(),
			 _back_row, tally, member_ocurrences_count)
	_setup_focus_neighbors()
	_setup_focus_sounds()


func set_narrator(narrator: BattleNarrationBox) -> void:
	_narrator  = narrator


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
		tally: Dictionary[String, int],
		member_ocurrences_count: Dictionary[String, int]) -> void:
	
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
		new_fighter_node.set_narrator(_narrator)
		new_fighter_node.selected.connect(_on_fighter_selected)
		new_fighter_node.selection_canceled.connect(_on_fighter_selection_canceled)
		new_fighter_node.get_stats_manager().curr_hp_changed.connect(
				_on_member_hp_changed.bind(new_fighter_node))
		row.add_child(new_fighter_node)
		_members.append(new_fighter_node)


func _setup_row_focus_neighbors(this_row: Node, other_row: Node) -> void:
	var other_row_children: Array[Node] = other_row.get_children()
	var is_other_row_empty: bool = other_row_children.is_empty()
	var has_other_row_any_active_fighters: bool = other_row_children.any(
			func(member: Fighter):
				return not member.is_removed_from_battle())
	
	var other_row_first_active_path: String = ""
	if not is_other_row_empty and has_other_row_any_active_fighters:
		for member: Fighter in other_row_children:
			if not member.is_removed_from_battle():
				other_row_first_active_path = member.get_path()
				break
	
	for idx: int in this_row.get_child_count():
		var fighter_node := this_row.get_child(idx) as Control
		var fighter_node_path = fighter_node.get_path()
		
		if (fighter_node as Fighter).is_removed_from_battle():
			fighter_node.focus_neighbor_top = fighter_node_path
			fighter_node.focus_neighbor_bottom = fighter_node_path
			fighter_node.focus_neighbor_right = fighter_node_path
			fighter_node.focus_neighbor_left = fighter_node_path
			continue
		
		var top_bottom_focus_path: String = other_row_first_active_path
		if not top_bottom_focus_path:
			top_bottom_focus_path  = fighter_node_path
		
		fighter_node.focus_neighbor_top = top_bottom_focus_path
		fighter_node.focus_neighbor_bottom = top_bottom_focus_path
		
		var next_idx: int = idx
		for _i: int in this_row.get_child_count():
			next_idx = wrapi(next_idx + 1, 0, this_row.get_child_count())
			var member := this_row.get_child(next_idx) as Fighter
			if not member.is_removed_from_battle():
				break
		var next_path: String = this_row.get_child(next_idx).get_path()
		
		var prev_idx: int = idx
		for _i: int in this_row.get_child_count():
			prev_idx = wrapi(prev_idx - 1, 0, this_row.get_child_count())
			var member := this_row.get_child(prev_idx) as Fighter
			if not member.is_removed_from_battle():
				break
		var prev_path: String = this_row.get_child(prev_idx).get_path()
		
		fighter_node.focus_next = next_path
		fighter_node.focus_neighbor_right = next_path
		fighter_node.focus_previous = prev_path
		fighter_node.focus_neighbor_left = prev_path


func _setup_focus_neighbors() -> void:
	_setup_row_focus_neighbors(_front_row, _back_row)
	_setup_row_focus_neighbors(_back_row, _front_row)


func _setup_focus_sounds() -> void:
	for node: Control in get_members():
		node.focus_entered.connect(_on_fighter_focus_entered)


func _clear_row(row: HBoxContainer) -> void:
	for child_node: Node in row.get_children():
		child_node.queue_free()


func _on_member_hp_changed(member: Fighter) -> void:
	if not is_party_defeated() and \
			member.get_stats_manager().get_curr_hp() <= 0:
		_setup_focus_neighbors()


func _on_fighter_focus_entered() -> void:
	if _skip_focus_sound:
		_skip_focus_sound = false
	else:
		SoundManager.play_sound(UI_SOUND_FOCUS)


func _on_fighter_selected(target: Fighter) -> void:
	Log.d("%s selected" % target.get_full_name())
	_skip_focus_sound = false
	SoundManager.play_sound(UI_SOUND_SELECT)
	target_selected.emit(target)


func _on_fighter_selection_canceled() -> void:
	Log.d("fighter selection canceled")
	_skip_focus_sound = false
	target_selected.emit(null)


func _on_focus_entered() -> void:
	for fighter: Fighter in _members:
		if not fighter.is_removed_from_battle():
			_skip_focus_sound = true
			fighter.grab_focus.call_deferred()
			return
	
	release_focus()
	_on_fighter_selection_canceled()
