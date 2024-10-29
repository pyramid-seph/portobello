extends Node2D

const SFX_HEAT_SEEKER_CHARGING = preload("res://audio/sfx/sfx_motership_heat_seeker_charging.wav")

@export var target: Node2D
@export var world: Node2D
@export var is_active: bool:
	set(value):
		var old_is_active = is_active
		is_active = value
		if old_is_active != is_active:
			_on_is_active_changed()
@export var _cooldown_sec: float = 1.0
@export var _laser_sight_duration_sec: float = 1.0
@export var _warning_duration_sec: float = 1.0
@export var _time_between_bullets_sec: float = 1.0
@export var _time_between_bursts_sec: float = 1.0
@export var _bullets_per_burst: int = 1

var _tween: Tween

@onready var _gun := $Gun as Gun
@onready var _timer := $Timer as Timer
@onready var _laser_sight := $Gun/LaserSight as Line2D
@onready var _laser_sight_warning := $Gun/LaserSightWarning as Line2D
@onready var _is_ready: bool = true
@onready var _target_locked: bool = false


func _ready() -> void:
	_on_is_active_changed()
	_reset_sight()
	_gun.world = world


func _process(_delta: float) -> void:
	if is_active and not _target_locked and target:
		var sprite_size: Vector2 = target.size() if target.has_method("size") else Vector2.ZERO
		_gun.global_position.x = target.global_position.x + sprite_size.x / 2


func _exit_tree() -> void:
	SoundManager.stop_sound(SFX_HEAT_SEEKER_CHARGING)


func _activate() -> void:
	_seek_an_destroy()


func _deactivate() -> void:
	_reset_weapon()


func _reset_weapon() -> void:
	if _tween:
		_tween.kill()
	_reset_sight()
	_target_locked = false
	SoundManager.stop_sound(SFX_HEAT_SEEKER_CHARGING)
	if not _timer.is_stopped(): # Otherwise CONNECT_ONE_SHOT makes trouble.
		Utils.safe_disconnect_all(_timer.timeout)
		_timer.stop()


func _reset_sight() -> void:
	_laser_sight.visible = false
	_laser_sight_warning.visible = false


func _on_is_active_changed() -> void:
	if not _is_ready:
		return
	
	if is_active:
		_activate()
	else:
		_deactivate()


func _start_cooldown() -> void:
	_timer.start(_cooldown_sec)
	_timer.timeout.connect(_on_cooldown_timeout, CONNECT_ONE_SHOT)


func _shoot_burst() -> void:
	for i: int in _bullets_per_burst:
		if not is_active:
			break
		_gun.shoot(Vector2.DOWN)
		_timer.start(_time_between_bullets_sec)
		await _timer.timeout


func _shoot_gun() -> void:
	await _shoot_burst()
	
	if not is_active:
		return
	
	_timer.start(_time_between_bursts_sec)
	
	await _timer.timeout
	
	await _shoot_burst()
	
	if is_active:
		_reset_weapon()
		_start_cooldown()


func _seek_an_destroy() -> void:
	_tween = create_tween()
	var audio_player: AudioStreamPlayer = \
			SoundManager.play_sound(SFX_HEAT_SEEKER_CHARGING)
	_tween.parallel().tween_property(audio_player, "pitch_scale", 2.0,
			_laser_sight_duration_sec)
	_tween.parallel().tween_callback(func(): _laser_sight.visible = true)
	_tween.tween_interval(_laser_sight_duration_sec)
	_tween.tween_callback(func():
		_laser_sight_warning.visible = true
		_target_locked = true
	)
	_tween.tween_interval(_warning_duration_sec)
	_tween.tween_callback(func():
		SoundManager.stop_sound(SFX_HEAT_SEEKER_CHARGING)
		_reset_sight()
		_shoot_gun()
	)


func _on_cooldown_timeout() -> void:
	_reset_weapon()
	_seek_an_destroy()
