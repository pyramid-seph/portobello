class_name Day02Game
extends Node

enum Level {
	STORY_MODE_LEVEL_01,
	STORY_MODE_LEVEL_02,
	STORY_MODE_LEVEL_03,
	SCORE_ATTACK_MODE_LEVEL_01,
	SCORE_ATTACK_MODE_LEVEL_02,
	SCORE_ATTACK_MODE_LEVEL_03,
}

const ResultsScreen = preload("res://scenes/_shared/ui/results_screen.gd")
const Day02Ui = preload("res://scenes/day_02/_shared/ui/day_02_ui.gd")
const Maze = preload("res://scenes/day_02/_shared/maze/maze.gd")

const MAX_LIVES_STORY: int = 9
const MAX_LIVES_SCORE_ATTACK: int = 3
const REVIVAL_DELAY_SEC: float = 0.5
const LEVEL_CHANGE_DELAY_SEC: float = 1.0
const POINTS_TREAT: int = 10
const POINTS_SUPER_TREAT: int = 20
const POINTS_GHOST: int = 200
const FAST_ENEMY_SPEED: float = 40.0
const SLOW_ENEMY_SPEED: float = 13.375

@export var _initial_level: Day02Game.Level

var _score: int:
	set(value):
		_score = value
		_on_score_changed()
var _remaining_lives: int:
	set(value):
		_remaining_lives = value
		_on_remaining_lives_changed()

@onready var _is_ready := true
@onready var _timer := $Timer as Timer
@onready var _ui := %Day02Ui as Day02Ui
@onready var _results_screen := %ResultsScreen as ResultsScreen
@onready var _maze_a := $World/Mazes/MazeA as Maze
@onready var _maze_b := $World/Mazes/MazeB as Maze
@onready var _maze_c := $World/Mazes/MazeC as Maze
@onready var _mazes: Array[Maze] = [_maze_a, _maze_b, _maze_c]
@onready var _level: int = _get_initial_level_index():
	set(value):
		_level = value
		_on_level_set()


func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY_DPAD_ONLY
	_setup_high_score_ui()
	_set_initial_lives()
	_on_score_changed()
	_on_level_set()


func _exit_tree() -> void:
	SoundUtils.stop_all_sfx()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_initial_level = data.level


func _get_high_score() -> int:
	var high_scores := SaveDataManager.save_data.high_scores
	return high_scores.day_two if _is_game_story_mode() else high_scores.buff_two


func _setup_high_score_ui() -> void:
	_ui.update_high_score(_get_high_score())


func _set_up_level() -> void:
	for maze: Maze in _mazes:
		await maze.quit()
	_timer.start(LEVEL_CHANGE_DELAY_SEC)
	await _timer.timeout
	var current_maze = _get_current_maze()
	current_maze.prepare()
	
	if _level > 0:
		current_maze.blue_ghost_speed = FAST_ENEMY_SPEED
	else:
		current_maze.blue_ghost_speed = SLOW_ENEMY_SPEED
	if _level > 1:
		current_maze.red_ghost_speed = FAST_ENEMY_SPEED
		current_maze.yellow_ghost_speed = FAST_ENEMY_SPEED
	else:
		current_maze.red_ghost_speed = SLOW_ENEMY_SPEED
		current_maze.yellow_ghost_speed = SLOW_ENEMY_SPEED
	
	_ui.show_black_screen(false)


func _start_level() -> void:
	var game_mode: Game.Mode = _get_game_mode()
	_ui.show_level_start(game_mode, _level)
	await _ui.start_level_finished
	_ui.show_level_name(game_mode, _level)
	_get_current_maze().start()


func _set_initial_lives() -> void:
	if _is_game_story_mode():
		_remaining_lives = MAX_LIVES_STORY
	else:
		_remaining_lives = MAX_LIVES_SCORE_ATTACK


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _get_initial_level_index() -> int:
	match _initial_level:
		Level.STORY_MODE_LEVEL_01:
			return 0
		Level.STORY_MODE_LEVEL_02:
			return 1
		Level.STORY_MODE_LEVEL_03:
			return 2
		Level.SCORE_ATTACK_MODE_LEVEL_01:
			return 0
		Level.SCORE_ATTACK_MODE_LEVEL_02:
			return 1
		Level.SCORE_ATTACK_MODE_LEVEL_03:
			return 2
		_:
			return 0


