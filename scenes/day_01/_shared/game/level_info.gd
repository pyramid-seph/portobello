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


func is_story_mode_level(level: Day01Game.Level) -> bool:
	return STORY_MODE_LEVELS.has(level)


func is_score_attack_mode_level(level: Day01Game.Level) -> bool:
	return not is_story_mode_level(level)


func get_game_mode(level: Day01Game.Level) -> Game.Mode:
	if is_story_mode_level(level):
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


## Returns the next level. If it returns curr_level,
## then there is no next level.
func get_next_level(curr_level: Day01Game.Level) -> Day01Game.Level:
	var idx = STORY_MODE_LEVELS.find(curr_level)
	if idx == -1 or idx == STORY_MODE_LEVELS.size() - 1:
		return curr_level
	return STORY_MODE_LEVELS[idx + 1]


func get_lvl_index(level: Day01Game.Level) -> int:
	return maxi(STORY_MODE_LEVELS.find(level), 0)


func get_level_count_for_mode(game_mode: Game.Mode) -> int:
	if game_mode == Game.Mode.STORY:
		return STORY_MODE_LEVELS.size()
	else:
		return -1


func get_high_score(level: Day01Game.Level) -> int:
	match level:
		Day01Game.Level.SCORE_ATTACK_1A:
			return SaveDataManager.save_data.high_scores.buff_one_a
		Day01Game.Level.SCORE_ATTACK_1B:
			return SaveDataManager.save_data.high_scores.buff_one_b
		Day01Game.Level.SCORE_ATTACK_1C:
			return SaveDataManager.save_data.high_scores.buff_one_c
		Day01Game.Level.SCORE_ATTACK_1D:
			return SaveDataManager.save_data.high_scores.buff_one_d
		_:
			return -1


func set_high_score(level: Day01Game.Level, score: int, force: bool = false) -> bool:
	var changed: bool = false
	if force or score > get_high_score(level):
		match level:
			Day01Game.Level.SCORE_ATTACK_1A:
				changed = true
				SaveDataManager.save_data.high_scores.buff_one_a = score
			Day01Game.Level.SCORE_ATTACK_1B:
				changed = true
				SaveDataManager.save_data.high_scores.buff_one_b = score
			Day01Game.Level.SCORE_ATTACK_1C:
				changed = true
				SaveDataManager.save_data.high_scores.buff_one_c = score
			Day01Game.Level.SCORE_ATTACK_1D:
				changed = true
				SaveDataManager.save_data.high_scores.buff_one_d = score
	
	if changed:
		SaveDataManager.save()
	return changed


func set_stars(stars: int, force: bool = false) -> bool:
	var changed: bool = false
	if force or stars > SaveDataManager.save_data.stars.day_one:
		changed = true
		SaveDataManager.save_data.stars.day_one = stars
	
	if changed:
		SaveDataManager.save()
	return changed


func set_story_mode_beaten(force: bool = false) -> bool:
	var changed: bool = false
	if force or SaveDataManager.save_data.latest_day_completed < 1:
		changed = true
		SaveDataManager.save_data.latest_day_completed = 1
	
	if changed:
		SaveDataManager.save()
	return changed
