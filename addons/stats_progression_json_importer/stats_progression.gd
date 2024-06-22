class_name StatsProgression
extends Resource


@export var _experience_curve: PackedInt32Array
@export var _hp_curve: PackedInt32Array
@export var _mp_curve: PackedInt32Array
@export var _attack_curve: PackedInt32Array
@export var _defense_curve: PackedInt32Array
@export var _speed_curve: PackedInt32Array
@export var _agility_curve: PackedInt32Array
@export var _luck_curve: PackedInt32Array


func get_max_level() -> int:
	return maxi(1, _experience_curve.size())


func get_min_experience() -> int:
	var size: int = _experience_curve.size()
	return _experience_curve[0] if size > 0 else 0


func get_max_experience() -> int:
	var size: int = _experience_curve.size()
	return _experience_curve[size - 1] if size > 0 else 0


func get_level_by_experience(experience: int) -> int:
	var result: int = 0
	var clamped_exp: int = \
			clampi(experience, get_min_experience(), get_max_experience())
	for i: int in _experience_curve.size():
		if clamped_exp >= _experience_curve[i]:
			result = i
		else:
			break
	return result + 1


func build_stats_for_level(level: int) -> Stats:
	var stats := Stats.new()
	
	if _experience_curve.is_empty():
		return stats
	
	var index: int = clampi(level - 1, 0, _experience_curve.size() - 1)
	stats._level = index + 1
	stats._experience = _experience_curve[index]
	stats._hp = _hp_curve[index]
	stats._mp = _mp_curve[index]
	stats._attack = _attack_curve[index]
	stats._defense = _defense_curve[index]
	stats._speed = _speed_curve[index]
	stats._agility = _agility_curve[index]
	stats._luck = _luck_curve[index]
	return stats


func _validate_property(property: Dictionary) -> void:
	property.usage |= PROPERTY_USAGE_READ_ONLY
