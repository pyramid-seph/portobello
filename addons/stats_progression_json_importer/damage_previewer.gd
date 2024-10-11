@tool
extends Control


const FIGHTER_DATA_DIR_PATH: String = "res://resources/instances/day_ex/chars/"
const RES_SUFFIX: String = ".tres"

@onready var _dmg_table: Tree = %DmgTable
@onready var _error_label: Label = %ErrorLabel
@onready var _attacker_option_button: OptionButton = %AttackerOptionButton
@onready var _target_option_button: OptionButton = %TargetOptionButton
@onready var _attacker_lvl_spin_box: SpinBox = %AttackerLvlSpinBox


func _ready() -> void:
	_load_options()
	_setup_table()


func _reset_table() -> void:
	_dmg_table.clear()
	_error_label.text = ""


func _setup_table() -> void:
	_dmg_table.columns = 10
	_dmg_table.set_column_title(0, "Attacker Attack")
	_dmg_table.set_column_custom_minimum_width(0, 350.0)
	for i: int in _dmg_table.columns - 1:
		var level: int = i + 1
		_dmg_table.set_column_title(level, "Target LVL %s" % level)
		_dmg_table.set_column_custom_minimum_width(level, 200.0)


func _load_options() -> void:
	_attacker_lvl_spin_box.value = 1
	_attacker_option_button.clear()
	_target_option_button.clear()
	
	var data_dir := DirAccess.open(FIGHTER_DATA_DIR_PATH)
	if not data_dir:
		var error: Error = DirAccess.get_open_error()
		_error_label.text = "Error while accesing data directory: %s" % error
		return
	
	var fighter_data_files = data_dir.get_files()
	for i: int in fighter_data_files.size():
		var file_name: String = fighter_data_files[i]
		if not file_name.ends_with(RES_SUFFIX):
			continue
		
		var option_label: String = file_name.trim_suffix(RES_SUFFIX)
		var res_path: String = "/".join([FIGHTER_DATA_DIR_PATH, file_name])
		_attacker_option_button.add_item(option_label, i)
		_attacker_option_button.set_item_metadata(i, res_path)
		_target_option_button.add_item(option_label, i)
		_target_option_button.set_item_metadata(i, res_path)
	
	var selected_file_idx: int = -1 if fighter_data_files.is_empty() else 0
	_attacker_option_button.selected = selected_file_idx
	_target_option_button.selected = selected_file_idx


func _build_action_name(attack: BattleAction) -> String:
	var attack_name: String = attack.get_action_name().trim_prefix("RPG_BATTLE_")
	attack_name = attack_name.replace("ATTACK_NAME_PLAYER", "ATTACK > ")
	attack_name = attack_name.replace("ABILITY_NAME_PLAYER", "ABILITY > ")
	attack_name = attack_name.replace("ATTACK_NAME_ENEMY", "ATTACK > ")
	attack_name = attack_name.replace("ABILITY_NAME_ENEMY", "ABILITY > ")
	attack_name = attack_name.capitalize()
	return attack_name


func _build_dmg_preview(attacker_stats: Stats, target_stats: Stats, attack: BattleAction) -> String:
	if not attack.is_physical_attack():
		return ""
	
	if attack.get_physical_damage() == BattleAction.PhysicalDamage.LOSE_HP_PERCENT:
		return "%s%%" % floori(attack.get_damage_percent() * 100.0)
	
	var attacker_atkf = float(attacker_stats.get_atk())
	var target_deff = float(target_stats.get_def())
	var min_extra_dmg: int = floori(5 + target_deff / attacker_atkf)
	var max_extra_dmg: int = floori(5 + attacker_atkf / target_deff)
	var dmg_mult: float = snappedf(1.0 + 3.0 * attacker_atkf / 99.0, 0.01)
	var attack_dmgf = float(attack.get_damage_points())
	var base_dmg: int = floori(attack_dmgf * dmg_mult)
	var min_dmg: int = maxi(1, base_dmg - min_extra_dmg)
	var max_dmg: int = maxi(1, base_dmg + max_extra_dmg)
	return " - ".join([min_dmg, max_dmg])


func _build_status_effect_hit_chance_text(target_stats: Stats, attack: BattleAction) -> String:
	if not attack.inflicts_any_status_effect():
		return ""
	
	var hit_chance: float = attack.get_hit_chance()
	if hit_chance > 0.1 and not is_equal_approx(hit_chance, 1.0):
		var target_lckf: float = float(target_stats.get_lck())
		var min_hit_chance: float = hit_chance * 0.7
		var max_decrement: float = hit_chance - min_hit_chance
		var decrement: float = (target_lckf / 99.0) * max_decrement
		hit_chance = snappedf(hit_chance - decrement, 0.01)
	return "STATUS%%(%d)" % [hit_chance * 100.0]


