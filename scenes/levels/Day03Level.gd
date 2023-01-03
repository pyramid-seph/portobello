extends Node
class_name Day03Level

signal level_state_changed(new_state)
signal pause_state_changed(new_state)

const START_DURATION: float = 1.6
const TIME_BETWEEN_REVIVALS: float = 1.2
const GAME_OVER_DURATION: float = 3.2

@export var player: PackedScene
@export var player_data: Day03PlayerData

@onready var world := $World
@onready var mega_gun_flash := $Interface/MegaGunFlash
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
	var player = _instantiate_player()
	player.is_input_enabled = false
	level_state = LevelState.STARTING
	await scene_tree.create_timer(START_DURATION, false).timeout
	level_state = LevelState.PLAYING
	player.is_input_enabled = true
	wave_manager.start(world)
	stamina_spawner.enable(world)
	power_up_spawner.enable(world)


func _instantiate_player() -> Node:
	var new_player = player.instantiate()
	new_player.position = player_start_position
	new_player.died.connect(_on_Player_died)
	new_player.mega_gun_shot.connect(mega_gun_flash._on_Player_mega_gun_shot)
	world.add_child(new_player)
	return new_player


func _game_over() -> void:
	level_state = LevelState.GAME_OVER
	wave_manager.cancel_wave()
	stamina_spawner.disable()
	power_up_spawner.disable()
	await scene_tree.create_timer(GAME_OVER_DURATION).timeout
	scene_tree.quit()


func _input(event: InputEvent) -> void:
	if level_state == LevelState.PLAYING and event.is_action_pressed("pause"):
		scene_tree.paused = not scene_tree.paused
		pause_state_changed.emit(scene_tree.paused)


func _on_Player_died(remaining_lives: int) -> void:
	if remaining_lives == 0:
		_game_over()
	else:
		await scene_tree.create_timer(TIME_BETWEEN_REVIVALS, false).timeout
		_instantiate_player()


func _on_wave_manager_wave_completed(wave_index: int) -> void:
	print("WAVE %s COMPLETED!" % str(wave_index))


func _on_wave_manager_all_waves_completed() -> void:
	stamina_spawner.disable()
	power_up_spawner.disable()


func _on_wave_manager_wave_started(wave_index: int) -> void:
	print("WAVE %s STARTED!" % str(wave_index))
