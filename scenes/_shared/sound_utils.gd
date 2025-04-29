class_name SoundUtils
extends RefCounted

const SoundEffects = preload("res://addons/sound_manager/sound_effects.gd")


static func stop_all_sfx() -> void:
	var sound_effects := SoundManager.sound_effects as SoundEffects
	for audio_stream_player: AudioStreamPlayer in sound_effects.busy_players:
		sound_effects.stop(audio_stream_player.stream)


static func is_sfx_playing(sfx_sound: AudioStream) -> bool:
	if not sfx_sound:
		return false
	
	var sound_effects := SoundManager.sound_effects as SoundEffects
	return sound_effects.busy_players.any(
		func(player: AudioStreamPlayer):
			return player.stream.resource_path == sfx_sound.resource_path
	)


static func is_sfx_started_playing(sfx_sound: AudioStream, tolerance: float = 0.064) -> bool:
	if not sfx_sound:
		return false
	
	var sound_effects := SoundManager.sound_effects as SoundEffects
	return sound_effects.busy_players.any(
		func(player: AudioStreamPlayer):
			return player.stream.resource_path == sfx_sound.resource_path and \
					player.get_playback_position() < tolerance
	)


static func mute() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), true)


static func unmute() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), false)
