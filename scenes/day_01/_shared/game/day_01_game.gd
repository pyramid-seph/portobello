class_name Day01Game
extends Node


enum Level {
	STORY_MODE_LEVEL_01,
	SCORE_ATTACK_1A,
	SCORE_ATTACK_1B,
	SCORE_ATTACK_1C,
	SCORE_ATTACK_1D,
}

enum ObstacleCourseType {
	NONE,
	DEFAULT,
	RANDOM,
}

@export var _level: Day01Game.Level = Day01Game.Level.STORY_MODE_LEVEL_01

@export_group("Level Settings","_ld")
@export var _ld_pace_sec: float
@export var _ld_obstacle_course_type: ObstacleCourseType
@export var _ld_reverse_controls: bool
@export var _ld_max_lives: int = 9
@export var _ld_treats: int
@export var _ld_dialogue: Array[DialogueLine]

var _lives: int
var _stamina: int
var _score: int
var _high_score: int
var _remaining_treats: int
var _initial_lives: int = Day03PlayerData.MAX_LIVES

@onready var _results_screen := $Interface/ResultsScreen


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _is_last_level() -> bool:
	return _level != Day01Game.Level.STORY_MODE_LEVEL_01


func _on_player_crashed() -> void:
	pass # Replace with function body.


func _on_player_ate() -> void:
	pass # Replace with function body.


func _on_level_failed() -> void:
	_go_to_title_screen()


func _on_level_beaten(lives: int, total_score: int, _stars: int) -> void:
	pass


func _on_results_screen_calculated(new_high_score, stars) -> void:
	pass


func _on_results_screen_finished(total_score, extra_lives, stars) -> void:
	pass
