extends Node


func shoot() -> void:
	# TODO Screen flash.
	get_tree().call_group("enemies", "kill")
	get_tree().call_group("bullets", "queue_free")

	PlayerData.power_up_count -= PlayerData.power_up_count
