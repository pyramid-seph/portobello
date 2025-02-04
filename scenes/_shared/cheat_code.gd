extends Node


signal started
signal completed
signal failed

@export var _max_wait_between_inputs: float = 1.0
@export var _cheat_code: Array[StringName]
@export var disabled: bool:
	set(value):
		disabled = value
		_on_disabled_set()

var _timer: float
var _curr_idx: int


func _ready() -> void:
	_on_disabled_set()


func _process(delta: float) -> void:
	if _curr_idx > 0:
		_timer += delta
		if _timer > _max_wait_between_inputs:
			_on_failed_attempt()


func _input(event: InputEvent) -> void:
	if event.is_echo() or event.is_released() or event.is_canceled():
		return
	
	var curr_input: StringName = _cheat_code[_curr_idx]
	if event.is_action_pressed(curr_input):
		_timer = 0.0
		
		if _curr_idx == 0:
			started.emit()
		
		_curr_idx += 1
		
		if _curr_idx > _cheat_code.size() - 1:
			disabled = true
			completed.emit()
	else:
		_on_failed_attempt()


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"_cheat_code", "_max_wait_between_inputs":
			property.usage |= PROPERTY_USAGE_READ_ONLY


func _restart_cheat_attempt() -> void:
	_timer = 0.0
	_curr_idx = 0


func _on_failed_attempt() -> void:
	_restart_cheat_attempt()
	failed.emit()


func _on_disabled_set() -> void:
	if not is_node_ready():
		return
	
	if disabled:
		set_process(false)
		set_process_input(false)
	else:
		_restart_cheat_attempt()
		set_process(true)
		set_process_input(true)
