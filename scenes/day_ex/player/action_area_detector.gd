extends Area2D

signal action_area_detected
signal detected_action_area_exited

var _detected_action_area: ActionArea # TODO Should this better be a weakref?
var _detected_distance: float


func get_detected_action_area() -> ActionArea:
	return _detected_action_area


func is_executable_action_area_detected() -> bool:
	return _detected_action_area and _detected_action_area.is_executable()


func execute_detected_action_area(target: CharacterBody2D) -> bool:
	var is_executable: bool = is_executable_action_area_detected()
	if is_executable:
		_detected_action_area.execute(target)
	return is_executable


func _on_area_entered(candidate: ActionArea) -> void:
	if not candidate:
		return
	
	var candidate_distance: float = \
			candidate.global_position.distance_squared_to(global_position)
	
	if not _detected_action_area or candidate_distance < _detected_distance:
		_detected_action_area = candidate
		_detected_distance = candidate_distance
		action_area_detected.emit()


func _on_area_exited(action_area: ActionArea) -> void:
	if action_area == _detected_action_area:
		_detected_action_area = null
		_detected_distance = 0.0
		detected_action_area_exited.emit()
