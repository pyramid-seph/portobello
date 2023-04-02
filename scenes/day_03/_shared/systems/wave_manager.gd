class_name WaveManager
extends Node2D


signal all_waves_completed
signal wave_completed(wave_index)
signal wave_started(wave_index)

const MAX_CONCURRENT_ENEMIES: int = 10

@export var WavesScript: Script

var _waves_descriptor: LevelWaves
var _spawned_enemies_count: int = 0
var _enemies_on_screen: int = 0
var _is_canceled: bool = false

@onready var _screen_size: Vector2 = get_viewport_rect().size
@onready var _timer := $Timer as Timer


func _ready() -> void:
	_waves_descriptor = WavesScript.new() as LevelWaves


func start(world: Node2D, player: Day03Player) -> void:
	_is_canceled = false
	
	if world == null:
		print("Completing wave because world cannot be null.")
		all_waves_completed.emit()
		return
	
	if player == null:
		print("Completing wave because player cannot be null.")
		all_waves_completed.emit()
		return
	
	var wave_index = -1
	for wave in _waves_descriptor.get_waves():
		var wave_enemy_index = 0
		var wave_memo = {}
		_spawned_enemies_count = 0
		_enemies_on_screen = 0
		wave_index += 1
		
		wave_started.emit(wave_index)
		
		_timer.start(wave.time_between_spawns)
		await _timer.timeout
		while _spawned_enemies_count < wave.enemy_count and not _is_canceled:
			if _enemies_on_screen >= MAX_CONCURRENT_ENEMIES:
				_timer.start(Utils.FRAME_TIME)
				await _timer.timeout
				continue
			
			var enemy = wave.Enemy.instantiate()
			var movement = wave.calculate_pattern.call(
				wave_enemy_index,
				player.global_position,
				_screen_size,
				wave_memo
			)
			enemy.global_position = movement.initial_global_position			
			enemy.movement_pattern = movement.pattern
			enemy.tree_exited.connect(_on_Enemy_tree_exited, CONNECT_ONE_SHOT)
			world.add_child(enemy)
			
			_enemies_on_screen += 1
			_spawned_enemies_count += 1
			wave_enemy_index += 1
			
			_timer.start(wave.time_between_spawns)
			await _timer.timeout
		
		while _enemies_on_screen > 0 and not _is_canceled:
			_timer.start(Utils.FRAME_TIME)
			await _timer.timeout
		
		_timer.start(wave.time_between_waves)
		await _timer.timeout
		
		wave_completed.emit(wave_index)
		
	if not _is_canceled:
		all_waves_completed.emit()


func cancel_wave() -> void:
	_is_canceled = true


func _on_Enemy_tree_exited() -> void:
	if _is_canceled:
		return
	_enemies_on_screen = maxi(_enemies_on_screen - 1, 0)
