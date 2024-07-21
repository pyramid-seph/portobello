class_name BattleCommand
extends RefCounted


class Flee extends BattleCommand:
	pass


class Pass extends BattleCommand:
	pass


class Hurt extends BattleCommand:
	var _action: BattleAction
	
	func get_action() -> BattleAction:
		return _action
	
	
	func _init(action: BattleAction) -> void:
		_action = action
	
