class_name Log
extends RefCounted


static func d(msg: String, ...args: Array) -> void:
	if OS.is_debug_build():
		print.callv([msg] + args)


static func w(msg: String, ...args: Array) -> void:
	if OS.is_debug_build():
		push_warning.callv([msg] + args)


static func e(msg: String, ...args: Array) -> void:
	if OS.is_debug_build():
		push_error.callv([msg] + args)
