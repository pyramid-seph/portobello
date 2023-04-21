extends Node2D


@export var target: Node2D
@export var _cooldown: float = 1.0
@export var is_active: bool:
	set(value):
		var old_is_active = is_active
		is_active = value
		if old_is_active != is_active:
			_on_set_is_active()

var _pattern: Array[LaserBallsCannon]

@onready var _cannon_0 := $LaserBallsCannon0
@onready var _cannon_1 := $LaserBallsCannon1
@onready var _cannon_2 := $LaserBallsCannon2
@onready var _cannon_3 := $LaserBallsCannon3
@onready var _timer := $Timer as Timer
@onready var _is_ready: bool = true


func _ready() -> void:
	_on_set_is_active()


func _activate() -> void:
	_timer.start(_cooldown)


func _deactivate() -> void:
	_cannon_0.deactivate()
	_cannon_1.deactivate()
	_cannon_2.deactivate()
	_cannon_3.deactivate()
	_pattern.clear()
	_timer.stop()


func _on_set_is_active() -> void:
	if not _is_ready:
		return
	
	if is_active:
		_activate()
	else:
		_deactivate()


func _randomize_cannons_charge() -> void:
	print("Randomizing pattern")
	_pattern.clear()
	var pattern = randi() % 13
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


func _fire_charged_cannon(cannon: Node) -> void:
	cannon.fire()


func _on_timer_timeout() -> void:
	if target:
		_randomize_cannons_charge()
		print("Cannon count: %s" % _pattern.size())
		for cannon in _pattern:
			cannon.charge()
	else:
		print("No target set.")


func _on_laser_balls_cannon_target_detected() -> void:
	for cannon in _pattern:
		cannon.fire()


func _on_laser_balls_cannon_discharged() -> void:
	print("all discharged: %s" % _pattern.all(func(cannon): return cannon.is_discharged()))
	if _pattern.all(func(cannon): return cannon.is_discharged()):
		print("==============================================================")
		_timer.start(_cooldown)
