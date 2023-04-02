extends Label


func _on_day_3_ui_hi_score_changed(new_val:int) -> void:
	text = "Hi %s" % str(new_val)
