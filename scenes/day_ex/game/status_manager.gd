class_name StatusManager
extends RefCounted

signal status_changed

var _is_charmed: bool:
	set(value):
		var old_value: bool = _is_charmed
		_is_charmed = value
		if _is_charmed != old_value:
			status_changed.emit()
var _poison_damage: int:
	set(value):
		var old_value: int = _poison_damage
		_poison_damage = maxi(0, value)
		if _poison_damage != old_value:
			status_changed.emit()


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
