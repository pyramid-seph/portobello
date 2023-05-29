class_name Day03Game
extends Node

enum Level {
	NONE,
	STORY_MODE_DAY_01,
	STORY_MODE_DAY_02,
	SCORE_ATTACK_3A,
	SCORE_ATTACK_3B,
}

@export_group("Debug", "_debug")
@export_enum("level_one", "level_two")
var _debug_level: String = "level_one"
@export var _debug_skip_cutscenes: bool = false

var _current_level: Day03Level

@onready var is_ready: bool = true
@onready var _results_screen := $ResultsScreenBuffet


func _ready() -> void:
	play_level()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		pass # TODO
	if data.has("debug_skip_cutscenes"):
		_debug_skip_cutscenes = data.debug_skip_cutscenes


func play_level() -> void:
	if _current_level:
		_current_level.queue_free()
	
	match Game.get_current_minigame():
		Game.Minigame.STORY_DAY_03, Game.Minigame.SCORE_ATTACK_3A:
			_current_level = load("res://scenes/day_03/_shared/level/day_03_level_01.tscn").instantiate() as Day03Level
			_current_level.completed.connect(_on_level_completed)
			add_child(_current_level)
		Game.Minigame.SCORE_ATTACK_3B:
			_current_level = load("res://scenes/day_03/_shared/level/day_03_level_02.tscn").instantiate() as Day03Level
			_current_level.completed.connect(_on_level_completed)
			add_child(_current_level)
		_:
			if OS.is_debug_build():
				match _debug_level:
					"level_one":
						_current_level = load("res://scenes/day_03/_shared/level/day_03_level_01.tscn").instantiate() as Day03Level
						_current_level.completed.connect(_on_level_completed)
						add_child(_current_level)
					"level_two":
						_current_level = load("res://scenes/day_03/_shared/level/day_03_level_02.tscn").instantiate() as Day03Level
						_current_level.completed.connect(_on_level_completed)
						add_child(_current_level)
					_:
						print("Unknown debug level. Quitting game.")
						get_tree().quit()
			else:
				print("This is not a level of this minigame. Returning to title screen.")
				Game.start(Game.Minigame.TITLE_SCREEN)


func _get_high_score() -> int:
	match Game.get_current_level():
		Game.Minigame.STORY_DAY_03:
			return SaveDataManager.save_data.high_scores.day_three
		Game.Minigame.SCORE_ATTACK_3A:
			return SaveDataManager.save_data.high_scores.buff_three_a
		Game.Minigame.SCORE_ATTACK_3B:
			return SaveDataManager.save_data.high_scores.buff_three_b
		_:
			return 0


func _set_high_score(new_high_score: int) -> void:
	match Game.get_current_level():
		Game.Minigame.STORY_DAY_03:
			SaveDataManager.save_data.high_scores.day_three = new_high_score
		Game.Minigame.SCORE_ATTACK_3A:
			SaveDataManager.save_data.high_scores.buff_three_a = new_high_score
		Game.Minigame.SCORE_ATTACK_3B:
			SaveDataManager.save_data.high_scores.buff_three_b = new_high_score


func _set_stars(stars: int) -> void:
	var new_stars_max = maxi(stars, SaveDataManager.save_data.stars.day_three)
	if Game.get_current_level() == Game.Minigame.STORY_DAY_03: # and is_last_level
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
	if Game.get_current_level() == Game.Minigame.STORY_DAY_03:
		pass # load next level if level 1 (and pass current score and lives!);
			# otherwise load credits with Game.start(Game.Minigame.CREDITS)
	else:
		Game.start(Game.Minigame.TITLE_SCREEN)
