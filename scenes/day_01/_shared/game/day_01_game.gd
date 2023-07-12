class_name Day01Game
extends Node

const Player = preload("res://scenes/day_01/player/day_01_player.gd")
const Day01Ui = preload("res://scenes/day_01/_shared/ui/day_01_game_ui.gd")
const LevelInfo = preload("res://scenes/day_01/_shared/game/level_info.gd")
const Treat = preload("res://scenes/day_01/_shared/treat.tscn")
const ResultsScreen = preload("res://scenes/_shared/ui/results_screen.gd")
const TreatPlacementSystem = preload("res://scenes/day_01/_shared/game/treat_placement_system.gd")
const FurniturePlacementSystem = preload("res://scenes/day_01/_shared/game/furniture_placement_system.gd")

enum Level {
	STORY_MODE_LEVEL_01,
	STORY_MODE_LEVEL_02,
	STORY_MODE_LEVEL_03,
	STORY_MODE_LEVEL_04,
	STORY_MODE_LEVEL_05,
	STORY_MODE_LEVEL_06,
	STORY_MODE_LEVEL_07,
	STORY_MODE_LEVEL_08,
	SCORE_ATTACK_1A,
	SCORE_ATTACK_1B,
	SCORE_ATTACK_1C,
	SCORE_ATTACK_1D,
}

const MAX_LIVES_STORY: int = 9
const MAX_LIVES_SCORE_ATTACK: int = 1
const REVIVAL_DELAY_SEC: float = 3.0

@export var _level: Day01Game.Level:
	set(value):
		_level = value
		_on_level_changed()

var _score: int
var _high_score: int
var _remaining_lives: int:
	set(value):
		_remaining_lives = value
		if _is_ready:
			_ui.update_lives_counter(_remaining_lives)
var _treats_ate: int:
	set(value):
		_treats_ate = value
		_on_treats_ate_changed()
var _curr_lvl_settings: Day01LevelSettings

@onready var _is_ready: bool = true
@onready var _results_screen := $World/Interface/ResultsScreen as ResultsScreen
@onready var _player := $World/TileMap/Day01Player as Player
@onready var _ui := $World/Interface/Day01GameUi as Day01Ui
@onready var _timer := $Timer as Timer
@onready var _lvl_info := $Systems/LevelInfo as LevelInfo
@onready var _world := $World as Node2D
@onready var _treat_placement_system := $Systems/TreatPlacementSystem as TreatPlacementSystem
@onready var _furniture_placement_system := $Systems/FurniturePlacementSystem as FurniturePlacementSystem


func _ready() -> void:
	_on_level_changed()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level


func _set_up_room() -> void:
	if _curr_lvl_settings:
		_furniture_placement_system.place_furniture(_curr_lvl_settings.obstacle_course_type)


func _place_treat() -> void:
	_treat_placement_system.spawn_treat_random()


func _set_up_level() -> void:
	_curr_lvl_settings = _lvl_info.get_settings(_level)
	
	if _lvl_info.get_game_mode(_level) == Game.Mode.STORY:
		_remaining_lives = MAX_LIVES_STORY
	else:
		_remaining_lives = MAX_LIVES_SCORE_ATTACK
	
	_ui.set_is_stamina_bar_visible(_curr_lvl_settings.is_time_limited())
	_ui.update_treats_counter(_curr_lvl_settings.treats_limit)
	
	_reset_level()
	_set_up_room()
	_place_treat()


func _reset_level() -> void:
	if not _curr_lvl_settings:
		return
	_treats_ate = 0
	_player.pace_sec = _curr_lvl_settings.get_pace(_treats_ate)
	_player.stamina_sec = _curr_lvl_settings.time_limit_sec
	_player.inverted_controls = _curr_lvl_settings.inverted_controls
	_player.revive(true)


func _start_level() -> void:
	_player.can_move = false
	# TODO if not first level, play cutscene.
	var game_mode = _lvl_info.get_game_mode(_level)
	var lvl_index = _lvl_info.get_lvl_index(_level)
	_ui.show_level_start(game_mode, lvl_index)
	await _ui.start_level_finished
	_player.can_move = true


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _on_level_changed() -> void:
	if _is_ready:
		_set_up_level()
		_start_level()


func _on_treats_ate_changed() -> void:
	if not _is_ready:
		return
	var count: int
	if _curr_lvl_settings.limits_treats():
		count = maxi(0, _curr_lvl_settings.treats_limit - _treats_ate)
	else:
		count = _treats_ate
	_ui.update_treats_counter(count)


func _on_remaining_lives_changed() -> void:
	if not _is_ready:
		return


func _on_level_failed() -> void:
	_ui.show_game_over()
	await _ui.game_over_finished
	_go_to_title_screen()


func _on_level_beaten() -> void:
	_player.can_move = false
	_ui.show_level_beaten()
	await _ui.level_beaten_finished
	
	var next_lvl = _lvl_info.get_next_level(_level)
	if next_lvl == -1:
		_results_screen.start(
				_lvl_info.get_game_mode(_level),
				true, 
				_remaining_lives, 
				_score, 
				_high_score
		)
	else:
		_level = next_lvl


func _on_player_died(cause: Player.DeathCause) -> void:
	_remaining_lives -= 1
	
	if cause == Player.DeathCause.FATIGUE:
		_ui.show_time_out()
		await _ui.time_out_finished
	else:
		_timer.start(REVIVAL_DELAY_SEC)
		await _timer.timeout
	
	if _remaining_lives <= 0:
		_on_level_failed()
	else:
		_reset_level()


func _on_player_ate() -> void:
	if not _curr_lvl_settings:
		print("No _curr_lvl_settings set. Skipping methd.")
		return
	
	_score += 1
	_treats_ate += 1
	
	# TODO Maybe move this to _on_treats_ate_changed
	if _curr_lvl_settings.limits_treats() and \
			_treats_ate >= _curr_lvl_settings.treats_limit:
		_on_level_beaten()
	else:
		_place_treat()
		_player.pace_sec = _curr_lvl_settings.get_pace(_treats_ate)


func _on_results_screen_calculated(new_high_score, stars) -> void:
	pass


func _on_results_screen_finished(total_score, extra_lives, stars) -> void:
	_go_to_title_screen()


func _on_player_stamina_changed(stamina) -> void:
	_ui.update_stamina_bar(stamina)
