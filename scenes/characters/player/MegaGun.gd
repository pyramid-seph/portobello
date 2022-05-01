extends Node

var _is_prepared = false


func is_powered_up() -> bool:
	return PlayerData.power_up_count >= 5


func prepare():
	_is_prepared = true


func shoot() -> bool:
	if not _is_prepared:
		return false

	_is_prepared = false

	get_tree().call_group("enemies", "kill")
	get_tree().call_group("bullets", "queue_free")

	PlayerData.power_up_count -= PlayerData.power_up_count
	return true
