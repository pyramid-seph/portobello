class_name Day03Game
extends Node

enum Level {
	STORY_MODE_DAY_01,
	STORY_MODE_DAY_02,
	SCORE_ATTACK_3A,
	SCORE_ATTACK_3B,
}

@export var _level: Day03Game.Level = Day03Game.Level.STORY_MODE_DAY_01
@export var _skip_cutscenes: bool = false

var _level_instance: Day03Level

@onready var is_ready: bool = true
@onready var _results_screen := $ResultsScreenBuffet


func _ready() -> void:
	play_level()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level
	if data.has("skip_cutscenes"):
		_skip_cutscenes = data.skip_cutscenes


func play_level() -> void:
	if _level_instance:
		_level_instance.queue_free()
	
	match _level:
		Day03Game.Level.STORY_MODE_DAY_01,\
		Day03Game.Level.SCORE_ATTACK_3A:
			_level_instance = load("res://scenes/day_03/_shared/level/day_03_level_01.tscn").instantiate() as Day03Level
			_level_instance.completed.connect(_on_level_completed)
			add_child(_level_instance)
		Day03Game.Level.SCORE_ATTACK_3B:
			_level_instance = load("res://scenes/day_03/_shared/level/day_03_level_02.tscn").instantiate() as Day03Level
			_level_instance.completed.connect(_on_level_completed)
			add_child(_level_instance)
		_:
			Game.start(Game.Minigame.TITLE_SCREEN)


func _get_high_score() -> int:
	match Game.get_level_instance():
		Day03Game.Level.STORY_MODE_DAY_01:
			return SaveDataManager.save_data.high_scores.day_three
		Day03Game.Level.SCORE_ATTACK_3A:
			return SaveDataManager.save_data.high_scores.buff_three_a
		Day03Game.Level.SCORE_ATTACK_3B:
			return SaveDataManager.save_data.high_scores.buff_three_b
		_:
			return 0


func _set_high_score(new_high_score: int) -> void:
	match Game.get_level_instance():
		Day03Game.Level.STORY_MODE_DAY_01:
			SaveDataManager.save_data.high_scores.day_three = new_high_score
		Day03Game.Level.SCORE_ATTACK_3A:
			SaveDataManager.save_data.high_scores.buff_three_a = new_high_score
		Day03Game.Level.SCORE_ATTACK_3B:
			SaveDataManager.save_data.high_scores.buff_three_b = new_high_score


func _set_stars(stars: int) -> void:
	var new_stars_max = maxi(stars, SaveDataManager.save_data.stars.day_three)
	if _level == Day03Game.Level.STORY_MODE_DAY_02:
		SaveDataManager.save_data.stars.day_three = new_stars_max


func _on_level_completed(lives: int, score: int) -> void:
	_results_screen.is_last_level = true # TODO
	var high_score = _get_high_score()
	var total_score = _results_screen.start(
		lives, 
		score,
		high_score
	)
	if total_score > high_score:
		_set_high_score(high_score)
	_set_stars(0)
	SaveDataManager.save()


func _on_results_screen_results_presented(total_score) -> void:
	if _level == Day03Game.Level.STORY_MODE_DAY_01:
		pass # load next level if level 1 (and pass current score and lives!);
			# otherwise load credits with Game.start(Day03Game.Level.CREDITS)
	else:
		Game.start(Game.Minigame.TITLE_SCREEN)
