extends Node


signal displayed_status_changed(new_status: Status)

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
var _shown_status_index: int


@onready var _timer: Timer = $Timer


func get_displayed_status() -> Status:
	return Status.values()[_shown_status_index]


func update_status(stats_manager: StatsManager, status_manager: StatusManager) -> void:
	var displayed_status: int = get_displayed_status()
	_set_status_bit(Status.POISON, status_manager.is_poisoned())
	_set_status_bit(Status.CHARMED, status_manager.is_charmed())
	_set_status_bit(Status.ATK_BUFF, stats_manager.get_atk_buffs() > 0)
	_set_status_bit(Status.ATK_DEBUFF, stats_manager.get_atk_buffs() < 0)
	_set_status_bit(Status.DEF_BUFF, stats_manager.get_def_buffs() > 0)
	_set_status_bit(Status.DEF_DEBUFF, stats_manager.get_def_buffs() < 0)
	_set_status_bit(Status.SPD_BUFF, stats_manager.get_spd_buffs() > 0)
	_set_status_bit(Status.SPD_DEBUFF, stats_manager.get_spd_buffs() < 0)
	if not _statuses & displayed_status:
		_show_next_status()


func _set_status_bit(status_flag: Status, is_active: bool) -> void:
	if is_active:
		_statuses |= status_flag
	elif _statuses & status_flag:
		_statuses ^= status_flag


func _set_next_shown_status_index() -> void:
	if _statuses == Status.NORMAL:
		_shown_status_index = 0
		return
	
	# Find the next active status bit
	var statuses_count: int = Status.size()
	var status_bits: Array = Status.values()
	var initial_idx: int = _shown_status_index
	_shown_status_index = wrapi(_shown_status_index + 1, 0, statuses_count)
	while _shown_status_index != initial_idx:
		var candidate_status: int = status_bits[_shown_status_index]
		if _statuses & candidate_status:
			break
		_shown_status_index = wrapi(_shown_status_index + 1, 0, statuses_count)


func _show_next_status() -> void:
	_set_next_shown_status_index()
	if _statuses & (_statuses - 1) == 0: # is single status or normal?
		_timer.stop()
	else:
		_timer.start()
	displayed_status_changed.emit(get_displayed_status())


func _on_timer_timeout() -> void:
	_show_next_status()
