@tool
extends Node


const Ghost = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")

const MUTE_DB: float = -60.0
const COMBO_STREAM_DURATION_SEC: float = 1.0
const INDEX_BASE_STREAM: int = 0
const INDEX_COMBO_STREAM: int = 1
const INDEX_SCARE_STREAM: int = 2

@export var _base_stream: AudioStream:
	set(value):
		_base_stream = value
		update_configuration_warnings()
@export var _combo_stream: AudioStream:
	set(value):
		_combo_stream = value
		update_configuration_warnings()
@export var _scare_stream: AudioStream:
	set(value):
		_scare_stream = value
		update_configuration_warnings()

var _combo_stream_timer: float
var _combo_stream_switch := Switch.new()
var _scare_stream_switch := Switch.new()
var _sync_audio: AudioStreamSynchronized
var _tweens: Dictionary

@onready var _ghosts: Array[Ghost] = [
		$"../YellowGhost",
		$"../BlueGhost",
		$"../RedGhost",
	]


func _init() -> void:
	if Engine.is_editor_hint():
		set_process(false)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if _base_stream and _combo_stream and _scare_stream:
		_sync_audio = AudioStreamSynchronized.new()
		_sync_audio.stream_count = 3
		_sync_audio.set_sync_stream(INDEX_BASE_STREAM, _base_stream)
		_sync_audio.set_sync_stream(INDEX_COMBO_STREAM, _combo_stream)
		_sync_audio.set_sync_stream_volume(INDEX_COMBO_STREAM, MUTE_DB)
		_sync_audio.set_sync_stream(INDEX_SCARE_STREAM, _scare_stream)
		_sync_audio.set_sync_stream_volume(INDEX_SCARE_STREAM, MUTE_DB)


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		stop()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not _sync_audio:
		return
	
	_combo_stream_timer = maxf(0.0, _combo_stream_timer - delta)
	
	if Engine.get_process_frames() % 5:
		_scare_stream_switch.is_on = _ghosts.any(_is_ghost_scared)
		_combo_stream_switch.is_on = _combo_stream_timer > 0


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if not _base_stream:
		warnings.append("Base stream required.")
	if not _combo_stream:
		warnings.append("Combo stream required.")
	if not _scare_stream:
		warnings.append("Scare stream required.")
	return warnings


func play() -> void:
	if not _sync_audio or _is_playing():
		return
	
	_combo_stream_switch.set_is_on_no_signal(false)
	_scare_stream_switch.set_is_on_no_signal(false)
	
	Utils.safe_connect(_combo_stream_switch.switched, _on_combo_switch_switched)
	Utils.safe_connect(_scare_stream_switch.switched, _on_scare_switch_switched)
	
	_combo_stream_timer = 0.0
	
	_sync_audio.set_sync_stream_volume(INDEX_COMBO_STREAM, MUTE_DB)
	_sync_audio.set_sync_stream_volume(INDEX_SCARE_STREAM, MUTE_DB)
	
	SoundManager.play_music(_sync_audio)
	set_process(true)


func stop() -> void:
	if not _sync_audio:
		return
	
	Utils.safe_disconnect(_combo_stream_switch.switched,
			_on_combo_switch_switched)
	Utils.safe_disconnect(_scare_stream_switch.switched,
			_on_scare_switch_switched)
	
	for tween: Tween in _tweens.values():
		tween.kill()
	_tweens.clear()
	
	if _is_playing():
		SoundManager.stop_music()
	
	set_process(false)


func _is_playing() -> bool:
	return _sync_audio and SoundManager.is_music_playing(_sync_audio)


func _is_ghost_scared(ghost: Ghost) -> bool:
	return ghost.is_scared()


func _switch_on_stream(stream_index: int, switch_on: bool) -> void:
	var tween: Tween = _tweens.get(stream_index)
	if tween:
		tween.kill()
	tween = create_tween()
	_tweens[stream_index] = tween
	
	var volume_prop: String = "stream_%d/volume" % stream_index
	if switch_on:
		tween.tween_property(_sync_audio, volume_prop, 0, 0.1).set_trans(
				Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(_sync_audio, volume_prop, MUTE_DB, 0.1).set_trans(
				Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)


func _on_combo_switch_switched() -> void:
	_switch_on_stream(INDEX_COMBO_STREAM, _combo_stream_switch.is_on)


func _on_scare_switch_switched() -> void:
	_switch_on_stream(INDEX_SCARE_STREAM, _scare_stream_switch.is_on)


func _on_player_ate_treat() -> void:
	_combo_stream_timer = COMBO_STREAM_DURATION_SEC
