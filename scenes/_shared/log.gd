class_name Log
extends RefCounted


static func d(msg: String) -> void:
	if OS.is_debug_build():
		print(msg)


static func w(msg: String) -> void:
	if OS.is_debug_build():
		push_warning(msg)


static func e(msg: String) -> void:
	if OS.is_debug_build():
		push_error(msg)
