@tool
class_name Day03InteractiveBgm
extends Node


const NORMAL_STAMINA_PITCH: float = 1.0

@export var _song: AudioStream
@export var _player_data: Day03PlayerData:
	set(value):
		_player_data = value
		update_configuration_warnings()
@export_range(0.0, 1.0, 0.01) var _low_stamina_threshold: float = 0.5
@export_range(0.0, 2.0, 0.1) var _low_stamina_pitch: float = 1.2

var _audio_player: AudioStreamPlayer
var _low_stamina_points: float


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	_stop_if_playing()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if not _song:
		warnings.append("Set a song.")
	if not _player_data:
		warnings.append("Set a player data resource.")
	return warnings


func play_music() -> void:
	if not _player_data or not _song:
		return
	
	_low_stamina_points = _player_data.MAX_STAMINA * _low_stamina_threshold
	
	Utils.safe_connect(_player_data.stamina_updated, _update_pitch)
	_audio_player = SoundManager.play_music(_song)
	_update_pitch()


func stop_music(fade_out_duration_sec: float = 0.0) -> void:
	if not _player_data:
		return
	
	Utils.safe_disconnect(_player_data.stamina_updated, _update_pitch)
	_stop_if_playing()
	_audio_player = null


func _stop_if_playing(fade_out_duration_sec: float = 0.0) -> void:
	if _song and SoundManager.is_music_playing(_song):
		SoundManager.stop_music(fade_out_duration_sec)


func _update_pitch() -> void:
	if not _audio_player or not _player_data:
		return
	
	var is_stamina_low: bool = not _player_data.stamina > _low_stamina_points
	_audio_player.pitch_scale = \
			_low_stamina_pitch if is_stamina_low else NORMAL_STAMINA_PITCH
