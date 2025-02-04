class_name Switch
extends RefCounted


signal switched

var is_on: bool = true:
	set(value):
		var old_value: bool = is_on
		is_on = value
		if value != old_value:
			switched.emit()


func _init(value: bool = false) -> void:
	set_is_on_no_signal(value)


func set_is_on_no_signal(value: bool) -> void:
	set_block_signals(true)
	is_on = value
	set_block_signals(false)
