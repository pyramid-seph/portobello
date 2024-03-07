class_name Day03BossFight
extends Node

signal completed


func prepare() -> void:
	pass


func start() -> void:
	completed.emit()


func cleanup() -> void:
	pass
