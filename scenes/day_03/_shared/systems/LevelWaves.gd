class_name LevelWaves
extends RefCounted


var _waves: Array[Wave]


func get_waves() -> Array[Wave]:
	if _waves.is_empty(): _waves = _create_waves()
	return _waves


func _create_waves() -> Array[Wave]:
	return [];
