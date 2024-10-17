class_name WaveManager
extends Node2D


signal all_waves_completed
signal wave_completed(wave_index)
signal wave_started(wave_index)

const MAX_CONCURRENT_ENEMIES: int = 10

var _waves_descriptor: LevelWaves
var _spawned_enemies_count: int = 0
var _enemies_on_screen: int = 0
var _is_stopped: bool = true
var _world: Node2D
var _player: Day03Player
var _wave_index: int = -1
var _wave_memo: Dictionary = {}

@onready var _screen_size: Vector2 = get_viewport_rect().size
@onready var _wave_finished_check_timer: Timer = $WaveFinishedCheckTimer
@onready var _wave_delay_timer: Timer = $WaveDelayTimer
@onready var _spawn_delay_timer: Timer = $SpawnDelayTimer


func _ready() -> void:
	_waves_descriptor = Utils.first_or_null(get_children(), func(child): 
		return child as LevelWaves != null
	)


func _exit_tree() -> void:
	Log.d(" \n========\n ")


func start(world: Node2D, player: Day03Player) -> void:
	if not _is_stopped:
		return
	
	if not _pre_start_checks_passed(world, player):
		stop()
		all_waves_completed.emit()
		return
	
	_wave_index = -1
	_is_stopped = false
	_world = world
	_player =  player
	_start_next_wave()


func stop() -> void:
	_is_stopped = true
	_world = null
	_player = null
	_wave_delay_timer.stop()
	_spawn_delay_timer.stop()
	_wave_finished_check_timer.stop()
	Log.d("Wave manager has been stopped")


func _get_current_wave() -> Wave:
	var waves: Array[Wave] = _waves_descriptor.get_waves()
	return null if _wave_index < 0 else waves[_wave_index]


func _start_next_wave() -> void:
	if _is_stopped:
		return

	_wave_memo.clear()
	_spawned_enemies_count = 0
	_enemies_on_screen = 0
	_wave_index += 1
	var wave: Wave = _get_current_wave()
	_spawn_delay_timer.start(wave.time_between_spawns)
	wave_started.emit(_wave_index)
	Log.d(">>> Wave started: %s" % _wave_index)


func _pre_start_checks_passed(world: Node2D, player: Day03Player) -> bool:
	if world == null:
		Log.d("Completing _wave phase  because world cannot be null.")
		return false
	
	if player == null:
		Log.d("Completing _wave phase  because player cannot be null.")
		return false
	
	if _waves_descriptor == null:
		Log.d("Completing _wave phase because level waves descriptor cannot be null.")
		return false
	
	return true


func _spawn_enemy() -> void:
	var wave: Wave = _get_current_wave()
	var enemy = wave.Enemy.instantiate()
	
	var movement = wave.calculate_pattern.call(
		_spawned_enemies_count,
		_player.global_position,
		_screen_size,
		_wave_memo
	)
	enemy.global_position = movement.initial_global_position
	enemy.movement_pattern = movement.pattern
	enemy.tree_exited.connect(_on_enemy_tree_exited, CONNECT_ONE_SHOT)
	_world.add_child(enemy)
	
	_enemies_on_screen += 1
	_spawned_enemies_count += 1


func _on_enemy_tree_exited() -> void:
	if not _is_stopped:
		_enemies_on_screen = maxi(_enemies_on_screen - 1, 0)


func _on_wave_finished_check_timer_timeout() -> void:
	if _is_stopped:
		return
	
	if _enemies_on_screen <= 0:
		var wave: Wave = _get_current_wave()
		_wave_delay_timer.start(wave.time_between_waves)
	else:
		_wave_finished_check_timer.start(Utils.FRAME_TIME)


func _on_spawn_delay_timer_timeout() -> void:
	if _is_stopped:
		return
	
	var wave: Wave = _get_current_wave()
	if _spawned_enemies_count >= wave.enemy_count:
		_on_wave_finished_check_timer_timeout()
		return
	
	if _enemies_on_screen >= MAX_CONCURRENT_ENEMIES:
		_spawn_delay_timer.start(Utils.FRAME_TIME)
		return
	
	_spawn_enemy()
	_spawn_delay_timer.start(wave.time_between_spawns)


func _on_wave_delay_timer_timeout() -> void:
	if _is_stopped:
		return
	
	Log.d("Spawns: %s" % _spawned_enemies_count)
	Log.d("<<< Wave completed: %s" % _wave_index)
	
	if _wave_index >= _waves_descriptor.get_waves().size() - 1:
		stop()
		Log.d("All waves completed")
		all_waves_completed.emit()
	else:
		wave_completed.emit(_wave_index)
		_start_next_wave()
