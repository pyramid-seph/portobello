extends Node


const FRAME_TIME: float = 0.08


func rand_item(arr: Array) -> Node:
	if arr == null or arr.is_empty():
		return null
	
	return arr[randi() % arr.size()]


func first_or_null(arr: Array, callable: Callable):
	var result = arr.filter(callable)
	if result.is_empty():
		return null
	return result[0]


func count(arr: Array, callable: Callable) -> int:
	var total = 0
	if arr:
		for item in arr:
			if callable.call(item):
				total += 1
	return total


func children_in_group(node: Node, group: String) -> Array[Node]:
	return node.get_children().filter(
		func(child: Node): return child.is_in_group(group)
	)


func queue_free_group(node: Node, group: String) -> void:
	var items = children_in_group(node, group)
	for item in items:
		item.queue_free()


func rand_child_in_group(node: Node, group: String) -> Node:
	var candidates = children_in_group(node, group)
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

func change_label_color(label: Label, color: Color) -> void:
	if not label: return
	label.remove_theme_color_override("font_color")
	label.add_theme_color_override("font_color", color)
