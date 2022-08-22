extends Node


const FRAME_TIME = 0.08


static func rand_item(arr: Array) -> Node:
	if arr == null or arr.empty():
		return null
	
	return arr[randi() % arr.size()]


func rand_item_in_group(group: String) -> Node:
	return rand_item(get_tree().get_nodes_in_group(group))


func get_item_count_in_group(group: String) -> int:
	return get_tree().get_nodes_in_group(group).size()
