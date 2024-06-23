class_name Stats
extends RefCounted

var _level: int = 1
var _experience: int
var _hp: int = 1
var _mp: int = 1
var _attack: int = 1
var _defense: int = 1
var _speed: int = 1
var _agility: int = 1
var _luck: int = 1


func get_level() -> int:
	return _level


func get_required_exp() -> int:
	return _experience


func get_max_hp() -> int:
	return _hp


func get_max_mp() -> int:
	return _mp


func get_atk() -> int:
	return _attack


func get_def() -> int:
	return _defense


func get_spd() -> int:
	return _speed


func get_agi() -> int:
	return _agility


func get_lck() -> int:
	return _luck


func diff(other: Stats) -> Stats:
	var stats_diff = Stats.new()
	stats_diff._level = _level - other._level
	stats_diff._experience = _experience - other._experience
	stats_diff._hp = _hp - other._hp
	stats_diff._mp = _mp - other._mp
	stats_diff._attack = _attack - other._attack
	stats_diff._defense = _defense - other._defense
	stats_diff._speed = _speed - other._speed
	stats_diff._agility = _agility - other._agility
	stats_diff._luck = _luck - other._luck
	return stats_diff
