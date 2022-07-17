extends Node2D

signal all_waves_completed
signal wave_completed(wave_index)
signal wave_started(wave_index)


const MAX_CONCURRENT_ENEMIES: int = 10

onready var screen_size := get_viewport_rect().size
onready var scene_tree := get_tree()

var _wave_descriptor
var _spawned_enemies_count: int = 0
var _enemies_on_screen: int = 0
var _is_canceled: bool = false


func _ready() -> void:
	_wave_descriptor = Level0Waves.new()


func start(world: Node2D) -> void:
	_is_canceled = false
	
	if world == null:
		print("Completing wave because start_wave requires world cannot be null.")
		emit_signal("all_waves_completed")
		return
	
	var wave_index = -1
	for wave in _wave_descriptor.waves:
		_spawned_enemies_count = 0
		_enemies_on_screen = 0
		wave_index += 1
		
		emit_signal("wave_started", wave_index)
		
		yield(scene_tree.create_timer(wave["time_between_spawns"], false), "timeout")
		while (_spawned_enemies_count < wave["enemy_count"] and not _is_canceled):
			if _enemies_on_screen >= MAX_CONCURRENT_ENEMIES:
				yield(scene_tree, "idle_frame")
				continue
			
			var new_enemy = _wave_descriptor._get_enemy().instance()
			new_enemy.movement_pattern = wave["movement_pattern"].call_func()
			new_enemy.global_position = wave["initial_position"].call_func(new_enemy.movement_pattern, screen_size)
			new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
			
			world.add_child(new_enemy)
			
			_enemies_on_screen += 1
			_spawned_enemies_count += 1
			
			yield(scene_tree.create_timer(wave["time_between_spawns"], false), "timeout")
		
		while (_enemies_on_screen > 0 and not _is_canceled):
			yield(scene_tree, "idle_frame")
		
		emit_signal("wave_completed", wave_index)
	
	if not _is_canceled:
		emit_signal("all_waves_completed")


func _on_Enemy_tree_exited() -> void:
	if _is_canceled:
		return
	
	_enemies_on_screen = int(max(_enemies_on_screen - 1, 0))
	print("_enemies_on_screen: %s" % str(_enemies_on_screen))
