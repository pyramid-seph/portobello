class_name Day03Game
extends Node

const _CUTSCENE_PATH_DAY_01 = "res://scenes/day_03/_shared/cutscenes/cutscene_day_03_01.tscn"
const _LEVEL_PATH_FORMAT =  "res://scenes/day_03/_shared/level/day_03_level_%02d.tscn"

enum Level {
	STORY_MODE_DAY_01,
	STORY_MODE_DAY_02,
	SCORE_ATTACK_3A,
	SCORE_ATTACK_3B,
}

@export var _level: Day03Game.Level = Day03Game.Level.STORY_MODE_DAY_01
@export_group("Debug", "_debug")
@export var _debug_skip_cutscenes: bool = false:
	get:
		return _debug_skip_cutscenes and OS.is_debug_build()

var _level_instance: Day03Level

@onready var _results_screen := $ResultsScreenBuffet


func _ready() -> void:
	_start_minigame()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level


func _play_level() -> void:
	if _level_instance:
		_level_instance.queue_free()
	
	match _level:
		Day03Game.Level.STORY_MODE_DAY_01,\
		Day03Game.Level.SCORE_ATTACK_3A:
			_load_level(1)
		Day03Game.Level.SCORE_ATTACK_3B:
			_load_level(2)
		_:
			Game.start(Game.Minigame.TITLE_SCREEN)


func _start_minigame() -> void:
	if _debug_skip_cutscenes or _level != Day03Game.Level.STORY_MODE_DAY_01:
		_play_level()
	else:
		var old_scene = _get_level_scene()
		await SceneChanger.change_to_scene(_CUTSCENE_PATH_DAY_01, {}, old_scene)
		_get_level_scene().finished.connect(_play_level)


func _get_level_scene() -> Node:
	return Utils.last_child($Level)


func _load_level(level: int, lives: int = Day03PlayerData.MAX_LIVES) -> void:
	var path = _LEVEL_PATH_FORMAT % level
	var shared_data = { "lives": lives }
	await SceneChanger.change_to_scene(path, shared_data, _get_level_scene())
	_get_level_scene().completed.connect(_on_level_completed)


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
