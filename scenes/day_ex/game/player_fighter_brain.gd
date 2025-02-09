class_name PlayerFighterBrain
extends FighterBrain


const ActionSelector = preload("res://scenes/day_ex/game/action_selector.gd")

var _action_selector: ActionSelector


func _init(action_selector: ActionSelector) -> void:
	_action_selector = action_selector


func _start_command_selection(fighter: Fighter, is_flee_forbidden: bool) -> void:
	_action_selector.update_actions(fighter, is_flee_forbidden)
	_action_selector.grab_focus.call_deferred()
	var selected_command: BattleCommand = await _action_selector.command_selected
	command_selected.emit(selected_command)


func _start_target_selection(target_side: BattlefieldSide) -> void:
	target_side.grab_focus.call_deferred()
	var selected_target: Fighter = await target_side.target_selected
	target_selected.emit(selected_target)
