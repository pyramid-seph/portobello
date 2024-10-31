class_name Switch
extends RefCounted


signal switched

var is_on: bool:
	set(value):
		var old_value: bool = is_on
		is_on = value
		if value != old_value:
			switched.emit()


func _init(val: bool = false) -> void:
	set_is_on_no_signal(val)


func set_is_on_no_signal(val: bool) -> void:
	set_block_signals(true)
	is_on = val
	set_block_signals(false)
