extends Node2D

signal wave_completed


const MAX_CONCURRENT: int = 10

export(PackedScene) var enemy = preload("res://scenes/characters/enemy/Drone.tscn")
export var start_delay: float = 3.0

onready var screen_size := get_viewport_rect().size
onready var scene_tree := get_tree()

var _world: Node2D = null
var _enemy_wave_count: int = 50
var _spawned_enemies_count: int = 0
var _concurrent_enemies_count: int = 0
var _remaining_enemies_count: int = 0
var _is_canceled: bool = false
var _current_wave = 0
var _delay_between_spawns: float = 0.8


func start(world: Node2D) -> void:
	print("start_wave")
	_world = world
	_is_canceled = false
	_spawned_enemies_count = 0
	_concurrent_enemies_count = 0
	_current_wave = 0
	_remaining_enemies_count = _enemy_wave_count
	
	if world == null:
		print("Completing wave because start_wave requires world cannot be null.")
		emit_signal("wave_completed")
		return
	
	##################################################################################
	
	_enemy_wave_count = 50
	_spawned_enemies_count = 0
	_delay_between_spawns = 0.4
	
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		#if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		#	print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		#	continue
	
		print("Spawning!")
		var new_enemy = enemy.instance()
		
		new_enemy.movement_pattern = Drone.MovementPattern.VERTICAL_DOWN
		
		var initial_pos := Vector2()
		initial_pos.x = randi() % int(screen_size.x - 40) + 10
		initial_pos.y = 3
		new_enemy.global_position = initial_pos
		
		new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		
		_world.add_child(new_enemy)
		
		_concurrent_enemies_count += 1
		_spawned_enemies_count += 1
		
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")
	
	##################################################################################
	
	_enemy_wave_count = 50
	_spawned_enemies_count = 0
	_delay_between_spawns = 0.8
	
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		#if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		#	print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		#	continue
	
		print("Spawning!")
		var new_enemy = enemy.instance()
		
		if randi() % 2 == 0:
			 new_enemy.movement_pattern = Drone.MovementPattern.HORIZONTAL_RIGHT
		else:
			new_enemy.movement_pattern = Drone.MovementPattern.HORIZONTAL_LEFT
		
		var initial_pos := Vector2()
		if new_enemy.movement_pattern == Drone.MovementPattern.HORIZONTAL_RIGHT:
			initial_pos.x = 0
		else:
			initial_pos.x = screen_size.x
		initial_pos.y = randi() % int(screen_size.y - 10) + 3
		new_enemy.global_position = initial_pos

		new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		
		_world.add_child(new_enemy)
		
		_concurrent_enemies_count += 1
		_spawned_enemies_count += 1
		
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")
	
	##################################################################################
	
	_enemy_wave_count = 50
	_spawned_enemies_count = 0
	_delay_between_spawns = 0.8
	
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		#if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		#	print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		#	continue
	
		print("Spawning!")
		var new_enemy = enemy.instance()
		
		new_enemy.movement_pattern = Drone.MovementPattern.HORIZONTAL_RIGHT
		
		var initial_pos := Vector2()
		initial_pos.x = 0
		initial_pos.y = randi() % int(screen_size.y - 10) + 3
		new_enemy.global_position = initial_pos
		
		new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		
		_world.add_child(new_enemy)
		
		_concurrent_enemies_count += 1
		_spawned_enemies_count += 1
		
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")
	
	##################################################################################
	
	_enemy_wave_count = 35
	_spawned_enemies_count = 0
	_delay_between_spawns = 1.2
	
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		#if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		#	print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		#	continue
	
		print("Spawning!")
		var new_enemy = enemy.instance()
		
		if randi() % 2 == 0:
			 new_enemy.movement_pattern = Drone.MovementPattern.VERTICAL_DOWN
		else:
			new_enemy.movement_pattern = Drone.MovementPattern.VERTICAL_UP
		
		var initial_pos := Vector2()
		initial_pos.x = randi() % int(screen_size.x - 40) + 10
		if new_enemy.movement_pattern == Drone.MovementPattern.VERTICAL_DOWN:
			initial_pos.y = 0
		else:
			initial_pos.y = screen_size.y - 6

		new_enemy.global_position = initial_pos

		new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		
		_world.add_child(new_enemy)
		
		_concurrent_enemies_count += 1
		_spawned_enemies_count += 1
		
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")
	
	##################################################################################
	
	_enemy_wave_count = 35
	_spawned_enemies_count = 0
	_delay_between_spawns = 0.8
	
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		#if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		#	print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		#	continue
	
		print("Spawning!")
		var new_enemy = enemy.instance()
		
		new_enemy.movement_pattern = Drone.MovementPattern.HORIZONTAL_LEFT
		
		var initial_pos := Vector2()
		initial_pos.x = screen_size.x
		initial_pos.y = randi() % int(screen_size.y - 10) + 3
		new_enemy.global_position = initial_pos
		
		new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		
		_world.add_child(new_enemy)
		
		_concurrent_enemies_count += 1
		_spawned_enemies_count += 1
		
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")
	
	##################################################################################
	
	_enemy_wave_count = 20
	_spawned_enemies_count = 0
	_delay_between_spawns = 1.2
	
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		#if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		#	print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		#	continue
	
		print("Spawning!")
		var new_enemy = enemy.instance()
		
		new_enemy.movement_pattern = Drone.MovementPattern.SQUARE_UP
		
		var initial_pos := Vector2()
		if randi() % 2 == 0:
			initial_pos.x = 0
		else:
			initial_pos.x = screen_size.x
		initial_pos.y = screen_size.y - 15
		new_enemy.global_position = initial_pos
		
		new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		
		_world.add_child(new_enemy)
		
		_concurrent_enemies_count += 1
		_spawned_enemies_count += 1
		
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")
	
	##################################################################################
	
	_enemy_wave_count = 20
	_spawned_enemies_count = 0
	_delay_between_spawns = 1.2
	
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		#if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		#	print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		#	continue
	
		print("Spawning!")
		var new_enemy = enemy.instance()
		
		new_enemy.movement_pattern = Drone.MovementPattern.ZIG_ZAG_DOWN
		
		var initial_pos := Vector2()
		match  randi() % 4:
			0, 3:
				initial_pos.x = randi() % int(screen_size.x - 20) + 10
				initial_pos.y = 3
			1:
				initial_pos.x = screen_size.x - 16
				initial_pos.y = randi() % 40 + 10
			2:
				initial_pos.x = 16
				initial_pos.y = randi() % 40 + 10
		
		new_enemy.global_position = initial_pos
		
		new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
		
		_world.add_child(new_enemy)
		
		_concurrent_enemies_count += 1
		_spawned_enemies_count += 1
		
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")


