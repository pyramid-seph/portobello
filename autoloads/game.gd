extends Node

enum Minigame {
	TITLE_SCREEN,
	STORY_DAY_01,
	STORY_DAY_02,
	STORY_DAY_03,
	STORY_EXTRA,
	SCORE_ATTACK_1A,
	SCORE_ATTACK_1B,
	SCORE_ATTACK_1C,
	SCORE_ATTACK_1D,
	SCORE_ATTACK_2,
	SCORE_ATTACK_3A,
	SCORE_ATTACK_3B,
	CREDITS,
}

var is_pause_disabled: bool
var is_cold_boot: bool = true

var _current_minigame: Minigame = Minigame.TITLE_SCREEN


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func get_current_minigame() -> Minigame:
	return _current_minigame


func start(level: Minigame) -> void:
	if _current_minigame == level:
		return
	_current_minigame = level
	var path = _get_scene_file_path(level)
	var minigame_start_level = _get_minigame_start_level(level)
	SceneChanger.change_to_scene(path, { "level": minigame_start_level })


func _get_scene_file_path(minigame: Minigame) -> String:
	match minigame:
		Minigame.STORY_DAY_03, \
		Minigame.SCORE_ATTACK_3A, \
		Minigame.SCORE_ATTACK_3B:
			return "res://scenes/day_03/_shared/game/day_03_game.tscn"
		_:
			return "res://scenes/_shared/title_screen/title_screen_scene.tscn"


func _get_minigame_start_level(minigame: Minigame) -> int:
	match minigame:
		Minigame.STORY_DAY_03:
			return Day03Game.Level.STORY_MODE_DAY_01
		Minigame.SCORE_ATTACK_3A:
			return Day03Game.Level.SCORE_ATTACK_3A
		Minigame.SCORE_ATTACK_3B:
			return Day03Game.Level.SCORE_ATTACK_3B
		_:
			return -1
