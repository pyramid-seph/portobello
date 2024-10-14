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
var _stats_manager: StatsManager
var _status_manager: StatusManager
var _status_update_enqueued: bool

@onready var _timer: Timer = $Timer


func setup(stats_manager: StatsManager, status_manager: StatusManager) -> void:
	if _stats_manager:
		Utils.safe_disconnect(
				_stats_manager.buffed, _on_status_or_stats_changed)
	if _status_manager:
		Utils.safe_disconnect(
				_status_manager.status_changed, _on_status_or_stats_changed)
	
	if not stats_manager or not status_manager:
		print("stats_manager and status manager cannot be null. Skipping setup.")
		return
	
	_stats_manager = stats_manager
	_status_manager = status_manager
	Utils.safe_connect(_stats_manager.buffed, _on_status_or_stats_changed)
	Utils.safe_connect(
			_status_manager.status_changed, _on_status_or_stats_changed)
	force_status_update()


func get_displayed_status() -> Status:
	return Status.values()[_shown_status_index]


func force_status_update() -> void:
	if not _stats_manager or not _stats_manager:
		print("Do not call force_status_update() before setup().")
		return
	
	var old_statuses: int = _statuses
	var old_statuses_is_single_or_normal: bool = _is_single_status_or_normal()
	
	_set_status_bit(Status.POISON, _status_manager.is_poisoned())
	_set_status_bit(Status.CHARMED, _status_manager.is_charmed())
	_set_status_bit(Status.ATK_BUFF, _stats_manager.get_atk_buffs() > 0)
	_set_status_bit(Status.ATK_DEBUFF, _stats_manager.get_atk_buffs() < 0)
	_set_status_bit(Status.DEF_BUFF, _stats_manager.get_def_buffs() > 0)
	_set_status_bit(Status.DEF_DEBUFF, _stats_manager.get_def_buffs() < 0)
	_set_status_bit(Status.SPD_BUFF, _stats_manager.get_spd_buffs() > 0)
	_set_status_bit(Status.SPD_DEBUFF, _stats_manager.get_spd_buffs() < 0)
	
	var is_displayed_status_active: bool = _statuses & get_displayed_status()
	if (old_statuses_is_single_or_normal and is_displayed_status_active) or \
			_statuses != old_statuses:
		_show_next_status()


func _enqueue_status_update() -> void:
	if not _status_update_enqueued:
		_status_update_enqueued = true
		
		var tree = get_tree()
		if not tree:
			return
			
		await tree.process_frame
		# I'm not sure if this "if" is needed but I'm adding it anyway in case 
		# this node is enqueued for destruction and it has an status
		# update queued on the same frame.
		if is_instance_valid(self):
			force_status_update()
			_status_update_enqueued = false


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


func _is_single_status_or_normal() -> bool:
	return _statuses & (_statuses - 1) == 0


func _show_next_status() -> void:
	_set_next_shown_status_index()
	if _is_single_status_or_normal():
		_timer.stop()
	else:
		_timer.start()
	displayed_status_changed.emit(get_displayed_status())


func _on_status_or_stats_changed() -> void:
	_enqueue_status_update()


func _on_timer_timeout() -> void:
	_show_next_status()
