extends Node


const MAX_BUFF: int = 7
const MAX_DEBUFF: int = -7

var _fighter_data: FighterData
var _base_stats := Stats.new()
var _curr_level: int:
	set(value):
		_curr_level = maxi(value, 1)
var _curr_exp: int:
	set(value):
		_curr_exp = maxi(value, 0)
var _atk_buffs: int:
	set(value):
		_atk_buffs = clampi(value, MAX_DEBUFF, MAX_BUFF)
var _def_buffs: int:
	set(value):
		_def_buffs = clampi(value, MAX_DEBUFF, MAX_BUFF)
var _spd_buffs: int:
	set(value):
		_spd_buffs = clampi(value, MAX_DEBUFF, MAX_BUFF)


func setup(fighter_data: FighterData, experience: int = 0) -> void:
	if not fighter_data or experience < 0:
		print("StatsManager :> setup NOT executed: invalid parameters.")
		return
	
	_fighter_data = fighter_data
	gain_experience(experience)


## Sets this fighter stats to the requested level.
## Be aware that this also sets the current experience to the required 
## experience to reach that level.
## 
## Calling this method does NOT reset buffs.
##
## Does nothing when level is less than 1 or this fighter has not been set up.
## If the level requested is greater than the maximum level posible, 
## resets this fighter stats to the max level.
##
## See also: [code]gain_experience(experience: int)[/code]
func reset_stats_to_level(level: int) -> void:
	if not _fighter_data or level < 1:
		print("StatsManager :> reset_level NOT executed: invalid parameters.")
		return Stats.new()
	
	_base_stats = _fighter_data.get_base_stats_for_level(level)
	_curr_exp = _base_stats.experience
	_curr_level = _base_stats.level


func get_current_level() -> int:
	return _curr_level


func get_current_experience() -> int:
	return _curr_exp


func gain_experience(experience: int) -> Stats:
	if not _fighter_data or experience < 0:
		print("StatsManager :> gain_experience NOT executed: invalid parameters.")
		return Stats.new()
	
	var min_experience: int = _fighter_data.get_min_experience()
	var max_experience: int = _fighter_data.get_max_experience()
	_curr_exp = clampi(_curr_exp + experience, min_experience, max_experience)
	_curr_level = _fighter_data.get_level_by_experience(_curr_exp)
	var old_stats: Stats = _base_stats
	_base_stats = _fighter_data.get_base_stats_for_level(_curr_level)
	return _base_stats.diff(old_stats)


#region StatsGetters
func get_max_hp() -> int:
	return _base_stats.get_max_hp()


func get_max_mp() -> int:
	return _base_stats.get_max_mp()


func get_atk() -> int:
	return maxi(1, _base_stats.get_atk() + _atk_buffs)


func get_def() -> int:
	return maxi(1, _base_stats.get_def() + _def_buffs)


func get_spd() -> int:
	return maxi(1, _base_stats.get_spd() + _spd_buffs)


func get_agi() -> int:
	return _base_stats.get_agi()


func get_lck() -> int:
	return _base_stats.get_lck()
#endregion


#region BuffsGetters
func get_atk_buffs() -> int:
	return _atk_buffs


func get_def_buffs() -> int:
	return _def_buffs


func get_spd_buffs() -> int:
	return _spd_buffs


func is_buffed_or_debuffed() -> bool:
	return _atk_buffs != 0 or _def_buffs != 0 or _spd_buffs != 0
#endregion


#region BuffsSetters
func buff_atk(points: int) -> void:
	_atk_buffs += points


func buff_def(points: int) -> void:
	_def_buffs += points


func buff_speed(points: int) -> void:
	_spd_buffs += points
#endregion


#region BuffsReseters
func reset_atk_buffs() -> void:
	_atk_buffs = 0


func reset_def_buffs() -> void:
	_def_buffs = 0


func reset_spd_buffs() -> void:
	_spd_buffs = 0


func reset_buffs() -> void:
	reset_atk_buffs()
	reset_def_buffs()
	reset_spd_buffs()
#endregion