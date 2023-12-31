extends HBoxContainer


@onready var _label := $Label as Label


func _on_day_3_ui_lives_left_changed(new_val: int):
	_label.text = str(new_val)
