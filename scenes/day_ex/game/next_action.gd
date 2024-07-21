class_name NextAction
extends RefCounted

const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

enum ActionType {
	FLEE,
	ATTACK
}

var _action_type: ActionType
var _target: Fighter
var _attack: BattleAction


func _init(action_type: ActionType, target: Fighter, attack: BattleAction) -> void:
	_target = target
	_attack = attack


func get_type() -> ActionType:
	return _action_type


func get_target() -> Fighter:
	return _target


func get_attack() -> BattleAction:
	return _attack


static func attack(target: Fighter, attack: BattleAction) -> NextAction:
	return NextAction.new(ActionType.ATTACK, target, attack)


static func flee() -> NextAction:
	return NextAction.new(ActionType.FLEE, null, null)
