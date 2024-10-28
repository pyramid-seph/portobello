extends Node

const Ghost = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")


@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _audio_stream_sync := _audio_stream_player.stream as AudioStreamSynchronized
@onready var _ghosts: Array[Ghost] = [
		$"../YellowGhost",
		$"../BlueGhost",
		$"../RedGhost",
	]

var _time_since_player_ate: int
var _any_scared_ghost: bool


func _process(_delta: float) -> void:
	var old_any_scared_ghosts = _any_scared_ghost
	_any_scared_ghost = _ghosts.any(_is_ghost_scared)
	if old_any_scared_ghosts != _any_scared_ghost:
		_adjust_volumes()


func play() -> void:
	_audio_stream_player.play()
	var old_any_scared_ghosts = _any_scared_ghost
	_any_scared_ghost = _ghosts.any(_is_ghost_scared)
	if old_any_scared_ghosts != _any_scared_ghost:
		_adjust_volumes()


func stop() -> void:
	pass#_audio_stream_player.stop()

var _stream_01_tween: Tween
var _stream_02_tween: Tween
func _adjust_volumes() -> void:
	if _any_scared_ghost:
		if _stream_02_tween:
			_stream_02_tween.kill()
		_stream_02_tween = create_tween()
		#_audio_stream_sync.set_sync_stream_volume(2, linear_to_db(1.0))
		_stream_02_tween.tween_property(_audio_stream_sync, "stream_1/volume", linear_to_db(1.0), 0.48)
	else:
		if _stream_02_tween:
			_stream_02_tween.kill()
		
		_audio_stream_sync.set_sync_stream_volume(1, linear_to_db(0.0))
		#_stream_02_tween = create_tween()
		#_stream_02_tween.tween_property(_audio_stream_sync, "stream_2/volume", linear_to_db(0.0), 1.0)
		
		
	
	#if Time.get_ticks_msec() - _time_since_player_ate < 1_000 or _any_scared_ghost:
		#if _stream_01_tween:
			#_stream_01_tween.kill()
		##_audio_stream_sync.set_sync_stream_volume(1, linear_to_db(1.0))
		#_stream_01_tween.tween_property(_audio_stream_sync, "stream_1/volume", linear_to_db(1.0), 0.16)
	#else:
		#if _stream_01_tween:
			#_stream_01_tween.kill()
		##_audio_stream_sync.set_sync_stream_volume(1, linear_to_db(0.0))
		#_stream_01_tween.tween_property(_audio_stream_sync, "stream_1/volume", linear_to_db(0.0), 0.16)


func _is_ghost_scared(ghost: Ghost) -> bool:
	return ghost.is_scared()


func _on_day_02_player_ate_regular_treat() -> void:
	_time_since_player_ate = Time.get_ticks_msec()


func _on_day_02_player_ate_super_treat() -> void:
	_time_since_player_ate = Time.get_ticks_msec()


func _on_day_02_player_dying() -> void:
	pass#_audio_stream_player.stop()
