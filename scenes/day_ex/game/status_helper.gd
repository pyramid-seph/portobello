class_name StatusHelper
extends Node


signal status_changed(old_value: int, new_value: int)

enum Status {
	NORMAL = 0,
	POISON = 1,
	CHARMED = 2,
	ATK_BUFF = 4,
	ATK_DEBUFF = 8,
	DEF_BUFF = 16,
	DEF_DEBUFF = 32,
	SPD_BUFF = 64,
	SPD_DEBUFF = 128,
}

var _statuses: int
var _refresh_status: bool
var _stats_manager: StatsManager
var _status_manager: StatusManager


func _process(_delta: float) -> void:
	if _refresh_status:
		_refresh_status = false
		_update_statuses()


func setup(stats_manager: StatsManager, status_manager: StatusManager) -> void:
	_stats_manager = stats_manager
	_status_manager = status_manager
	_stats_manager.buffed.connect(_on_status_effects_or_stats_changed)
	_status_manager.status_changed.connect(_on_status_effects_or_stats_changed)
	_refresh_status = true


func get_statuses() -> int:
	return _statuses


func _update_statuses() -> void:
	if not _stats_manager and not _status_manager:
		return
	
	var old_statuses: int = _statuses
	_set_status_bit(Status.POISON, _status_manager.is_poisoned())
	_set_status_bit(Status.CHARMED, _status_manager.is_charmed())
	_set_status_bit(Status.ATK_BUFF, _stats_manager.get_atk_buffs() > 0)
	_set_status_bit(Status.ATK_DEBUFF, _stats_manager.get_atk_buffs() < 0)
	_set_status_bit(Status.DEF_BUFF, _stats_manager.get_def_buffs() > 0)
	_set_status_bit(Status.DEF_DEBUFF, _stats_manager.get_def_buffs() < 0)
	_set_status_bit(Status.SPD_BUFF, _stats_manager.get_spd_buffs() > 0)
	_set_status_bit(Status.SPD_DEBUFF, _stats_manager.get_spd_buffs() < 0)
	if _statuses != old_statuses:
		status_changed.emit(old_statuses, _statuses)


func _set_status_bit(status_flag: Status, is_active: bool) -> void:
	if is_active:
		_statuses |= status_flag
	elif _statuses & status_flag:
		_statuses ^= status_flag


func _on_status_effects_or_stats_changed() -> void:
	_refresh_status = true
