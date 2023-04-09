extends Area2D


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("bullets") or area.is_in_group("enemies"):
		area.queue_free()
