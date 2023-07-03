extends "res://scenes/_shared/cutscenes/cutscene.gd"


# Override
func _play() -> void:
	finish()


# Override
func _clean_up() -> void:
	pass


func _on_finished() -> void:
	SceneChanger.change_to_scene(
		"res://scenes/day_01/_shared/game/day_01_game.tscn",
		{ "level": Day01Game.Level.STORY_MODE_LEVEL_01 }
	)
