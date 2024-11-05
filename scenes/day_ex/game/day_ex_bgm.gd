extends Node


const DAY_EX_BGM_STREAM = preload("res://resources/instances/day_ex_bgm_stream.tres")


var _playback: AudioStreamPlaybackInteractive


func _exit_tree() -> void:
	stop_music()


func play_exploration_bgm() -> void:
	await _suspend_ensure_playing()
	_switch_to_exploration_stream()


func play_normal_battle_bgm() -> void:
	await _suspend_ensure_playing()
	_switch_to_normal_battle_stream()


func play_boss_battle_bgm() -> void:
	await _suspend_ensure_playing()
	_switch_to_boss_battle_stream()


func play_battle_won_bgm() -> void:
	await _suspend_ensure_playing()
	_switch_to_battle_won_stream()


func play_game_over_bgm() -> void:
	await _suspend_ensure_playing()
	_switch_to_game_over_stream()


func stop_music() -> void:
	_playback = null
	if SoundManager.is_music_playing(DAY_EX_BGM_STREAM):
		SoundManager.stop_music()


func _suspend_ensure_playing() -> void:
	if SoundManager.is_music_playing(DAY_EX_BGM_STREAM):
		return
	
	var audio_player: AudioStreamPlayer = \
			SoundManager.play_music(DAY_EX_BGM_STREAM)
	# Waiting for the next process frame so I don't get an error 
	# when trying to access the AudioStreamPlaybackInteractive.
	await get_tree().process_frame
	if SoundManager.is_music_playing(DAY_EX_BGM_STREAM):
		_playback = \
				audio_player.get_stream_playback() as AudioStreamPlaybackInteractive


func _switch_to_exploration_stream() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"exploration")


func _switch_to_normal_battle_stream() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"normal_battle")


func _switch_to_boss_battle_stream() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"boss_battle")


func _switch_to_battle_won_stream() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"battle_won")


func _switch_to_game_over_stream() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"game_over")