func stop() -> void:
	_is_canceled = true
	_world = null


func start_wave(world: Node2D) -> void:
	_world = world
	_is_canceled = false
	_spawned_enemies_count = 0
	_concurrent_enemies_count = 0
	_remaining_enemies_count = _enemy_wave_count
	
	if world == null:
		print("Completing wave because start_wave requires world cannot be null.")
		emit_signal("wave_completed")
		return
	
	yield(scene_tree.create_timer(start_delay, false), "timeout")
	_spawn_wave()
	#connect("timeout", scene_tree.create_timer(start_delay, true), "_on_start_delay_completed", [], CONNECT_ONESHOT)


func cancel_wave() -> void:
	_is_canceled = true
	_world = null


func _on_start_delay_completed() -> void:
	_spawn_wave()


func _spawn_wave() -> void:
	while (_spawned_enemies_count < _enemy_wave_count and not _is_canceled):
		_instantiate_enemy()
		yield(scene_tree.create_timer(_delay_between_spawns, false), "timeout")


func _instantiate_enemy():
	if _concurrent_enemies_count == MAX_CONCURRENT or _is_canceled:
		print("Max concurrent or canceled when trying spawning an enemy. Retrying spawn later")
		return null
	
	print("Spawning!")
	var new_enemy: Drone = enemy.instance()
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 40) + 10
	initial_pos.y = 3
	new_enemy.global_position = initial_pos
	new_enemy.connect("tree_exited", self, "_on_Enemy_tree_exited")
	_world.add_child(new_enemy)
	_concurrent_enemies_count += 1
	_spawned_enemies_count += 1
	return new_enemy


func _on_Enemy_tree_exited() -> void:
	if _is_canceled:
		return
	
	_concurrent_enemies_count = int(max(_concurrent_enemies_count - 1, 0))
	_remaining_enemies_count = int(max(_remaining_enemies_count - 1, 0))
	print("Enemy tree exited. Remaining enemies: %s" % str(_remaining_enemies_count))
	if _remaining_enemies_count == 0:
		pass#emit_signal("wave_completed")
	
