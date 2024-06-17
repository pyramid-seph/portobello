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

var _cached_stats: Stats


func get_stats_for_level(level: int, skip_cache: bool = false) -> Stats:
	if not skip_cache and _cached_stats and _cached_stats.level == level:
		return _cached_stats
	
	var stats = Stats.new()
	_cached_stats = stats
	
	if _experience_curve.is_empty():
		return stats
	
	var index: int = wrapi(level, 0, _experience_curve.size())
	stats.level = index + 1
	stats.experience = _experience_curve[index]
	stats.hp = _hp_curve[index]
	stats.mp = _mp_curve[index]
	stats.attack = _attack_curve[index]
	stats.defense = _defense_curve[index]
	stats.speed = _speed_curve[index]
	stats.agility = _agility_curve[index]
	stats.luck = _luck_curve[index]
	return stats


func _validate_property(property: Dictionary) -> void:
	property.usage |= PROPERTY_USAGE_READ_ONLY
