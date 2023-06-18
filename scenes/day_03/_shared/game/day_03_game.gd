class_name Day03Game
extends Node

enum Level {
	STORY_MODE_DAY_01,
	STORY_MODE_DAY_02,
	SCORE_ATTACK_3A,
	SCORE_ATTACK_3B,
}

@export var _paca: PackedScene
@export var _level: Day03Game.Level = Day03Game.Level.STORY_MODE_DAY_01

var _initial_lives: int = Day03PlayerData.MAX_LIVES

@onready var _results_screen := $ResultsScreenBuffet
@onready var _level_01_placeholder : InstancePlaceholder = $Day03Level01
@onready var _level_02_placeholder : InstancePlaceholder = $Day03Level02


func _ready() -> void:
	_play_level()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level
	if data.has("lives"):
		_initial_lives = data.lives


func _play_level() -> void:
	var mode = null
	var level_instance: Day03Level = null
	match _level:
		Day03Game.Level.STORY_MODE_DAY_01:
			level_instance = _level_01_placeholder.create_instance()
			mode = Day03Level.GameMode.STORY
		Day03Game.Level.STORY_MODE_DAY_02:
			level_instance = _level_02_placeholder.create_instance()
			mode = Day03Level.GameMode.STORY
		Day03Game.Level.SCORE_ATTACK_3A:
			level_instance = _level_01_placeholder.create_instance()
			mode = Day03Level.GameMode.SCORE_ATTACK
		Day03Game.Level.SCORE_ATTACK_3B:
			level_instance = _level_02_placeholder.create_instance()
			mode = Day03Level.GameMode.SCORE_ATTACK
		_:
			_go_to_title_screen()
	
	if level_instance:
		level_instance.failed.connect(_on_level_failed)
		level_instance.completed.connect(_on_level_completed)
		level_instance.set_lives(_initial_lives)
		level_instance.game_mode = mode


func _get_high_score() -> int:
	match _level:
		Day03Game.Level.STORY_MODE_DAY_01:
			return SaveDataManager.save_data.high_scores.day_three
		Day03Game.Level.SCORE_ATTACK_3A:
			return SaveDataManager.save_data.high_scores.buff_three_a
		Day03Game.Level.SCORE_ATTACK_3B:
			return SaveDataManager.save_data.high_scores.buff_three_b
		_:
			return 0


func _set_high_score(new_high_score: int) -> void:
	match _level:
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


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _on_level_completed(lives: int, score: int) -> void:
	_results_screen.is_last_level = _level == Day03Game.Level.STORY_MODE_DAY_02
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


func _on_level_failed() -> void:
	_go_to_title_screen()


func _on_results_screen_results_presented(total_score) -> void:
	if _level == Day03Game.Level.STORY_MODE_DAY_01:
		SceneChanger.change_to_scene(
				"res://scenes/day_03/_shared/game/day_03_game.tscn",
				 { "level": Level.STORY_MODE_DAY_02, "lives": 8 }
		)
	elif  _level == Day03Game.Level.STORY_MODE_DAY_02:
		Game.start(Game.Minigame.CREDITS)
	else:
		_go_to_title_screen()
