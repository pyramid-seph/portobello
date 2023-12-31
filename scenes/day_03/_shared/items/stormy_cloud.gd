extends MovingItem


func _on_pick_up(picker) -> void:
	if picker.has_method("power_up_by"):
		picker.power_up_by(1)
