class_name QuestManager
extends Node


signal progress_made

enum Steps {
	ONE, # Ask kitchen parrot to open the living room door
	TWO, # Defeat room parrot
	THREE, # Ask kitchen parrot to open the kitchen door
	FOUR, # Defeat the alien
	COMPLETED
}

var _curr_step: Steps


func get_curr_step() -> Steps:
	return _curr_step


func is_quest_completed() -> bool:
	return get_curr_step() == Steps.COMPLETED


func set_step_completed(step: Steps) -> void:
	if is_quest_completed() or step < _curr_step:
		return
	
	_curr_step = Steps.values()[mini(step + 1, Steps.size() - 1)]
	progress_made.emit()
