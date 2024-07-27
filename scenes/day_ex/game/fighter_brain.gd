class_name FighterBrain
extends RefCounted

signal command_selected(command: BattleCommand)
signal target_selected(fighter: Fighter)

const BattlefieldSide = preload("res://scenes/day_ex/game/battlefield_side.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")


func start_command_selection(fighter: Fighter) -> void:
	# Deferring call so we give consumers a chance to observe the command_selected signal
	call_deferred("_start_command_selection", fighter)


func  start_target_selection(target_side: BattlefieldSide) -> void:
	# Deferring call so we give consumers a chance to observe the target_selected signal
	call_deferred("_start_target_selection", target_side)


# Implement this function.
func _start_command_selection(fighter: Fighter) -> void:
	command_selected.emit(BattleCommand.Pass.new())


# Implement this function
func _start_target_selection(target_side: BattlefieldSide) -> void:
	target_selected.emit(null)
