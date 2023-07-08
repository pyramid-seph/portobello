class_name Day01Game
extends Node


enum Level {
	STORY_MODE_LEVEL_01,
	SCORE_ATTACK_1A,
	SCORE_ATTACK_1B,
	SCORE_ATTACK_1C,
	SCORE_ATTACK_1D,
}

const REVIVAL_DELAY_SEC: float = 3.0

@export var _level: Day01Game.Level = Day01Game.Level.STORY_MODE_LEVEL_01
@export var _level_settings: Day01LevelSettings

var _score: int
var _high_score: int
var _remaining_lives: int:
	set(value):
		_remaining_lives = value
		if _is_ready:
			_ui.update_lives_counter(_remaining_lives)
var _eaten_treats: int:
	set(value):
		_eaten_treats = value
		_on_eaten_treats_chaanged()

@onready var _is_ready: bool = true
@onready var _results_screen = $Interface/ResultsScreen
@onready var _player = $World/Day01Player
@onready var _ui = $Interface/Day01GameUi
@onready var _timer := $Timer as Timer


func _ready() -> void:
	_set_up_level()
	_start_level()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level


func _set_up_level() -> void:
	_eaten_treats = 0
	_remaining_lives = _level_settings.max_lives
	_player.inverted_controls = _level_settings.inverted_controls
	_player.pace_sec= _level_settings.pace_sec
	_player.stamina_sec = _level_settings.stamina_sec
	_ui.set_is_stamina_bar_visible(_level_settings.is_time_based())


func _start_level() -> void:
	_player.can_move = false
	# TODO Show presentation.
	# Await until presentation ends
	_player.can_move = true


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _is_last_level() -> bool:
	return true


func _on_eaten_treats_chaanged() -> void:
	if not _is_ready:
		return
	var count: int
	if _level_settings.is_score_attack():
		count = _eaten_treats
	else:
		count = _level_settings.treats - _eaten_treats
	_ui.update_treats_counter(count)


func _on_level_failed() -> void:
	# * Show game over label
	# * Await until it dissapers
	# * Show results screen if it is a score attack level
	#     * Await until the results screen finishes
	#     * Save results
	_go_to_title_screen()


func _on_level_beaten(lives: int, total_score: int, _stars: int) -> void:
	# set up next level
	pass


func _on_player_died() -> void:
	_remaining_lives -= 1
	if _remaining_lives <= 0:
		_on_level_failed()
	else:
		_timer.start(REVIVAL_DELAY_SEC)
		await _timer.timeout
		_player.revive()


func _on_player_ate() -> void:
	_score += 1
	_eaten_treats += 1
	
	if _level_settings.is_score_attack():
		return
	
	if _eaten_treats >= _level_settings.treats:
		_on_level_beaten(0, 0, 0)


func _on_results_screen_calculated(new_high_score, stars) -> void:
	pass


func _on_results_screen_finished(total_score, extra_lives, stars) -> void:
	pass


func _on_player_stamina_changed(stamina) -> void:
	_ui.update_stamina_bar(stamina)
