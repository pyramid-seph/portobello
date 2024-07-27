class_name PlayerFighterBrain
extends FighterBrain


const ActionSelector = preload("res://scenes/day_ex/game/action_selector.gd")

var _action_selector: ActionSelector


func _init(action_selector: ActionSelector) -> void:
	_action_selector = action_selector


func _start_command_selection(fighter: Fighter) -> void:
	var available_weighted_actions: Array[EnemyCommand] = \
			fighter.get_available_weighted_actions()
	
	var actions_count: int = available_weighted_actions.size()
	if actions_count == 0:
		command_selected.emit(BattleCommand.Pass.new())
	
	var battle_actions: Array[BattleAction] = []
	battle_actions.resize(actions_count)
	for i: int in actions_count:
		battle_actions[i] = available_weighted_actions[i].get_action()
	_action_selector.set_actions(battle_actions)
	_action_selector.call_deferred("grab_focus")
	var selected_command: BattleCommand = await _action_selector.command_selected
	command_selected.emit(selected_command)


func _start_target_selection(target_side: BattlefieldSide) -> void:
	target_side.call_deferred("grab_focus")
	var selected_target: Fighter = await target_side.target_selected
	target_selected.emit(selected_target)
