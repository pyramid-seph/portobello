class_name Day02Game
extends Node

enum Level {
	STORY_MODE_LEVEL_01,
	STORY_MODE_LEVEL_02,
	STORY_MODE_LEVEL_03,
	SCORE_ATTACK_MODE_LEVEL_01,
	SCORE_ATTACK_MODE_LEVEL_02,
	SCORE_ATTACK_MODE_LEVEL_03
}

const Day02Ui = preload("res://scenes/day_02/_shared/ui/day_02_ui.gd")

const MAX_LIVES_STORY: int = 9
const MAX_LIVES_SCORE_ATTACK: int = 3
const REVIVAL_DELAY_SEC: float = 2.0

@export var _level: Day02Game.Level:
	set(value):
		_level = value
		_on_level_changed()

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

@onready var _is_ready: bool = true
@onready var _timer := $Timer as Timer
@onready var _ui := %Day02Ui as Day02Ui


func _ready() -> void:
	_set_initial_lives()
	_on_score_changed()
	_on_level_changed()
	$World/Maze.completed.connect(func():
		print("MAZE COMPLETED!")
	)

func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level


func _set_up_level() -> void:
	_reset_level()
	_ui.show_black_screen(false)


func _reset_level() -> void:
	pass


func _start_level() -> void:
	pass


func _set_initial_lives() -> void:
	_remaining_lives = MAX_LIVES_STORY # TODO


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _on_level_changed() -> void:
	if _is_ready:
		_ui.show_black_screen(true)
		await _set_up_level()
		await _start_level()


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
	pass


func _on_level_beaten() -> void:
	_ui.show_level_beaten()
	await _ui.level_beaten_finished
	_ui.show_black_screen(true)
	# TODO change to next level 


func _on_player_died() -> void:
	_remaining_lives -= 1
	_timer.start(REVIVAL_DELAY_SEC)
	await _timer.timeout
	
	if _remaining_lives <= 0:
		_on_level_failed()
	else:
		_reset_level()


func _on_results_screen_calculated(new_high_score, stars) -> void:
	pass # Replace with function body.


func _on_results_screen_finished(total_score, extra_lives, stars) -> void:
	pass # Replace with function body.
