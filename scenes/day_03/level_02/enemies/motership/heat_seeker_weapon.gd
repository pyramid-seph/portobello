extends Node2D

@export var target: Node2D:
	set(value):
		target = value
@export var is_active: bool:
	set(value):
		var old_is_active = is_active
		is_active = value
		if old_is_active != is_active:
			_on_set_is_active()
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
	_on_set_is_active()
	_reset_sight()
	_gun.world = get_parent() # TODO


func _process(_delta: float) -> void:
	if is_active and not _target_locked and target:
		var sprite_size: Vector2 = target.size() if target.has_method("size") else Vector2.ZERO
		_gun.global_position.x = target.global_position.x + sprite_size.x / 2


func _activate() -> void:
	_start_cooldown()


func _deactivate() -> void:
	_timer.stop()
	_reset_weapon()


func _reset_weapon() -> void:
	if _tween:
		_tween.kill()
	_reset_sight()
	_target_locked = false


func _reset_sight() -> void:
	_laser_sight.visible = false
	_laser_sight_warning.visible = false


func _on_set_is_active() -> void:
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
	for i in _bullets_per_burst:
		if not is_active:
			break
		_gun.shoot(Vector2.DOWN)
		_timer.start(_time_between_bullets_sec)
		await _timer.timeout # TODO Can this await be interrupted on deactivate?


func _shoot_gun() -> void:
	await _shoot_burst()
	
	if not is_active:
		return
	
	_timer.start(_time_between_bursts_sec)
	await _timer.timeout # TODO Can this await be interrupted on deactivate?
	
	await _shoot_burst()
	
	if is_active:
		_reset_weapon()
		_start_cooldown()


func _on_cooldown_timeout() -> void:
	_reset_weapon()
	_tween = create_tween()
	_tween.tween_callback(func(): _laser_sight.visible = true)
	_tween.tween_interval(_laser_sight_duration_sec)
	_tween.tween_callback(func():
		_laser_sight_warning.visible = true
		_target_locked = true
	)
	_tween.tween_interval(_warning_duration_sec)
	_tween.tween_callback(func():
		_reset_sight()
		_shoot_gun()
	)
