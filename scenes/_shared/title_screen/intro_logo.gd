# TODO Make this class abstract on Godot 4.5
# Abstract class
class_name IntroLogo
extends Control

@warning_ignore("unused_signal")
signal finished


func play() -> void:
	reset()
	_play()


# Abstract method.
func _play() -> void:
	pass


# Abstract method.
func reset() -> void:
	pass
