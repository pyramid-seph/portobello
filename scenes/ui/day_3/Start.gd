extends Label


func _on_Day3Ui_level_state_changed(new_state):
	visible = new_state == 0
