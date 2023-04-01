class_name Utils
extends RefCounted


const FRAME_TIME: float = 0.08


static func rand_item(arr: Array) -> Node:
	if arr == null or arr.is_empty():
		return null
	
	return arr[randi() % arr.size()]


static func first_or_null(arr: Array, callable: Callable):
	var filtered_arr = arr.filter(callable)
	return null if filtered_arr.is_empty() else filtered_arr[0]


static func count(arr: Array, callable: Callable) -> int:
	var total = 0
	if arr:
		for item in arr:
			if callable.call(item):
				total += 1
	return total


static func children_in_group(node: Node, group: String) -> Array[Node]:
	return node.get_children().filter(
		func(child: Node): return child.is_in_group(group)
	)


static func queue_free_group(node: Node, group: String) -> void:
	var items = children_in_group(node, group)
	for item in items:
		item.queue_free()


static func rand_child_in_group(node: Node, group: String) -> Node:
	var candidates = children_in_group(node, group)
	return rand_item(candidates)


static func vibrate_joy(
	device: int = 0, 
	weak_magnitude: float = 0.25,
	strong_magnitude: float = 0.25,
	duration: float = 0.25,
) -> void:
	if SaveDataManager.save_data.is_vibration_enabled:
		Input.start_joy_vibration(
			device, 
			weak_magnitude, 
			strong_magnitude, 
			duration
		)


static func change_label_color(label: Label, color: Color) -> void:
	if not label:
		return
	label.remove_theme_color_override("font_color")
	label.add_theme_color_override("font_color", color)
