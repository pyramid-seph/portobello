extends Node2D

signal all_waves_completed
signal wave_completed(wave_index)
signal wave_started(wave_index)


const MAX_CONCURRENT_ENEMIES: int = 10

@export var waves_script: Script

@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var scene_tree := get_tree()

var _waves_descriptor: LevelWaves
var _spawned_enemies_count: int = 0
var _enemies_on_screen: int = 0
var _is_canceled: bool = false


func _ready() -> void:
	_waves_descriptor = waves_script.new() as LevelWaves


func start(world: Node2D) -> void:
	_is_canceled = false
	
	if world == null:
		print("Completing wave because start_wave requires world cannot be null.")
		emit_signal("all_waves_completed")
		return
	
	var wave_index = -1
	for wave in _waves_descriptor._get_waves():
		_spawned_enemies_count = 0
		_enemies_on_screen = 0
		wave_index += 1
		
		emit_signal("wave_started", wave_index)
		
		await scene_tree.create_timer(wave.time_between_spawns, false).timeout
		while (_spawned_enemies_count < wave.enemy_count and not _is_canceled):
			if _enemies_on_screen >= MAX_CONCURRENT_ENEMIES:
				await scene_tree.create_timer(Utils.FRAME_TIME, false).timeout
				continue
			
			var new_enemy = _waves_descriptor._get_enemy_scene().instantiate()
			var initial_move_state: InitialMoveState = wave.get_initial_move_state_func.call(screen_size)
			new_enemy.global_position = initial_move_state.position
			new_enemy.movement_pattern = initial_move_state.movement_pattern
			new_enemy.tree_exited.connect(_on_Enemy_tree_exited)
			
			world.add_child(new_enemy)
			
			_enemies_on_screen += 1
			_spawned_enemies_count += 1
			
			await scene_tree.create_timer(wave.time_between_spawns, false).timeout
		
		while (_enemies_on_screen > 0 and not _is_canceled):
			await scene_tree.create_timer(Utils.FRAME_TIME, false).timeout
		
		await scene_tree.create_timer(wave.time_between_waves, false).timeout
		
		emit_signal("wave_completed", wave_index)
	
	if not _is_canceled:
		emit_signal("all_waves_completed")


func cancel_wave() -> void:
	_is_canceled = true


func _on_Enemy_tree_exited() -> void:
	if _is_canceled:
		return
	
	_enemies_on_screen = maxi(_enemies_on_screen - 1, 0)
