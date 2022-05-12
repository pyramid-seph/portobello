extends Node

var _is_prepared: bool = false


func prepare() -> void:
	_is_prepared = true


func shoot() -> bool:
	if not _is_prepared:
		return false

	_is_prepared = false

	get_tree().call_group("enemies", "kill", owner)
	get_tree().call_group("bullets", "queue_free")

	return true