func _get_current_maze() -> Maze:
	return _mazes[wrapi(_level, 0, _mazes.size())]


func _get_game_mode() -> Game.Mode:
	match _initial_level:
		Level.STORY_MODE_LEVEL_01, \
		Level.STORY_MODE_LEVEL_02, \
		Level.STORY_MODE_LEVEL_03:
			return Game.Mode.STORY
		_:
			return Game.Mode.SCORE_ATTACK


func _is_game_story_mode() -> bool:
	return _get_game_mode() == Game.Mode.STORY


func _on_level_set() -> void:
	if _is_ready:
		_ui.show_black_screen(true)
		_ui.set_pause_menu_enabled(false)
		await _set_up_level()
		await _start_level()
		_ui.set_pause_menu_enabled(true)


func _on_score_changed() -> void:
	if _is_ready:
		_ui.update_score(_score)


func _on_remaining_lives_changed() -> void:
	if _is_ready:
		_ui.update_lives_counter(_remaining_lives, true)


func _save_high_score() -> bool:
	var changed := false
	var high_scores := SaveDataManager.save_data.high_scores
	if _is_game_story_mode():
		if _score > high_scores.day_two:
			high_scores.day_two = _score
			changed = true
	else:
		if _score > high_scores.buff_two:
			high_scores.buff_two = _score
			changed = true
	if changed:
		SaveDataManager.save()
	return changed


func _game_over() -> void:
	var new_high_score_achieved: bool = _save_high_score()
	_ui.set_pause_menu_enabled(false)
	_ui.show_game_over(new_high_score_achieved)
	await _ui.game_over_finished
	_go_to_title_screen()


func _on_maze_completed() -> void:
	_ui.set_pause_menu_enabled(false)
	_ui.show_level_beaten()
	await _ui.level_beaten_finished
	_ui.hide_level_name()
	_ui.show_black_screen(true)
	if _is_game_story_mode() and _level >= _mazes.size() - 1:
		await _get_current_maze().quit()
		_results_screen.start(
				_get_game_mode(),
				true, 
				_remaining_lives, 
				_score, 
				_get_high_score()
		)
	else:
		_ui.set_pause_menu_enabled(true)
		_level += 1


func _on_maze_ghost_eaten() -> void:
	_score += POINTS_GHOST


func _on_maze_super_treat_eaten() -> void:
	_score += POINTS_SUPER_TREAT


func _on_maze_treat_eaten() -> void:
	_score += POINTS_TREAT


func _on_maze_player_dying() -> void:
	if _remaining_lives == 1:
		_get_current_maze().failed()


func _on_maze_player_died() -> void:
	_remaining_lives -= 1
	# FIXME The code below is also executed when the player dies at the
	# same time they complete the maze. In that situation, when they have 0 lives,
	# it is expected for this code to run. However, when the have more than
	# 0 lives left, only the remaining_lives var should be updated.
	# Nothing serious happen if this is not fixed since, with the current
	# value of REVIVAL_DELAY_SEC, the current maze is still the completed one, 
	# not the next. If REVIVAL_DELAY_SEC changes, this code could cause malfunctions.
	_timer.start(REVIVAL_DELAY_SEC)
	await _timer.timeout
	
	if _remaining_lives <= 0:
		_game_over()
	else:
		_get_current_maze().revive_player()


func _on_results_screen_calculated(_new_high_score, stars) -> void:
	_save_high_score()
	var save_data := SaveDataManager.save_data as SaveData
	save_data.stars.day_two = maxi(save_data.stars.day_two, stars)
	var curr_progress = SaveDataManager.save_data.latest_day_completed
	save_data.latest_day_completed = maxi(curr_progress, 2)
	SaveDataManager.save()


func _on_results_screen_finished(_total_score, _extra_lives, _stars) -> void:
	SceneChanger.change_to_scene(
		"res://scenes/day_02/_shared/cutscenes/cutscene_day_02_02.tscn"
	)
