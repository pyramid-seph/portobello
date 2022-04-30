extends HBoxContainer


func _on_Day3Ui_lives_left_changed(new_val):
	$Label.text = str(new_val)
