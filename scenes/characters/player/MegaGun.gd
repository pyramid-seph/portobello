extends Node


func shoot() -> void:
	# TODO Screen flash.
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.kill()

	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		bullet.queue_free()

	PlayerData.power_up_count -= PlayerData.power_up_count
