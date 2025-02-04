class_name Day03Game
extends Node

enum Level {
	STORY_MODE_DAY_01,
	STORY_MODE_DAY_02,
	SCORE_ATTACK_3A,
	SCORE_ATTACK_3B,
}

@export var _level: Day03Game.Level = Day03Game.Level.STORY_MODE_DAY_01

var _initial_lives: int = Day03PlayerData.MAX_LIVES
var _initial_score: int

@onready var _level_01_placeholder : InstancePlaceholder = $Day03Level01
@onready var _level_02_placeholder : InstancePlaceholder = $Day03Level02


func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY
	_play_level()


func _exit_tree() -> void:
	SoundUtils.stop_all_sfx()


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level
	if data.has("lives"):
		_initial_lives = data.lives
	if data.has("score"):
		_initial_score = data.score


func _play_level() -> void:
	var mode = null
	var level_instance: Day03Level = null
	var level_index = 0
	match _level:
		Day03Game.Level.STORY_MODE_DAY_01:
			level_instance = _level_01_placeholder.create_instance()
			mode = Game.Mode.STORY
		Day03Game.Level.STORY_MODE_DAY_02:
			level_instance = _level_02_placeholder.create_instance()
			level_index = 1
			mode = Game.Mode.STORY
		Day03Game.Level.SCORE_ATTACK_3A:
			level_instance = _level_01_placeholder.create_instance()
			mode = Game.Mode.SCORE_ATTACK
		Day03Game.Level.SCORE_ATTACK_3B:
			level_instance = _level_02_placeholder.create_instance()
			mode = Game.Mode.SCORE_ATTACK
		_:
			_go_to_title_screen()
	
	if level_instance:
		level_instance.failed.connect(_on_level_failed)
		level_instance.beaten.connect(_on_level_beaten)
		level_instance.start(
			mode,
			level_index,
			_is_last_level(),
			_initial_lives,
			_initial_score,
		)


func _go_to_title_screen() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)


func _is_last_level() -> bool:
	return _level != Day03Game.Level.STORY_MODE_DAY_01


func _on_level_failed() -> void:
	_go_to_title_screen()


func _on_level_beaten(lives: int, total_score: int, _stars: int) -> void:
	if _level == Day03Game.Level.STORY_MODE_DAY_01:
		SceneChanger.change_to_scene(
				"res://scenes/day_03/_shared/game/day_03_game.tscn",
				{
					"level": Level.STORY_MODE_DAY_02, 
					"lives": lives,
					"score": total_score
				}
		)
	elif  _level == Day03Game.Level.STORY_MODE_DAY_02:
		Game.start(Game.Minigame.CREDITS)
	else:
		_go_to_title_screen()
