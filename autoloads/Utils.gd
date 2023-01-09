extends Node


const FRAME_TIME: float = 0.08


func rand_item(arr: Array) -> Node:
	if arr == null or arr.is_empty():
		return null
	
	return arr[randi() % arr.size()]


func childre_in_group(node: Node, group: String) -> Array[Node]:
	return node.get_children().filter(
		func(child: Node): return child.is_in_group(group)
	)


func rand_child_in_group(node: Node, group: String) -> Node:
	var candidates = childre_in_group(node, group)
	return rand_item(candidates)


func rand_item_in_group(group: String) -> Node:
	return rand_item(get_tree().get_nodes_in_group(group))


func get_item_count_in_group(group: String) -> int:
	return get_tree().get_nodes_in_group(group).size()


func vibrate_joy(
	device: int = 0, 
	weak_magnitude: float = 0.25,
	strong_magnitude: float = 0.25,
	duration: float = 0.25,
) -> void:
	if SaveDataManager.save_data.is_vibration_enabled:
		Input.start_joy_vibration(device, weak_magnitude, strong_magnitude, duration)
