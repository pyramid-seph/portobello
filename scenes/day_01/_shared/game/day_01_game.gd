class_name Day01Game
extends Node

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

const Player = preload("res://scenes/day_01/player/day_01_player.gd")
const Day01Ui = preload("res://scenes/day_01/_shared/ui/day_01_game_ui.gd")
const LevelInfo = preload("res://scenes/day_01/_shared/game/level_info.gd")
const Treat = preload("res://scenes/day_01/_shared/treat.tscn")
const ResultsScreen = preload("res://scenes/_shared/ui/results_screen.gd")
const TreatPlacementSystem = preload("res://scenes/day_01/_shared/game/treat_placement_system.gd")
const FurniturePlacementSystem = preload("res://scenes/day_01/_shared/game/furniture_placement_system.gd")

const MAX_LIVES_STORY: int = 9
const MAX_LIVES_SCORE_ATTACK: int = 1
const REVIVAL_DELAY_SEC: float = 2.0
const TREAT_PLACEMENT_DELAY_SEC: float = 1.0

@export var _level: Day01Game.Level:
	set(value):
		_level = value
		_on_level_changed()

var _score: int
var _high_score: int:
	set(value):
		_high_score = value
		_on_high_score_changed()
var _remaining_lives: int:
	set(value):
		_remaining_lives = value
		_on_remaining_lives_changed()
var _treats_eaten: int:
	set(value):
		_treats_eaten = value
		_on_treats_eaten_changed()
var _curr_lvl_settings: Day01LevelSettings
var _immediate_lives_counter_update: bool = true

@onready var _is_ready: bool = true
@onready var _results_screen := %ResultsScreen as ResultsScreen
@onready var _player := $World/TileMap/Day01Player as Player
@onready var _ui := %Day01GameUi as Day01Ui
@onready var _timer := $Timer as Timer
@onready var _lvl_info := $Systems/LevelInfo as LevelInfo
@onready var _treat_placement_system := $Systems/TreatPlacementSystem as TreatPlacementSystem
@onready var _furniture_placement_system := $Systems/FurniturePlacementSystem as FurniturePlacementSystem
@onready var _cutscene := %Day01BetweenLevelsCutscene
@onready var _max_time_limit: float = _get_max_time_limit()


func _ready() -> void:
	_set_initial_lives()
	_on_level_changed()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level


func _get_max_time_limit() -> float:
	var max_time_limit: float = 0.0
	for item in Level.values():
		var level_settings: Day01LevelSettings = _lvl_info.get_settings(item)
		max_time_limit = maxf(max_time_limit, level_settings.time_limit_sec)
	return max_time_limit


func _set_initial_lives() -> void:
	if _lvl_info.is_story_mode_level(_level):
		_remaining_lives = MAX_LIVES_STORY
	else:
		_remaining_lives = MAX_LIVES_SCORE_ATTACK


func _set_up_room() -> void:
	if _curr_lvl_settings:
		_furniture_placement_system.place_furniture(_curr_lvl_settings.obstacle_course_type)


func _place_treat() -> void:
	_treat_placement_system.spawn_treat_random()


func _set_up_level() -> void:
	_curr_lvl_settings = _lvl_info.get_settings(_level)
	_high_score = _lvl_info.get_high_score(_level)
	
	_ui.set_is_stamina_bar_visible(_curr_lvl_settings.is_time_limited())
	_ui.update_treats_counter(_curr_lvl_settings.treats_limit)
	
	_reset_level()
	_set_up_room()
	await get_tree().physics_frame
	# It seems that waiting for the next
	# physhics frame is not enough to
	# have updated furniture's colliders.
	# Let's give it more than time for this to happen
	# before trying to place a treat.
	# It works, but I'm not sure if this is
	# the right way, though.
	_timer.start(TREAT_PLACEMENT_DELAY_SEC)
	await _timer.timeout
	_place_treat()
	_ui.show_black_screen(false)


func _reset_level() -> void:
	if not _curr_lvl_settings:
		return
	_treats_eaten = 0
	_player.pace_sec = _curr_lvl_settings.get_pace(_treats_eaten)
	_player.stamina_sec = _curr_lvl_settings.time_limit_sec
	_player.inverted_controls = _curr_lvl_settings.inverted_controls
	_player.revive(true)


