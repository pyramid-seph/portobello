extends Node


const COOLDOWN_SECONDS: float = 0.8
const MAX_CONCURRENT_BULLETS: int = 10

onready var cooldown_timer := $CooldownTimer

var _disabled: bool = false


func enable(immediate: bool = false) -> void:
	_disabled = false
	if immediate:
		_start_cooldown()


func disable() -> void:
	_disabled = true
	_stop_cooldown()


func _start_cooldown(time: float = COOLDOWN_SECONDS) -> void:
	if not _disabled:
		cooldown_timer.start(time)


func _stop_cooldown() -> void:
	cooldown_timer.stop()


func _on_WaveManager_wave_started(_wave_index) -> void:
	_start_cooldown()


func _on_WaveManager_wave_completed(_wave_index) -> void:
	_stop_cooldown()


func _on_WaveManager_all_waves_completed() -> void:
	disable()


func _on_CooldownTimer_timeout() -> void:
	if _disabled:
		return

	var enemy_bullet_count = Utils.get_item_count_in_group("enemy_bullet")
	if enemy_bullet_count >= MAX_CONCURRENT_BULLETS:
		_start_cooldown(Utils.FRAME_TIME)
		return

	var drone = Utils.rand_item_in_group("drone")
	if drone:
		drone.shoot()
		_start_cooldown()
	else:
		_start_cooldown(Utils.FRAME_TIME)
