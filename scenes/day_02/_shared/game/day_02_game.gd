class_name Day02Game
extends Node

enum Level {
	STORY_MODE_LEVEL_01,
	STORY_MODE_LEVEL_02,
	STORY_MODE_LEVEL_03,
	SCORE_ATTACK_MODE,
}

@export var _level: Day02Game.Level

@onready var _is_ready: bool = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("fire"):
		Game.start(Game.Minigame.TITLE_SCREEN)


func set_shared_data(data: Dictionary = {}) -> void:
	if data.has("level"):
		_level = data.level
