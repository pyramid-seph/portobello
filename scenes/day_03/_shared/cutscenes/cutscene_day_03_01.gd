extends Node2D

signal finished


func _on_timer_timeout() -> void:
	print("Cutscene finished")
	finished.emit()