func _start_level() -> void:
	var game_mode = _lvl_info.get_game_mode(_level)
	var lvl_index = _lvl_info.get_lvl_index(_level)
	_ui.show_level_start(game_mode, lvl_index)
	await _ui.start_level_finished
	_play_dialogue()
	_player.is_allowed_to_move = true


func _play_dialogue() -> void:
	if _curr_lvl_settings:
		_ui.play_dialogue(_curr_lvl_settings.dialogue)


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _on_level_changed() -> void:
	if _is_ready:
		_player.is_allowed_to_move = false
		_ui.show_black_screen(true)
		_ui.set_pause_menu_enabled(false)
		await _set_up_level()
		await _start_level()
		_ui.set_pause_menu_enabled(true)


func _on_treats_eaten_changed() -> void:
	if not _is_ready:
		return
	var count: int
	if _curr_lvl_settings.limits_treats():
		count = maxi(0, _curr_lvl_settings.treats_limit - _treats_eaten)
	else:
		count = _treats_eaten
	_ui.update_treats_counter(count)


func _on_high_score_changed() -> void:
	if _is_ready:
		_ui.update_high_score(_high_score)


func _on_remaining_lives_changed() -> void:
	if not _is_ready:
		return
	_ui.update_lives_counter(_remaining_lives, _immediate_lives_counter_update)
	_immediate_lives_counter_update = false


func _on_level_failed() -> void:
	var new_high_score_achieved = _lvl_info.set_high_score(_level, _score)
	_ui.set_pause_menu_enabled(false)
	_ui.show_game_over(new_high_score_achieved)
	await _ui.game_over_finished
	_go_to_title_screen()


func _on_level_beaten() -> void:
	_player.is_allowed_to_move = false
	_ui.set_pause_menu_enabled(false)
	_ui.show_level_beaten()
	await _ui.level_beaten_finished
	_ui.stop_dilogue()
	_ui.show_black_screen(true)
	
	var next_lvl := _lvl_info.get_next_level(_level)
	if next_lvl == _level:
		_results_screen.start(
				_lvl_info.get_game_mode(_level),
				true, 
				_remaining_lives, 
				_score, 
				_high_score
		)
	else:
		_ui.set_pause_menu_enabled(true)
		if _lvl_info.is_story_mode_level(_level):
			var settings := _lvl_info.get_settings(next_lvl)
			_cutscene.inverted_controls = settings.inverted_controls
			_cutscene.play()
			await _cutscene.finished
		_level = next_lvl


func _on_player_died(cause: Player.DeathCause) -> void:
	_remaining_lives -= 1
	
	if cause == Player.DeathCause.FATIGUE:
		_ui.show_time_up()
		await _ui.time_out_finished
	else:
		_timer.start(REVIVAL_DELAY_SEC)
		await _timer.timeout
	
	if _remaining_lives <= 0:
		_on_level_failed()
	else:
		_reset_level()
		if _curr_lvl_settings.change_treat_pos_on_player_death:
			_place_treat()
		_play_dialogue()


func _on_player_ate() -> void:
	if not _curr_lvl_settings:
		print("No _curr_lvl_settings set. Skipping methd.")
		return
	
	_score += 1
	_treats_eaten += 1
	
	# TODO Maybe move this to _on_treats_eaten_changed?
	if _curr_lvl_settings.limits_treats() and \
			_treats_eaten >= _curr_lvl_settings.treats_limit:
		_on_level_beaten()
	else:
		_place_treat()
		_player.pace_sec = _curr_lvl_settings.get_pace(_treats_eaten)


func _on_results_screen_calculated(_new_high_score: int, stars: int) -> void:
	if _lvl_info.is_story_mode_level(_level) and _lvl_info.is_last_level(_level):
		_lvl_info.set_stars(stars)
		_lvl_info.set_story_mode_beaten()


func _on_results_screen_finished(_total_score: int, _extra_lives: int, _stars: int) -> void:
	_go_to_title_screen()


func _on_player_stamina_changed(remaining_stamina: float) -> void:
	_ui.update_stamina_bar(remaining_stamina, _max_time_limit)
