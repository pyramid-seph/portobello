extends Label


func _on_Day3Ui_hi_score_changed(new_val):
	text = "hi %s" % str(new_val)
