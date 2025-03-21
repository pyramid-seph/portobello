class_name FighterBrain
extends RefCounted

signal command_selected(command: BattleCommand)
signal target_selected(fighter: Fighter)

const BattlefieldSide = preload("res://scenes/day_ex/game/battlefield_side.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")


func start_command_selection(fighter: Fighter, is_flee_forbidden: bool) -> void:
	# Deferring call so we give consumers a chance to process the command_selected signal
	_start_command_selection.call_deferred(fighter, is_flee_forbidden)


func  start_target_selection(target_side: BattlefieldSide) -> void:
	# Deferring call so we give consumers a chance to process the target_selected signal
	_start_target_selection.call_deferred(target_side)


# Implement this function.
@warning_ignore("unused_parameter")
func _start_command_selection(fighter: Fighter, is_flee_forbidden: bool) -> void:
	command_selected.emit(BattleCommand.Pass.new())


# Implement this function
@warning_ignore("unused_parameter")
func _start_target_selection(target_side: BattlefieldSide) -> void:
	target_selected.emit(null)
