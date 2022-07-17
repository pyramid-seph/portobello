extends Node2D

signal all_waves_completed
signal wave_completed(wave_index)
signal wave_started(wave_index)


onready var screen_size := get_viewport_rect().size
onready var scene_tree := get_tree()

var _waves : Array = []
var _spawned_enemies_count: int = 0
var _enemies_on_screen: int = 0
var _is_canceled: bool = false


func _ready() -> void:
	_waves.clear()
	_waves.push_back(Level0Wave0.new())
	_waves.push_back(Level0Wave1.new())
	
	
func start(world: Node2D) -> void:
	_is_canceled = false
	
	if world == null:
		print("Completing wave because start_wave requires world cannot be null.")
		emit_signal("all_waves_completed")
		return
	
	var wave_index = -1
	for wave in _waves:
		_spawned_enemies_count = 0
		_enemies_on_screen = 0
		wave_index += 1
		
		emit_signal("wave_started", wave_index)
		
		yield(scene_tree.create_timer(wave._get_time_between_spawns(), false), "timeout")
		while (_spawned_enemies_count < wave._get_enemy_count() and not _is_canceled):
			if _enemies_on_screen >= wave._get_max_concurrent_enemies():
				yield(scene_tree, "idle_frame")
				continue
			
			var new_enemy = wave._get_enemy().instance()
			new_enemy.movement_pattern = wave._get_movement_pattern()
			new_enemy.global_position = wave._get_initial_position(new_enemy.movement_pattern, screen_size)
			new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
			
			world.add_child(new_enemy)
			
			_enemies_on_screen += 1
			_spawned_enemies_count += 1
			
			yield(scene_tree.create_timer(wave._get_time_between_spawns(), false), "timeout")
		
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
