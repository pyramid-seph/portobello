extends Area2D

signal action_area_detected
signal detected_action_area_exited

const ActionArea = preload("res://scenes/day_ex/game/speak_action_area.gd")

var _detected_action_area: ActionArea
var _detected_distance: float


func get_detected_action_area() -> ActionArea:
	return _detected_action_area


func is_action_area_detected() -> bool:
	return _detected_action_area != null


func execute_detected_action_area(target: CharacterBody2D) -> void:
	if _detected_action_area:
		_detected_action_area.execute(target)


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
