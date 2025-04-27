extends Node


func _exit_tree() -> void:
	stop_music()


func stop_music() -> void:
	SoundManager.stop_music()


func play_exploration_bgm() -> void:
	pass # NOOP


func play_normal_battle_bgm() -> void:
	pass # NOOP


func play_boss_battle_bgm() -> void:
	pass # NOOP


func play_battle_won_bgm() -> void:
	pass # NOOP


func play_game_over_bgm() -> void:
	pass # NOOP
