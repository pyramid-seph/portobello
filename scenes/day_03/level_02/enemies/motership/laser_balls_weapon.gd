extends Node2D

const SFX_CANNONS_FIRED = preload("res://audio/sfx/sfx_motership_laser_ball_cannon_fired.wav")
const SFX_CANNONS_CHARGING = preload("res://audio/sfx/sfx_motership_laser_ball_cannon_charging.wav")

@export var _cooldown: float = 1.0
@export var is_active: bool:
	set(value):
		var old_is_active = is_active
		is_active = value
		if old_is_active != is_active:
			_on_is_active_changed()

var _charging_sound_pitch_tween: Tween
var _pattern: Array[LaserBallsCannon]

@onready var _cannon_0 := $LaserBallsCannon0
@onready var _cannon_1 := $LaserBallsCannon1
@onready var _cannon_2 := $LaserBallsCannon2
@onready var _cannon_3 := $LaserBallsCannon3
@onready var _timer: Timer = $Timer


func _ready() -> void:
	_on_is_active_changed()


func _exit_tree() -> void:
	SoundManager.stop_sound(SFX_CANNONS_FIRED)
	SoundManager.stop_sound(SFX_CANNONS_CHARGING)


func _activate() -> void:
	_timer.start(_cooldown)


func _deactivate() -> void:
	if _charging_sound_pitch_tween:
		_charging_sound_pitch_tween.kill()
	SoundManager.stop_sound(SFX_CANNONS_CHARGING)
	_cannon_0.deactivate()
	_cannon_1.deactivate()
	_cannon_2.deactivate()
	_cannon_3.deactivate()
	_pattern.clear()
	_timer.stop()


func _on_is_active_changed() -> void:
	if not is_node_ready():
		return
	
	if is_active:
		_activate()
	else:
		_deactivate()


func _randomize_cannons_charge() -> void:
	_pattern.clear()
	var pattern: int = randi() % 13
	match pattern:
		0:
			_pattern.append(_cannon_0)
		1:
			_pattern.append(_cannon_1)
		2:
			_pattern.append(_cannon_2)
		3:
			_pattern.append(_cannon_3)
		4:
			_pattern.append(_cannon_0)
			_pattern.append(_cannon_1)
		5:
			_pattern.append(_cannon_0)
			_pattern.append(_cannon_2)
		6:
			_pattern.append(_cannon_0)
			_pattern.append(_cannon_3)
		7:
			_pattern.append(_cannon_1)
			_pattern.append(_cannon_2)
		8:
			_pattern.append(_cannon_1)
			_pattern.append(_cannon_3)
		9:
			_pattern.append(_cannon_2)
			_pattern.append(_cannon_3)
		10:
			_pattern.append(_cannon_0)
			_pattern.append(_cannon_1)
			_pattern.append(_cannon_2)
		11:
			_pattern.append(_cannon_0)
			_pattern.append(_cannon_2)
			_pattern.append(_cannon_3)
		12:
			_pattern.append(_cannon_0)
			_pattern.append(_cannon_1)
			_pattern.append(_cannon_3)


func _on_timer_timeout() -> void:
	_randomize_cannons_charge()
	
	var charge_duration_sec: float = 0.0
	if not _pattern.is_empty():
		charge_duration_sec = _pattern[0].get_charging_duration_sec()
	
	var audio_player := SoundManager.play_sound(SFX_CANNONS_CHARGING)
	if _charging_sound_pitch_tween:
		_charging_sound_pitch_tween.kill()
	_charging_sound_pitch_tween = create_tween()
	_charging_sound_pitch_tween.tween_property(audio_player, "pitch_scale",
			1.2, charge_duration_sec)
	
	for cannon: LaserBallsCannon in _pattern:
		cannon.charge()


func _on_laser_balls_cannon_target_detected(_target: Node2D) -> void:
	if _charging_sound_pitch_tween:
		_charging_sound_pitch_tween.kill()
	
	SoundManager.stop_sound(SFX_CANNONS_CHARGING)
	SoundManager.play_sound(SFX_CANNONS_FIRED)
	for cannon: LaserBallsCannon in _pattern:
		cannon.fire()


func _on_laser_balls_cannon_discharged() -> void:
	if _pattern.all(func(cannon): return cannon.is_discharged()):
		if _charging_sound_pitch_tween:
			_charging_sound_pitch_tween.kill()
		
		SoundManager.stop_sound(SFX_CANNONS_CHARGING)
		_timer.start(_cooldown)
