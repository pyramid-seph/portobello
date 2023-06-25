extends Node


const MAX_CONCURRENT_BULLETS: int = 10

@export var cooldown_sec: float = 1

@export var _world: Node2D
@export var _player: Day03Player

var _disabled: bool = false

@onready var _cooldown_timer := $CooldownTimer as Timer


func enable(immediate: bool = false) -> void:
	_disabled = false
	if immediate: 
		_start_cooldown()


func disable() -> void:
	_disabled = true
	_stop_cooldown()


func _start_cooldown(time: float = cooldown_sec) -> void:
	if not _disabled: _cooldown_timer.start(time)


func _stop_cooldown() -> void:
	_cooldown_timer.stop()


func _on_wave_manager_wave_started(wave_index: int) -> void:
	if wave_index < 8:
		_start_cooldown()


func _on_wave_manager_wave_completed(_wave_index: int) -> void:
	_stop_cooldown()


func _on_wave_manager_all_waves_completed() -> void:
	disable()


func _fire(ufo: Ufo) -> bool:
	var fired: bool = false
	var player_pos = _player.global_position
	var ufo_pos = ufo.global_position
	var offset = ufo.get_width() / 2.0
	if player_pos.x >= ufo_pos.x - offset && player_pos.x <= ufo_pos.x + offset:
		if player_pos.y <= ufo_pos.y:
			ufo.fire_top_gun()
		else:
			ufo.fire_bottom_gun()
		fired = true
	return fired


func _on_cooldown_timer_timeout() -> void:
	if _disabled:
		return
	
	if _player.is_dead():
		_start_cooldown(Utils.FRAME_TIME)
		return
	
	var enemy_bullet_count = SceneTreeUtils.get_item_count_in_group("enemy_bullet")
	if enemy_bullet_count >= MAX_CONCURRENT_BULLETS:
		_start_cooldown(Utils.FRAME_TIME)
		return
	
	var candidates = Utils.children_in_group(_world, "ufos")
	if candidates.is_empty():
		_start_cooldown(Utils.FRAME_TIME)
		return
	
	var shot: bool = false
	for ufo in candidates:
		if not ufo.is_dead() and _fire(ufo):
			_start_cooldown()
			shot = true
			break
	if not shot:
		_start_cooldown(Utils.FRAME_TIME)
