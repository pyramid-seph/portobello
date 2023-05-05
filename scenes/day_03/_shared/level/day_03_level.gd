class_name Day03Level
extends Node


signal level_state_changed(new_state)
signal waves_completed
signal completed

enum LevelState { STARTING, PLAYING, GAME_OVER, LEVEL_COMPLETE }

const START_DURATION: float = 1.6
const GAME_OVER_DURATION: float = 3.2
const RESULTS_SCREEN_DELAY: float = 10.45

@export var _player: Day03Player

@export_group("Debug", "_debug")
@export var _debug_is_god_mode_enabled: bool:
	set(value):
		_debug_is_god_mode_enabled = value and OS.is_debug_build()
		_on_debug_is_god_mode_enabled_set()
@export var _debug_start_at_boss_fight: bool:
	set(value):
		_debug_start_at_boss_fight = value and OS.is_debug_build()

var _level_state: LevelState = LevelState.STARTING:
	set(value):
		_level_state = value
		level_state_changed.emit(_level_state)

@onready var _is_ready: bool = true
@onready var _world := $World
@onready var _world_background := $World/Day03Bg
@onready var _world_player_start_marker := $World/WavePhaseStartMarker as Marker2D
@onready var _wave_manager := $Systems/WaveManager as WaveManager
@onready var _stamina_spawner := $Systems/StaminaSpawner
@onready var _power_up_spawner := $Systems/PowerUpSpawner
@onready var _timer := $Timer as Timer
@onready var _boss_fight := $BossFight as Day03BossFight


func _ready() -> void:
	_on_debug_is_god_mode_enabled_set()
	_set_up_player()
	await _start_level()
	if _debug_start_at_boss_fight:
		_start_boss_phase()
	else:
		_start_wave_phase()


func _set_up_player() -> void:
	_player.revived.connect(_on_player_revived)
	_player.out_of_lives.connect(_on_player_out_of_lives)
	_player.mega_gun_shot.connect(_world_background._on_mega_gun_shot)
	_player.is_autofire_enabled = SaveDataManager.save_data.is_autofire_enabled
	SaveDataManager.save_data.is_autofire_enabled_changed.connect(
		func(_old_val, new_val): 
			_player.is_autofire_enabled = new_val
	)


func _start_level() -> void:
	_player.position = _world_player_start_marker.position
	_player.is_input_enabled = false
	_player.is_losing_stamina = false
	_level_state = LevelState.STARTING
	_timer.start(START_DURATION)
	_level_state = LevelState.PLAYING
	await _timer.timeout


func _start_wave_phase() -> void:
	_player.is_input_enabled = true
	_player.is_losing_stamina = true
	_player.start_timed_invincibility()
	_stamina_spawner.enable(_world)
	_power_up_spawner.enable(_world)
	_wave_manager.start(_world, _player)


func _start_boss_phase() -> void:
	get_tree().call_group("bullets", "queue_free")
	get_tree().call_group("items", "queue_free")
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_player.reset_power_up()
	_player.reset_stamina()
	_player.is_input_enabled = false
	_player.is_losing_stamina = false
	waves_completed.emit()


func _on_debug_is_god_mode_enabled_set() -> void:
	if _is_ready:
		_player.is_god_mode_enabled = _debug_is_god_mode_enabled


func _game_over() -> void:
	_level_state = LevelState.GAME_OVER
	_wave_manager.cancel_wave()
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_timer.start(GAME_OVER_DURATION)
	await _timer.timeout
	get_tree().quit()


func _on_player_revived() -> void:
	if _player.get_parent() == _world:
		_player.position = _world_player_start_marker.position


func _on_player_out_of_lives() -> void:
	_game_over()


func _on_level_complete() -> void:
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_player.is_losing_stamina = false
	_level_state = LevelState.LEVEL_COMPLETE
	_timer.start(RESULTS_SCREEN_DELAY)
	await _timer.timeout
	completed.emit()


func _on_day_3_ui_boss_alert_finished() -> void:
	_boss_fight.prepare()
	_boss_fight.start()


func _on_wave_manager_all_waves_completed() -> void:
	if not _player.is_dead():
		_start_boss_phase()


func _on_boss_fight_completed() -> void:
	_on_level_complete()
