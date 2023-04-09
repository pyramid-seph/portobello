class_name StateMachine
extends Node

@export var _initial_state: NodePath

@onready var _state := get_node(_initial_state) as State


func _ready() -> void:
	await get_parent().ready
	for child in get_children():
		child.state_machine = self
	_state.enter()


func is_in_state(state: String) -> bool:
	return _state.name == state


func _process(delta: float) -> void:
	_state.update(delta)

 
func change_state(state_name: String) -> void:
	if not has_node(state_name):
		return
	print("Exit: %s" % _state.get_name())
	_state.exit()
	_state = get_node(state_name)
	print("Enter: %s" % state_name)
	_state.enter()

