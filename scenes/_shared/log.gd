class_name Log
extends RefCounted


static func d(...args: Array) -> void:
	if OS.is_debug_build():
		print.callv(args)


static func w(...args: Array) -> void:
	if OS.is_debug_build():
		push_warning.callv(args)


static func e(...args: Array) -> void:
	if OS.is_debug_build():
		push_error.callv(args)
