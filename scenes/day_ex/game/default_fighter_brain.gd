class_name DefaultFighterBrain
extends FighterBrain


func _start_command_selection(fighter: Fighter, _is_flee_forbidden: bool) -> void:
	var weighted_actions: Array[EnemyCommand] = fighter.get_weighted_actions()
	if weighted_actions.is_empty():
		command_selected.emit(BattleCommand.Pass.new())

	var curr_mp: int = fighter.get_stats_manager().get_curr_mp()
	weighted_actions = weighted_actions.filter(
			_filter_doable_actions.bind(curr_mp))
	var weighted_actions_count: int = weighted_actions.size()
	var weights: Array[float] = []
	weights.resize(weighted_actions_count)
	for i: int in weighted_actions_count:
		weights[i] = weighted_actions[i].get_weight()
	
	var selected_idx: int = Utils.rand_weigthed(weights)
	if selected_idx < 0:
		command_selected.emit(BattleCommand.Pass.new())
		return
		
	var selected_action: BattleAction = \
			weighted_actions[selected_idx].get_action()
	command_selected.emit(BattleCommand.Hurt.new(selected_action))


func _start_target_selection(target_side: BattlefieldSide) -> void:
	var targets: Array[Fighter] = target_side.get_members()
	var selected_target: Fighter = \
			null if targets.is_empty() else targets.pick_random()
	target_selected.emit(selected_target)


func _filter_doable_actions(item, curr_mp: int) -> bool:
	var enemy_command := item as EnemyCommand
	if not enemy_command:
		return false
	
	var action: BattleAction = enemy_command.get_action()
	match action.get_consumable():
		BattleAction.Consumable.MP:
			return curr_mp >= action.get_cost()
		BattleAction.Consumable.SCRAPS:
			return false
		BattleAction.Consumable.NOTHING:
			return true
		_:
			return false
