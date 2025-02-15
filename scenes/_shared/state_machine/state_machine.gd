class_name StateMachine
extends Node

@export var _initial_state: NodePath

@onready var _state := get_node(_initial_state) as State


func _ready() -> void:
	await get_parent().ready
	for child: State in get_children():
		child.state_machine = self
	_state.enter()


func is_in_state(state: String) -> bool:
	return _state.name == state


func _process(delta: float) -> void:
	_state.update(delta) 


func change_state(state_name: String) -> void:
	if not has_node(state_name):
		return
	_debug_print("Exit: %s" % _state.get_name())
	_state.exit()
	_state = get_node(state_name)
	_debug_print("Enter: %s" % state_name)
	_state.enter()


func _debug_print(text: String) -> void:
	Log.d("[%s] %s" % [owner.name, text])
