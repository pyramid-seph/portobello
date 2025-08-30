class_name Utils
extends RefCounted


const FRAME_TIME: float = 0.08


static func round_up(value: float, multiple: float) -> int:
	var valuei: int = maxi(0, ceili(value))
	var stepi: int = int(multiple)
	var n: int = valuei
	var remainder: int = n % stepi
	if remainder > 0:
		n = n + stepi - remainder
	return n


static func rand_item(arr: Array) -> Node:
	return arr.pick_random() if arr else null


static func rand_weigthed(weights: Array[float]) -> int:
	if not weights or weights.is_empty():
		return -1
	
	var remaining_distance: float = \
			randf() * weights.reduce(func(accum, number): 
						return accum + number)
	var picked_index: int = -1
	for i: int in weights.size():
		remaining_distance -= weights[i]
		if remaining_distance < 0:
			picked_index = i
			break
	return picked_index


static func first_or_null(arr: Array, callable: Callable):
	if arr == null or arr.is_empty():
		return null
	for item in arr:
		if callable.call(item):
			return item
	return null


## Returns first index of the element that satisfy the given predicate,
##  or -1 if no element satisfy it.
static func index_of(arr: Array, predicate: Callable) -> int:
	if arr == null or arr.is_empty():
		return -1
	for index in range(0, arr.size()):
		if predicate.call(arr[index]):
			return index
	return -1


static func count(arr: Array, callable: Callable) -> int:
	var total = 0
	if arr:
		for item in arr:
			if callable.call(item):
				total += 1
	return total


static func partition(arr: Array, callable: Callable) -> Array:
	var group_a := []
	var group_b := []
	for item in arr:
		if callable.call(item):
			group_a.append(item)
		else:
			group_b.append(item)
	return [group_a, group_b]


static func children_in_group(node: Node, group: String) -> Array[Node]:
	return node.get_children().filter(
		func(child: Node): 
			return child.is_in_group(group)
	)


static func queue_free_group(node: Node, group: String) -> void:
	var items = children_in_group(node, group)
	for item: Node in items:
		item.queue_free()


static func rand_child_in_group(node: Node, group: String) -> Node:
	var candidates = children_in_group(node, group)
	return rand_item(candidates)


static func can_run_js() -> bool:
	return OS.has_feature("web")


static func vibrate_joy(
	device: int = 0, 
	weak_magnitude: float = 0.25,
	strong_magnitude: float = 0.25,
	duration: float = 0.25,
	force: bool = false,
) -> void:
	if force or SaveDataManager.save_data.is_vibration_enabled:
		if TouchControllerManager.is_touch_controller_active():
			Input.vibrate_handheld(int(duration * 1_000.0))
		elif is_running_on_web():
			_vibrate_joy_web_workaround(
				device,
				weak_magnitude,
				strong_magnitude,
				duration
			)
		else:
			Input.start_joy_vibration(
				device, 
				weak_magnitude, 
				strong_magnitude, 
				duration
			)


static func vibrate_joy_demo() -> void:
	vibrate_joy(0, 0.25, 0.25, 0.25, true)


static func change_label_color(label: Label, color: Color) -> void:
	if label:
		label.remove_theme_color_override("font_color")
		label.add_theme_color_override("font_color", color)


static func change_label_outline_color(label: Label, color: Color) -> void:
	if label:
		label.remove_theme_color_override("font_outline_color")
		label.add_theme_color_override("font_outline_color", color)


static func safe_disconnect_all(sg: Signal) -> void:
	for conn in sg.get_connections():
		safe_disconnect(conn.signal, conn.callable)


static func safe_disconnect(sg: Signal, callable: Callable) -> void:
	if sg.is_connected(callable):
		sg.disconnect(callable)


static func safe_connect(sg: Signal, callable: Callable, flags: int = 0) -> void:
	if not sg.is_connected(callable):
		sg.connect(callable, flags)


static func safe_reparent(
	node: Node,
	new_parent: Node,
	keep_global_transform: bool = true
) -> void:
	assert(node != null, "node cannot be null")
	assert(new_parent != null, "new_parent cannot be null")
	if node.get_parent() == new_parent:
		return
	if node.get_parent() == null:
		new_parent.add_child(node)
	else:
		node.reparent(new_parent, keep_global_transform)


## @Deprecated Use array.back() instead.
static func last(arr: Array):
	return arr.back()


static func last_child(node: Node):
	return null if node == null else last(node.get_children())


static func is_running_on_web() -> bool:
	return OS.get_name() == "Web"


static func get_game_version() -> String:
	return "v%s" % ProjectSettings.get_setting("application/config/version")


static func _vibrate_joy_web_workaround(
	device: int = 0, 
	weak_magnitude: float = 0.25,
	strong_magnitude: float = 0.25,
	duration: float = 0.25,
) -> void:
	if not can_run_js():
		return
	
	# This workaround uses an experimental API.
	# It does not work on every web browser or device.
	# More info:
	# https://developer.mozilla.org/en-US/docs/Web/API/Gamepad/vibrationActuator
	# Related issues:
	# https://github.com/godotengine/godot/issues/14634
	JavaScriptBridge.eval("""
		const gamepads = navigator.getGamepads();
		if (gamepads.length > 0) {
			const gamepad = gamepads[%s];
			if (gamepad && gamepad.vibrationActuator) {
				gamepad.vibrationActuator.playEffect("dual-rumble", {
					startDelay: 0,
					duration: %s,
					weakMagnitude: %s,
					strongMagnitude: %s,
				});
			}
		}
	""" % [device, duration * 1_000.0, weak_magnitude, strong_magnitude])


static func get_default_language() -> String:
	var system_lang: String = OS.get_locale_language()
	return system_lang if system_lang in ["en", "es"] else "en"
