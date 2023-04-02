class_name Day03Level
extends Node


signal level_state_changed(new_state)
signal pause_state_changed(new_state)
signal waves_completed

enum LevelState { STARTING, PLAYING, GAME_OVER, LEVEL_COMPLETE }

const START_DURATION: float = 1.6
const TIME_BETWEEN_REVIVALS: float = 1.2
const GAME_OVER_DURATION: float = 3.2
const RESULTS_SCREEN_DELAY: float = 10.45

@export var Boss: PackedScene
@export var Player: PackedScene
@export var _player_data: Day03PlayerData
@export var _is_god_mode_enabled: bool = false

var _player: Day03Player
var _boss: Node2D

@onready var _world := $World
@onready var _world_background := $World/Day03Bg
@onready var _player_start_position = $World/StartPosition.position
@onready var _wave_manager := $Systems/WaveManager
@onready var _stamina_spawner := $Systems/StaminaSpawner
@onready var _power_up_spawner := $Systems/PowerUpSpawner
@onready var _scene_tree = get_tree()
@onready var _results_screen = $ResultsScreenBuffet


var _level_state: LevelState = LevelState.STARTING :
	get:
		return _level_state
	set(mod_value):
		_level_state = mod_value
		level_state_changed.emit(_level_state)


func _ready() -> void:
	_player = _instantiate_player()
	_player.is_input_enabled = false
	_player.stop_stamina_lose(true)
	_player.is_autofire_enabled = SaveDataManager.save_data.is_autofire_enabled
	SaveDataManager.save_data.is_autofire_enabled_changed.connect(
		func(_old_val, new_val): _player.is_autofire_enabled = new_val
	)
	_level_state = LevelState.STARTING
	await _scene_tree.create_timer(START_DURATION, false).timeout
	_level_state = LevelState.PLAYING
	_player.is_input_enabled = true
	_player.stop_stamina_lose(false)
	_stamina_spawner.enable(_world)
	_power_up_spawner.enable(_world)
	_wave_manager.start(_world, _player)


func _input(event: InputEvent) -> void:
	if _level_state == LevelState.PLAYING and event.is_action_pressed("pause"):
		_scene_tree.paused = not _scene_tree.paused
		pause_state_changed.emit(_scene_tree.paused)


func _instantiate_boss() -> Node:
	var boss = Boss.instantiate()
	boss.position.y = (3 + boss.body_height()) * -1
	boss.position.x =  _world.get_viewport_rect().size.x / 2 - 30
	boss._world = _world
	_world.add_child(boss)
	return boss


func _instantiate_player() -> Day03Player:
	var player = Player.instantiate() as Day03Player
	player.position = _player_start_position
	player.died.connect(_on_player_died)
	player.mega_gun_shot.connect(_world_background._on_mega_gun_shot)
	player.is_god_mode_enabled = _is_god_mode_enabled
	_world.add_child(player)
	return player


func _game_over() -> void:
	_level_state = LevelState.GAME_OVER
	_wave_manager.cancel_wave()
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	await _scene_tree.create_timer(GAME_OVER_DURATION).timeout
	_scene_tree.quit()


func _on_player_died(remaining_lives: int) -> void:
	if remaining_lives > 0:
		await _scene_tree.create_timer(TIME_BETWEEN_REVIVALS, false).timeout
		_player.revive()
		_player.position = _player_start_position
	else:
		_game_over()


func _on_wave_manager_wave_completed(wave_index: int) -> void:
	print("WAVE %s COMPLETED!" % str(wave_index))


func _on_wave_manager_all_waves_completed() -> void:
	print("All waves completed!")
	if _player.is_dead(): return
	get_tree().call_group("bullets", "queue_free")
	get_tree().call_group("items", "queue_free")
	_stamina_spawner.cooldown = Utils.FRAME_TIME
	_stamina_spawner.random = false
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_player.reset_power_up()
	_player.reset_stamina()
	_player.is_input_enabled = false
	_player.stop_stamina_lose(true)
	_player.position = _player_start_position
	_boss = _instantiate_boss()
	_boss.died.connect(_on_boss_dead)
	_boss.almost_dead.connect(_on_boss_almost_dead)
	_boss._world = _world
	waves_completed.emit()


func _on_wave_manager_wave_started(wave_index: int) -> void:
	print("WAVE %s STARTED!" % str(wave_index))


func _on_boss_dead() -> void:
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_player.stop_stamina_lose(true)
	_level_state = LevelState.LEVEL_COMPLETE
	get_tree().create_timer(RESULTS_SCREEN_DELAY, false).timeout.connect(func():
		# TODO Destroy or disable the current _world, game systems and interface.
		_player.is_input_enabled = false
		_results_screen.is_last_level = true # TODO
		var total_score = _results_screen.start(
			_player_data.lives, 
			_player_data.score,
			SaveDataManager.save_data.high_scores.buff_three_a
		)
		# TODO high scores are stored for different levels and modes.
		if total_score > SaveDataManager.save_data.high_scores.buff_three_a:
			SaveDataManager.save_data.high_scores.buff_three_a = total_score
			SaveDataManager.save()
	)


func _on_boss_almost_dead() -> void:
	_power_up_spawner.enable(_world)
	_power_up_spawner.cooldown = Utils.FRAME_TIME
	_power_up_spawner.random = false


func _on_day_3_ui_boss_alert_finished() -> void:
	var tween = create_tween()
	tween.tween_property(_boss, "position:y", 3.0, 4.32).set_trans(Tween.TRANS_LINEAR)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tween.finished.connect(func():
		_stamina_spawner.enable(_world)
		_player.stop_stamina_lose(false)
		_player.start_timed_invincibility()
		_player.is_input_enabled = true
		_boss.start()
	)


func _on_results_screen_buffet_results_presented(total_score: int) -> void:
	# show level complete screen. On story mode add as much lives as awarded on this level
	# On buffet mode, load the title screen
	# On story mode, load the next level
	pass