func _build_phys_hit_chance_preview(target_stats: Stats, attack: BattleAction) -> String:
	if not attack.is_physical_attack():
		return ""
	
	var base_hit_chance: float = attack.get_hit_chance()
	var adjusted_hit_chance: float = base_hit_chance
	if base_hit_chance > 0.6 and not is_equal_approx(adjusted_hit_chance, 1.0):
		var target_agif: float = float(target_stats.get_agi())
		var min_hit_chance = adjusted_hit_chance * 0.7
		var max_decrement: float = adjusted_hit_chance - min_hit_chance
		var decrement: float = (target_agif / 99.0) * max_decrement
		adjusted_hit_chance = snappedf(adjusted_hit_chance - decrement, 0.01)
	
	var adjusted_hit_chance_percent: float = adjusted_hit_chance * 100.0
	if is_equal_approx(base_hit_chance, adjusted_hit_chance):
		return "PHYS%%(%d)" % adjusted_hit_chance_percent
	
	var base_hit_chance_percent = base_hit_chance * 100.0
	return "PHYS%%(%d - %d)" % \
			[adjusted_hit_chance_percent, base_hit_chance_percent]


func _build_hit_chance_preview(target_stats: Stats, attack: BattleAction) -> String:
	var hit_chance_phys: String = \
			_build_phys_hit_chance_preview(target_stats, attack)
	var hit_chance_status: String = \
			_build_status_effect_hit_chance_text(target_stats, attack)
	var hit_chance_texts = []
	if not hit_chance_phys.is_empty():
		hit_chance_texts.append(hit_chance_phys)
	if not hit_chance_status.is_empty():
		hit_chance_texts.append(hit_chance_status)
	return " | ".join(hit_chance_texts)


func _create_cell_text(attacker: FighterData, target: FighterData, 
		attack: BattleAction, attacker_lvl: int, target_level: int) -> String:
	var attacker_stats: Stats = attacker.get_base_stats_for_level(attacker_lvl)
	var target_stats: Stats = target.get_base_stats_for_level(target_level)
	var dmg_text: String = _build_dmg_preview(attacker_stats, target_stats, attack)
	var hit_chance_text: String = _build_hit_chance_preview(target_stats, attack)
	var cell_text: Array = []
	if not dmg_text.is_empty():
		cell_text.append(dmg_text)
	cell_text.append(hit_chance_text)
	return " | ".join(cell_text)


func _populate_table() -> void:
	_reset_table()
	
	var selected_attacker_idx: int = _attacker_option_button.selected
	var selected_target_idx: int = _target_option_button.selected
	if selected_attacker_idx == -1 or selected_target_idx == -1:
		_error_label.text = "Select an attacker and a target."
		return
	
	var attacker_res_path := _attacker_option_button.get_item_metadata(
			selected_attacker_idx) as String
	var target_res_path := _target_option_button.get_item_metadata(
			selected_target_idx) as String
	
	var attacker := load(attacker_res_path) as FighterData
	var target :=  load(target_res_path) as FighterData
	if not attacker or not target:
		_error_label.text = "Cannot load attacker or target."
		return
	
	var root: TreeItem = _dmg_table.create_item()
	for action: EnemyCommand in attacker.get_actions():
		var attack: BattleAction = action.get_action()
		var row: TreeItem = _dmg_table.create_item(root)
		var attack_name: String = _build_action_name(attack)
		row.set_text(0, attack_name)
		row.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
		
		var attacker_lvl: int = _attacker_lvl_spin_box.value
		for target_level: int in range(1, 10):
			var cell_text: String = _create_cell_text(attacker, target, attack, 
					attacker_lvl, target_level)
			row.set_text(target_level, cell_text)
			row.set_text_alignment(target_level, HORIZONTAL_ALIGNMENT_CENTER)


func _on_refresh_button_pressed() -> void:
	_reset_table()
	_load_options()


func _on_attacker_option_button_item_selected(index: int) -> void:
	_reset_table()


func _on_target_option_button_item_selected(index: int) -> void:
	_reset_table()


func _on_spin_box_value_changed(value: float) -> void:
	_reset_table()


func _on_calculate_button_pressed() -> void:
	_populate_table()
