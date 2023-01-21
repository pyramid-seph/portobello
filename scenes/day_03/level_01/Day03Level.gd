extends Node
class_name Day03Level

signal level_state_changed(new_state)
signal pause_state_changed(new_state)

const START_DURATION: float = 1.6
const TIME_BETWEEN_REVIVALS: float = 1.2
const GAME_OVER_DURATION: float = 3.2

@export var boss_scene: PackedScene
@export var player_scene: PackedScene
@export var player_data: Day03PlayerData

var _player: Node2D
var _boss: Node2D

@onready var world := $World
@onready var world_background := $World/Day03Bg
@onready var player_start_position = $World/StartPosition.position
@onready var wave_manager := $WaveManager
@onready var stamina_spawner := $StaminaSpawner
@onready var power_up_spawner := $PowerUpSpawner
@onready var scene_tree = get_tree()


enum LevelState { STARTING, PLAYING, GAME_OVER }

var level_state: int = LevelState.STARTING :
	get:
		return level_state
	set(mod_value):
		level_state = mod_value
		level_state_changed.emit(level_state)


func _ready() -> void:
	_player = _instantiate_player()
	_player.is_input_enabled = false
	level_state = LevelState.STARTING
	await scene_tree.create_timer(START_DURATION, false).timeout
	level_state = LevelState.PLAYING
	_player.is_input_enabled = true
	wave_manager.start(world)
	stamina_spawner.enable(world)
	power_up_spawner.enable(world)


func _input(event: InputEvent) -> void:
	if level_state == LevelState.PLAYING and event.is_action_pressed("pause"):
		scene_tree.paused = not scene_tree.paused
		pause_state_changed.emit(scene_tree.paused)


func _instantiate_boss() -> Node:
	var boss = boss_scene.instantiate()
	boss.global_position.y = 3
	boss.global_position.x =  world.get_viewport_rect().size.x / 2 - 30
	world.add_child(boss)
	return boss


func _instantiate_player() -> Node:
	var new_player = player_scene.instantiate()
	new_player.position = player_start_position
	new_player.died.connect(_on_Player_died)
	new_player.mega_gun_shot.connect(world_background._on_mega_gun_shot)
	world.add_child(new_player)
	return new_player


func _game_over() -> void:
	level_state = LevelState.GAME_OVER
	wave_manager.cancel_wave()
	stamina_spawner.disable()
	power_up_spawner.disable()
	await scene_tree.create_timer(GAME_OVER_DURATION).timeout
	scene_tree.quit()


func _on_Player_died(remaining_lives: int) -> void:
	if remaining_lives > 0:
		await scene_tree.create_timer(TIME_BETWEEN_REVIVALS, false).timeout
		_player.revive()
		_player.position = player_start_position
	else:
		_game_over()


func _on_wave_manager_wave_completed(wave_index: int) -> void:
	print("WAVE %s COMPLETED!" % str(wave_index))


func _on_wave_manager_all_waves_completed() -> void:
	Utils.queue_free_group(world, "bullets")
	Utils.queue_free_group(world, "pickups")
	stamina_spawner.disable()
	stamina_spawner.cooldown = Utils.FRAME_TIME
	stamina_spawner.random = false
	stamina_spawner.enable(world)
	power_up_spawner.disable()
	_player.reset_power_up()
	_player.reset_stamina()
	_player.start_timed_invincibility()
	_player.position = player_start_position
	_boss = _instantiate_boss()
	_boss.dead.connect(_on_boss_dead)
	_boss.almost_dead.connect(_on_boss_almost_dead)
	_boss.start()


func _on_wave_manager_wave_started(wave_index: int) -> void:
	print("WAVE %s STARTED!" % str(wave_index))


func _on_boss_dead() -> void:
	stamina_spawner.disable()
	power_up_spawner.disable()
	_player.stop_stamina_lose(true)
	print("YOU WIN!!!!!!!!!!!!!")


func _on_boss_almost_dead() -> void:
	print("ALMOST DEAD!!")
	power_up_spawner.enable(world)
	power_up_spawner.cooldown = Utils.FRAME_TIME
	power_up_spawner.random = false
