extends Node

enum Mode { 
	SCORE_ATTACK,
	STORY,
}

enum Minigame {
	TITLE_SCREEN,
	STORY_DAY_01,
	STORY_DAY_02,
	STORY_DAY_03,
	STORY_DAY_EX,
	SCORE_ATTACK_1A,
	SCORE_ATTACK_1B,
	SCORE_ATTACK_1C,
	SCORE_ATTACK_1D,
	SCORE_ATTACK_2,
	SCORE_ATTACK_3A,
	SCORE_ATTACK_3B,
	CREDITS,
}

var is_cold_boot: bool = true

var _current_minigame: Minigame = Minigame.TITLE_SCREEN


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	TranslationServer.set_locale(SaveDataManager.save_data.language)


func start(minigame: Minigame, allow_restart := false) -> void:
	if _current_minigame == minigame and not allow_restart:
		return
	_current_minigame = minigame
	var path = _get_start_path(minigame)
	var minigame_start_level = _get_minigame_start_level(minigame)
	var shared_data = {}
	if minigame_start_level > -1:
		shared_data["level"] = minigame_start_level
	SceneChanger.change_to_scene(path, shared_data)


func _get_start_path(minigame: Minigame) -> String:
	match minigame:
		Minigame.STORY_DAY_01:
			return "res://scenes/day_01/_shared/cutscenes/cutscene_day_01_01.tscn"
		Minigame.STORY_DAY_02:
			return "res://scenes/day_02/_shared/cutscenes/cutscene_day_02_01.tscn"
		Minigame.STORY_DAY_03:
			return "res://scenes/day_03/_shared/cutscenes/cutscene_day_03_01.tscn"
		Minigame.SCORE_ATTACK_1A, \
		Minigame.SCORE_ATTACK_1B, \
		Minigame.SCORE_ATTACK_1C, \
		Minigame.SCORE_ATTACK_1D:
			return "res://scenes/day_01/_shared/game/day_01_game.tscn"
		Minigame.SCORE_ATTACK_2:
			return "res://scenes/day_02/_shared/game/day_02_game.tscn"
		Minigame.SCORE_ATTACK_3A, \
		Minigame.SCORE_ATTACK_3B:
			return "res://scenes/day_03/_shared/game/day_03_game.tscn"
		Minigame.CREDITS:
			return "res://scenes/_shared/cutscenes/cutscene_credits.tscn"
		_:
			return "res://scenes/_shared/title_screen/title_screen_scene.tscn"


func _get_minigame_start_level(minigame: Minigame) -> int:
	match minigame:
		Minigame.STORY_DAY_01:
			return Day01Game.Level.STORY_MODE_LEVEL_01
		Minigame.SCORE_ATTACK_1A:
			return Day01Game.Level.SCORE_ATTACK_1A
		Minigame.SCORE_ATTACK_1B:
			return Day01Game.Level.SCORE_ATTACK_1B
		Minigame.SCORE_ATTACK_1C:
			return Day01Game.Level.SCORE_ATTACK_1C
		Minigame.SCORE_ATTACK_1D:
			return Day01Game.Level.SCORE_ATTACK_1D
		Minigame.STORY_DAY_02:
			return Day02Game.Level.STORY_MODE_LEVEL_01
		Minigame.SCORE_ATTACK_2:
			return Day02Game.Level.SCORE_ATTACK_MODE_LEVEL_01
		Minigame.STORY_DAY_03:
			return Day03Game.Level.STORY_MODE_DAY_01
		Minigame.SCORE_ATTACK_3A:
			return Day03Game.Level.SCORE_ATTACK_3A
		Minigame.SCORE_ATTACK_3B:
			return Day03Game.Level.SCORE_ATTACK_3B
		_:
			return -1
