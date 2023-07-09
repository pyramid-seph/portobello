class_name Day01LevelSettings
extends Resource

const _DEFAULT_PACE: float = 0.25

enum ObstacleCourseType {
	NONE,
	DEFAULT,
	RANDOM,
}

@export var pace_thresholds: Dictionary:
	set(value):
		pace_thresholds = value
		_pace_thresholds_changed()
@export var time_limit_sec: float
@export var treats_limit: int
@export var obstacle_course_type: ObstacleCourseType
@export var inverted_controls: bool
@export var dialogue: Array[DialogueLine]

var _thresholds: Array:
	get:
		if _thresholds.is_empty():
			_pace_thresholds_changed()
		return _thresholds


func is_time_limited() -> bool:
	return time_limit_sec > 0


func limits_treats() -> bool:
	return treats_limit > 0


func get_pace(eaten_treats: int) -> float:
	if _thresholds.is_empty():
		return _DEFAULT_PACE
	
	if _thresholds.size() == 1:
		return pace_thresholds[_thresholds[0]]
	
	for threshold in _thresholds:
		if eaten_treats >= threshold:
			return pace_thresholds[threshold]
	return _DEFAULT_PACE


func _pace_thresholds_changed() -> void:
	var thresholds := pace_thresholds.keys()
	thresholds.sort()
	thresholds.reverse()
	_thresholds = thresholds
