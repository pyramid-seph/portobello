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
const REVIVAL_DELAY_SEC: float = 2.0
const LEVEL_CHANGE_DELAY_SEC: float = 1.0

@export var _initial_level: Day02Game.Level

var _score: int:
	set(value):
		_score = value
		_on_score_changed()
var _high_score: int:
	set(value):
		_high_score = value
		_on_high_score_changed()
var _remaining_lives: int:
	set(value):
		_remaining_lives = value
		_on_remaining_lives_changed()
var _immediate_lives_counter_update: bool = true

@onready var _is_ready := true
@onready var _timer := $Timer as Timer
@onready var _ui := %Day02Ui as Day02Ui
@onready var _results_screen := %ResultsScreen as ResultsScreen
@onready var _maze_a := $World/Mazes/MazeA as Maze
@onready var _maze_b := $World/Mazes/MazeB as Maze
@onready var _maze_c := $World/Mazes/MazeC as Maze
@onready var _mazes: Array = [_maze_a, _maze_b, _maze_c]
@onready var _level: int = _get_initial_level_index():
	set(value):
		_level = value
		_on_level_set()


func _ready() -> void:
	_set_initial_lives()
	_on_score_changed()
	_on_level_set()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_initial_level = data.level


func _set_up_level() -> void:
	for maze in _mazes:
		maze.visible = false
	_timer.start(LEVEL_CHANGE_DELAY_SEC)
	await _timer.timeout
	_get_current_maze().reset()
	_get_current_maze().visible = true
	_ui.show_black_screen(false)


func _start_level() -> void:
	var game_mode: Game.Mode = _get_game_mode()
	_ui.show_level_start(game_mode, _level)
	await _ui.start_level_finished
	_get_current_maze().start()


func _set_initial_lives() -> void:
	_remaining_lives = MAX_LIVES_STORY # TODO


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


func _on_level_set() -> void:
	if _is_ready:
		_ui.show_black_screen(true)
		_set_up_level()
		_start_level()


func _on_score_changed() -> void:
	if _is_ready:
		_ui.update_score(_score)


func _on_high_score_changed() -> void:
	if _is_ready:
		_ui.update_high_score(_high_score)


func _on_remaining_lives_changed() -> void:
	if not _is_ready:
		return
	_ui.update_lives_counter(_remaining_lives, _immediate_lives_counter_update)
	_immediate_lives_counter_update = false


func _on_level_failed() -> void:
	# Set high score
	_ui.show_game_over(false)
	await _ui.game_over_finished
	_go_to_title_screen()


func _on_maze_completed() -> void:
	_ui.show_level_beaten()
	await _ui.level_beaten_finished
	_ui.show_black_screen(true)
	if _get_game_mode() == Game.Mode.STORY and _level >= _mazes.size() - 1:
		_get_current_maze().visible = false
		_results_screen.start(
				_get_game_mode(),
				true, 
				_remaining_lives, 
				_score, 
				_high_score
		)
	else:
		_level += 1


func _on_player_died() -> void:
	_remaining_lives -= 1
	_timer.start(REVIVAL_DELAY_SEC)
	await _timer.timeout
	
	if _remaining_lives <= 0:
		_on_level_failed()
	else:
		pass # Revive player


func _on_results_screen_calculated(new_high_score, stars) -> void:
	# TODO if on story mode, save stars, minigame beaten and story mode highscore
	#  else do nothing
	pass


func _on_results_screen_finished(total_score, extra_lives, stars) -> void:
	# TODO Show cutscene instead
	_go_to_title_screen()
