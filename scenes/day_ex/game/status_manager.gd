class_name StatusManager
extends RefCounted


var _is_charmed: bool
var _poison_damage: int:
	set(value):
		_poison_damage = maxi(0, value)


func get_poison_damage() -> int:
	return _poison_damage


func is_poisoned() -> bool:
	return _poison_damage > 0


func is_charmed() -> bool:
	return _is_charmed


func set_is_charmed(value: bool) -> void:
	_is_charmed = value


func set_poison_damage(value: int) -> void:
	_poison_damage = value


func clear_all_status_effect() -> void:
	set_is_charmed(false)
	set_poison_damage(0)
