extends Node


const STORY_MODE_LEVELS: Array[Day01Game.Level] = [
	Day01Game.Level.STORY_MODE_LEVEL_01,
	Day01Game.Level.STORY_MODE_LEVEL_02,
	Day01Game.Level.STORY_MODE_LEVEL_03,
	Day01Game.Level.STORY_MODE_LEVEL_04,
	Day01Game.Level.STORY_MODE_LEVEL_05,
	Day01Game.Level.STORY_MODE_LEVEL_06,
	Day01Game.Level.STORY_MODE_LEVEL_07,
	Day01Game.Level.STORY_MODE_LEVEL_08,
]

@export_category("Settings Story Mode")
@export var _lvl_settings_story_01: Day01LevelSettings
@export var _lvl_settings_story_02: Day01LevelSettings
@export var _lvl_settings_story_03: Day01LevelSettings
@export var _lvl_settings_story_04: Day01LevelSettings
@export var _lvl_settings_story_05: Day01LevelSettings
@export var _lvl_settings_story_06: Day01LevelSettings
@export var _lvl_settings_story_07: Day01LevelSettings
@export var _lvl_settings_story_08: Day01LevelSettings

@export_category("Settings Score Attack")
@export var _lvl_settings_score_attack_1a: Day01LevelSettings
@export var _lvl_settings_score_attack_1b: Day01LevelSettings
@export var _lvl_settings_score_attack_1c: Day01LevelSettings
@export var _lvl_settings_score_attack_1d: Day01LevelSettings


func get_game_mode(level: Day01Game.Level) -> Game.Mode:
	if STORY_MODE_LEVELS.has(level):
		return Game.Mode.STORY
	else:
		return Game.Mode.SCORE_ATTACK


func get_settings(level: Day01Game.Level) -> Day01LevelSettings:
	match level:
		Day01Game.Level.STORY_MODE_LEVEL_01:
			return _lvl_settings_story_01
		Day01Game.Level.STORY_MODE_LEVEL_02:
			return _lvl_settings_story_02
		Day01Game.Level.STORY_MODE_LEVEL_03:
			return _lvl_settings_story_03
		Day01Game.Level.STORY_MODE_LEVEL_04:
			return _lvl_settings_story_04
		Day01Game.Level.STORY_MODE_LEVEL_05:
			return _lvl_settings_story_05
		Day01Game.Level.STORY_MODE_LEVEL_06:
			return _lvl_settings_story_06
		Day01Game.Level.STORY_MODE_LEVEL_07:
			return _lvl_settings_story_07
		Day01Game.Level.STORY_MODE_LEVEL_08:
			return _lvl_settings_story_08
		Day01Game.Level.SCORE_ATTACK_1A:
			return _lvl_settings_score_attack_1a
		Day01Game.Level.SCORE_ATTACK_1B:
			return _lvl_settings_score_attack_1b
		Day01Game.Level.SCORE_ATTACK_1C:
			return _lvl_settings_score_attack_1c
		Day01Game.Level.SCORE_ATTACK_1D:
			return _lvl_settings_score_attack_1d
		_:
			return _lvl_settings_score_attack_1a


func is_last_level(level: Day01Game.Level) -> bool:
	return level == Day01Game.Level.STORY_MODE_LEVEL_08 or \
			not STORY_MODE_LEVELS.has(level)


func get_next_level(level: Day01Game.Level) -> Day01Game.Level:
	var idx = STORY_MODE_LEVELS.find(level)
	if idx == -1 or idx == STORY_MODE_LEVELS.size() - 1:
		return -1 # TODO Cannot return -1: no enum member has matching value
	return STORY_MODE_LEVELS[idx + 1]


func get_lvl_index(level: Day01Game.Level) -> int:
	return maxi(STORY_MODE_LEVELS.find(level), 0)
