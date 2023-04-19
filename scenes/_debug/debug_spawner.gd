extends Node

@export var world_path: NodePath = NodePath()
@export var things: Array[PackedScene]

var _selected_thing_index: int = 0 :
	get:
		return _selected_thing_index
	set(mod_value):
		_selected_thing_index = int(clamp(mod_value, 0, things.size() - 1))
		print("New spawn idx: %s" % _selected_thing_index)

@onready var world := get_node(world_path)


func _ready():
	if not OS.is_debug_build():
		queue_free()


func _input(event):
	_process_key_input(event)
	_process_mouse_input(event)


func _process_mouse_input(event):
	if not event is InputEventMouseButton:
		return

	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var new_thing = things[_selected_thing_index].instantiate()
		new_thing.position = event.position
		world.add_child(new_thing)


func _process_key_input(event):
	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	var new_index = -1
	match event.scancode:
		KEY_0:
			new_index = 9
		KEY_1:
			new_index = 0
		KEY_2:
			new_index = 1
		KEY_3:
			new_index = 2
		KEY_4:
			new_index = 3
		KEY_5:
			new_index = 4
		KEY_6:
			new_index = 5
		KEY_7:
			new_index = 6
		KEY_8:
			new_index = 7
		KEY_9:
			new_index = 8
	if (new_index != -1):
		_selected_thing_index = new_index