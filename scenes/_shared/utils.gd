class_name Utils
extends RefCounted


const FRAME_TIME: float = 0.08


static func rand_item(arr: Array) -> Node:
	return arr.pick_random() if arr else null


static func first_or_null(arr: Array, callable: Callable):
	if arr == null or arr.is_empty():
		return null
	for item in arr:
		if callable.call(item):
			return item
	return null


static func count(arr: Array, callable: Callable) -> int:
	var total = 0
	if arr:
		for item in arr:
			if callable.call(item):
				total += 1
	return total


static func children_in_group(node: Node, group: String) -> Array[Node]:
	return node.get_children().filter(
		func(child: Node): 
			return child.is_in_group(group)
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


static func safe_disconnect_all(sg: Signal) -> void:
	for conn in sg.get_connections():
		safe_disconnect(conn["signal"], conn.callable)


static func safe_disconnect(sg: Signal, callable: Callable) -> void:
	if sg.is_connected(callable):
		sg.disconnect(callable)

static func safe_reparent(node: Node, new_parent: Node, keep_global_transform: bool = true) -> void:
	assert(node != null, "node cannot be null")
	assert(new_parent != null, "new_parent cannot be null")
	if node.get_parent() == new_parent:
		return
	if node.get_parent() == null:
		new_parent.add_child(node)
	else:
		node.reparent(new_parent, keep_global_transform)
