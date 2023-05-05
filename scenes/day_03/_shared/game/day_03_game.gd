class_name Day03Game
extends Node

enum Mode {
	STORY,
	SCORE_ATTACK,
}

enum Level {
	LEVEL_1,
	LEVEL_2,
}

@export var mode: Day03Game.Mode
@export var level: Day03Game.Level


func _on_level_completed(lives: int, score: int) -> void:
	pass


#func _on_boss_dead() -> void:
#	_stamina_spawner.disable()
#	_power_up_spawner.disable()
#	_player.stop_stamina_lose(true)
#	_level_state = LevelState.LEVEL_COMPLETE
#	get_tree().create_timer(RESULTS_SCREEN_DELAY, false).timeout.connect(func():
#		# TODO Destroy or disable the current _world, game systems and interface.
#		_player.is_input_enabled = false
#		_results_screen.is_last_level = true # TODO
#		var total_score = _results_screen.start(
#			_player_data.lives, 
#			_player_data.score,
#			SaveDataManager.save_data.high_scores.buff_three_a
#		)
#		# TODO high scores are stored for different levels and modes.
#		if total_score > SaveDataManager.save_data.high_scores.buff_three_a:
#			SaveDataManager.save_data.high_scores.buff_three_a = total_score
#			SaveDataManager.save()
#	)



#func _on_results_screen_buffet_results_presented(total_score: int) -> void:
#	# show level complete screen. On story mode add as much lives as awarded on this level
#	# On buffet mode, load the title screen
#	# On story mode, load the next level
#	pass
