extends VBoxContainer


signal command_selected(command: BattleCommand)
signal current_info_changed(info_msg: String)

const UI_DAY_EX_COMMAND_SELECTOR_FOCUS = preload("res://audio/ui/ui_day_ex_command_selector_focus.wav")

const COMMAND_CURE = preload("res://resources/instances/day_ex/actions/command_cure.tres")
const COMMAND_EAT = preload("res://resources/instances/day_ex/actions/command_eat.tres")
const COMMAND_DUMMY_BACK = preload("res://resources/instances/day_ex/actions/dummy_back.tres")

const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

enum MainMenu {
	ATTACK,
	ABILITY,
	EAT,
	CURE,
	FLEE,
}

var _main_menu_options: Array[Dictionary] = [
	{
		"label": "RPG_BATTLE_COMMAND_ATTACK",
		"value": {
			"command": MainMenu.ATTACK,
			"info": "RPG_BATTLE_INFO_COMMAND_ATTACK",
		},
	},
	{
		"label": "RPG_BATTLE_COMMAND_ABILITY",
		"value": {
			"command": MainMenu.ABILITY,
			"info": "RPG_BATTLE_INFO_COMMAND_ABILITY",
		},
	},
	{
		"label": COMMAND_EAT.get_action_name(),
		"value": {
			"command": MainMenu.EAT,
			"info": COMMAND_EAT.get_info(),
		},
	},
	{
		"label": COMMAND_CURE.get_action_name(),
		"value": {
			"command": MainMenu.CURE,
			"info": COMMAND_CURE.get_info(),
		},
	},
	{
		"label": "RPG_BATTLE_COMMAND_FLEE",
		"value": {
			"command": MainMenu.FLEE,
			"info": "RPG_BATTLE_INFO_COMMAND_FLEE",
		},
	},
]

var _attack_options: Array[Dictionary]
var _ability_options: Array[Dictionary]

@onready var _command_selector: HSelector = $CommandHSelector
@onready var _action_selector: HSelector = $ActionHSelector
@onready var _ui_sounds: UiSounds = $UiSounds


func _ready() -> void:
	_action_selector.modulate.a = 0.0
	_command_selector.set_options(_main_menu_options)
	_action_selector.set_options([])
	_reset()


func update_actions(fighter: Fighter, disable_flee: bool = false) -> void:
	var actions: Array[BattleAction] = fighter.get_actions()
	var partition: Array = Utils.partition(actions, func(action: BattleAction):
			return action.get_consumable() == BattleAction.Consumable.NOTHING)
	var attacks: Array = partition[0]
	var abilities: Array = partition[1]
	attacks.append(COMMAND_DUMMY_BACK)
	abilities.append(COMMAND_DUMMY_BACK)

	var can_perform_attacks: bool = attacks.size() > 1
	var can_perform_abilities: bool = \
			fighter.get_stats_manager().get_curr_mp() > 0 and abilities.size() > 1
	_command_selector.set_option_disabled(MainMenu.ATTACK, !can_perform_attacks)
	_command_selector.set_option_disabled(MainMenu.ABILITY, !can_perform_abilities)

	_attack_options = _map_actions_to_options(attacks)
	_ability_options = _map_actions_to_options(abilities)

	var can_cure: bool = fighter.scraps > 0
	_command_selector.set_option_disabled(MainMenu.CURE, !can_cure)

	_command_selector.set_option_disabled(MainMenu.FLEE, disable_flee)

	_reset()


func _map_actions_to_options(actions: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	result.resize(actions.size())
	for i: int in actions.size():
		var action := actions[i] as BattleAction
		if action:
			result[i] = { "label": action.get_action_name(), "value": action }
	return result


func _reset(skip_select_first_main_menu_option: bool = false) -> void:
	if not skip_select_first_main_menu_option:
		_command_selector.current_option_idx = 0

	if _action_selector.get_options_count() > 0:
		_action_selector.current_option_idx = 0
	_action_selector.release_focus()


func _on_command_h_selector_selected(selected: Dictionary) -> void:
	match selected.command:
		MainMenu.ATTACK:
			_action_selector.set_options(_attack_options)
			_ui_sounds.focus_node_no_sound.call_deferred(_action_selector)
		MainMenu.ABILITY:
			_action_selector.set_options(_ability_options)
			_ui_sounds.focus_node_no_sound.call_deferred(_action_selector)
		MainMenu.EAT:
			command_selected.emit(BattleCommand.Hurt.new(COMMAND_EAT))
			_command_selector.release_focus()
		MainMenu.CURE:
			command_selected.emit(BattleCommand.Hurt.new(COMMAND_CURE))
			_command_selector.release_focus()
		MainMenu.FLEE:
			command_selected.emit(BattleCommand.Flee.new())
			_command_selector.release_focus()
		_:
			Log.d(name, " |> Unknown option selected: ", selected)


func _on_action_h_selector_selected(action: BattleAction) -> void:
	if action == COMMAND_DUMMY_BACK:
		_ui_sounds.focus_node_no_sound.call_deferred(_command_selector)
		_reset(true)
	else:
		command_selected.emit(BattleCommand.Hurt.new(action))
		_action_selector.release_focus()


func _on_command_h_selector_current_option_index_changed(index: int) -> void:
	current_info_changed.emit(_main_menu_options[index].value.info)


func _on_action_h_selector_current_option_index_changed(index: int) -> void:
	var action := _action_selector.get_value_for_option(index) as BattleAction
	var info: String = action.get_info()
	current_info_changed.emit(info)


func _on_focus_entered() -> void:
	SoundManager.play_ui_sound(UI_DAY_EX_COMMAND_SELECTOR_FOCUS)
	_ui_sounds.focus_node_no_sound.call_deferred(_command_selector)
	_reset()


func _on_command_h_selector_focus_entered() -> void:
	var info: String = ""
	var curr_idx: int = _command_selector.current_option_idx
	if curr_idx != HSelector.SELECTED_NONE:
		var selected_value := \
				_command_selector.get_value_for_option(curr_idx) as Dictionary
		info = selected_value.info
	current_info_changed.emit(info)


func _on_action_h_selector_focus_entered() -> void:
	_action_selector.modulate.a = 1.0

	var info: String = ""
	var curr_idx: int = _action_selector.current_option_idx
	if curr_idx != HSelector.SELECTED_NONE:
		var selected_value := \
				_action_selector.get_value_for_option(curr_idx) as BattleAction
		info = selected_value.get_info()
	current_info_changed.emit(info)


func _on_action_h_selector_focus_exited() -> void:
	_action_selector.modulate.a = 0.0
