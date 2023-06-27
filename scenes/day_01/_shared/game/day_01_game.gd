class_name Day01Game
extends Node2D


enum Level {
	STORY_MODE_LEVEL_01,
	SCORE_ATTACK_1A,
	SCORE_ATTACK_1B,
	SCORE_ATTACK_1C,
	SCORE_ATTACK_1D,
}

@export var _level: Day01Game.Level = Day01Game.Level.STORY_MODE_LEVEL_01

var _initial_lives: int = Day03PlayerData.MAX_LIVES


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _is_last_level() -> bool:
	return _level != Day01Game.Level.STORY_MODE_LEVEL_01


func _on_level_failed() -> void:
	_go_to_title_screen()


func _on_level_beaten(lives: int, total_score: int, _stars: int) -> void:
	pass


func _on_results_screen_calculated(new_high_score, stars) -> void:
	pass


func _on_results_screen_finished(total_score, extra_lives, stars) -> void:
	pass
