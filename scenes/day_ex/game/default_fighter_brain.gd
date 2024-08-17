class_name DefaultFighterBrain
extends FighterBrain


func _start_command_selection(fighter: Fighter, is_flee_forbidden: bool) -> void:
	var weighted_actions: Array[EnemyCommand] = fighter.get_weighted_actions()
	if weighted_actions.is_empty():
		command_selected.emit(BattleCommand.Pass.new())
	
	var weighted_actions_count: int = weighted_actions.size()
	var weights: Array[float] = []
	weights.resize(weighted_actions_count)
	for i: int in weighted_actions_count:
		weights[i] = weighted_actions[i].get_weight()
	var selected_idx: int = Utils.rand_weigthed(weights)
	var selected_action: BattleAction = \
			weighted_actions[selected_idx].get_action()
	command_selected.emit(BattleCommand.Hurt.new(selected_action))


func _start_target_selection(target_side: BattlefieldSide) -> void:
	var targets: Array[Fighter] = target_side.get_members()
	var selected_target: Fighter = \
			null if targets.is_empty() else targets.pick_random()
	target_selected.emit(selected_target)
