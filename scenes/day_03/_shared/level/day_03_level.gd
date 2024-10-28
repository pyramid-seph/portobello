class_name Day03Level
extends Node


signal level_state_changed(new_state)
signal waves_completed
signal beaten(lives: int, total_score: int, stars: int)
signal failed

enum LevelState { 
	READY, 
	STARTING, 
	PLAYING, 
	GAME_OVER,
	LEVEL_COMPLETE,
	SHOWING_RESULTS,
}

const DAY: int = 3
const START_DURATION: float = 1.6
const GAME_OVER_DURATION: float = 3.0
const PROP_NAME_STORY_SAVE_DATA_HIGH_SCORE: String = "high_scores:day_three"
const PROP_NAME_STORY_SAVE_DATA_STARS: String = "stars:day_three"

@export var _player: Day03Player
@export var _game_mode: Game.Mode
@export var _results_screen_delay_sec: float = 1.0

@export_group("Save Data", "_save_data")
@export var _save_data_score_attack_mode_score_name: String

@export_group("Debug", "_debug")
@export var _debug_is_god_mode_enabled: bool:
	set(value):
		_debug_is_god_mode_enabled = value and OS.is_debug_build()
		_on_debug_is_god_mode_enabled_set()
@export var _debug_start_at_boss_fight: bool:
	set(value):
		_debug_start_at_boss_fight = value and OS.is_debug_build()

var _is_last_level: bool
var _level_index: int
var _level_state: LevelState = LevelState.READY:
	set(value):
		_level_state = value
		level_state_changed.emit(_level_state)

@onready var _world := $World
@onready var _world_background := $World/Day03Bg
@onready var _world_player_start_marker: Marker2D = $World/WavePhaseStartMarker
@onready var _wave_manager: WaveManager = $Systems/WaveManager
@onready var _stamina_spawner := $Systems/StaminaSpawner
@onready var _power_up_spawner := $Systems/PowerUpSpawner
@onready var _timer: Timer = $Timer
@onready var _boss_fight: Day03BossFight = $BossFight
@onready var _results_screen := $Interface/ResultsScreen
@onready var _day_3_ui := $Interface/Day03Ui
@onready var _level_bgm: Day03InteractiveBgm = $Day03InteractiveBgm


func _ready() -> void:
	_on_debug_is_god_mode_enabled_set()
	_set_up_player()
	if get_parent() == $"/root":
		start(_game_mode, 0, false, Day03PlayerData.MAX_LIVES, 0)


func _exit_tree() -> void:
	_level_bgm.stop_music()


func start(mode: Game.Mode, level_index: int, is_last_level: bool, lives: int, score: int) -> void:
	if _level_state != LevelState.READY:
		return
	_level_state = LevelState.STARTING
	_game_mode = mode
	_player.lives = lives
	_player.set_score(score)
	_is_last_level = is_last_level
	_level_index = level_index
	_player.set_high_score(_get_high_score())
	_level_bgm.play_music()
	await _start_level()
	if _debug_start_at_boss_fight:
		_start_boss_phase()
	else:
		_start_wave_phase()


func _get_high_score() -> int:
	var prop_name: String
	if _game_mode == Game.Mode.STORY:
		prop_name = PROP_NAME_STORY_SAVE_DATA_HIGH_SCORE
	else:
		prop_name = _get_score_attack_high_score_prop_name()
	return SaveDataManager.save_data.get_indexed(prop_name)

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
	_day_3_ui.set_pause_menu_enabled(false)
	_day_3_ui.start_game_presentation(_game_mode, _level_index)
	_timer.start(START_DURATION)
	_level_state = LevelState.PLAYING
	await _timer.timeout
	_day_3_ui.set_pause_menu_enabled(true)


func _start_wave_phase() -> void:
	_player.is_input_enabled = true
	_player.is_losing_stamina = true
	_player.start_timed_invincibility()
	_stamina_spawner.enable(_world)
	_power_up_spawner.enable(_world)
	_wave_manager.start(_world, _player)


func _start_boss_phase() -> void:
	_level_bgm.stop_music()
	get_tree().call_group("bullets", "queue_free")
	get_tree().call_group("items", "queue_free")
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_player.reset_power_up()
	_player.reset_stamina()
	_player.is_input_enabled = false
	_player.is_losing_stamina = false
	waves_completed.emit()


func _get_score_attack_high_score_prop_name() -> String:
	return "high_scores:%s" % _save_data_score_attack_mode_score_name


func _game_over() -> void:
	_level_state = LevelState.GAME_OVER
	_wave_manager.stop()
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_day_3_ui.set_pause_menu_enabled(false)
	_timer.start(GAME_OVER_DURATION)
	await _timer.timeout
	failed.emit()


func _on_debug_is_god_mode_enabled_set() -> void:
	if is_node_ready():
		_player.is_god_mode_enabled = _debug_is_god_mode_enabled


func _on_player_revived() -> void:
	if _player.get_parent() == _world:
		_player.position = _world_player_start_marker.position


func _on_player_out_of_lives() -> void:
	_game_over()


func _on_results_screen_finished(total_score: int, extra_lives: int, stars: int) -> void:
	_player.lives += extra_lives
	beaten.emit(_player.lives, total_score, stars)


func _on_day_3_ui_boss_alert_finished() -> void:
	_boss_fight.prepare()
	_boss_fight.start()


func _on_wave_manager_all_waves_completed() -> void:
	if _player.lives == 0:
		return
	
	_power_up_spawner.disable()
	_level_bgm.stop_music(3.0)
	_timer.start(4.5)
	await _timer.timeout
	
	if _player.is_dead():
		_player.revived.connect(_start_boss_phase, CONNECT_ONE_SHOT)
	else:
		_start_boss_phase()


func _on_boss_fight_completed() -> void:
	if _player.lives == 0:
		return
	
	_stamina_spawner.disable()
	_power_up_spawner.disable()
	_player.is_losing_stamina = false
	_level_state = LevelState.LEVEL_COMPLETE
	_day_3_ui.set_pause_menu_enabled(false)
	_timer.start(_results_screen_delay_sec)
	await _timer.timeout
	_boss_fight.cleanup()
	_world.set_process(PROCESS_MODE_DISABLED)
	_world.set_process_input(false)
	_world.visible = false
	_level_state = LevelState.SHOWING_RESULTS
	_results_screen.start(
		_game_mode,
		_is_last_level,
		_player.lives, 
		_player.get_score(), 
		_player.get_high_score()
	)


func _on_results_screen_calculated(new_high_score: int, stars: int) -> void:
	if _game_mode == Game.Mode.STORY and _is_last_level:
		SaveDataManager.save_data.set_indexed(
			PROP_NAME_STORY_SAVE_DATA_HIGH_SCORE,
			 new_high_score
		)
		SaveDataManager.save_data.set_indexed(
			PROP_NAME_STORY_SAVE_DATA_STARS,
			 stars
		)
		var curr_progress = SaveDataManager.save_data.latest_day_completed
		SaveDataManager.save_data.latest_day_completed = maxi(curr_progress, DAY)
	elif _game_mode == Game.Mode.SCORE_ATTACK:
		SaveDataManager.save_data.set_indexed(
			_get_score_attack_high_score_prop_name(),
			 new_high_score
		)
	SaveDataManager.save()
