extends Node


var _is_prepared: bool = false


func revert_preparations() -> void:
	_is_prepared = false


func prepare() -> void:
	_is_prepared = true


func shoot() -> bool:
	if not _is_prepared: return false
	
	_is_prepared = false
	var scene_tree = get_tree()
	scene_tree.call_group("enemies", "kill", owner, true)
	scene_tree.call_group("bullets", "kill", owner, true)
	
	Utils.vibrate_joy()
	
	return true
