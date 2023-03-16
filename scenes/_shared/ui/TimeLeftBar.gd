extends HBoxContainer

@export var dangerous_level: float = 0.5

@onready var progress_bar = %ProgressBar


func _on_Day3Ui_time_changed(new_val: float, max_value: float):
	progress_bar.value = new_val * progress_bar.max_value / max_value
	print(str(progress_bar.value))

	var new_tint
	if new_val > max_value * dangerous_level:
		new_tint = Color.BLUE
	else:
		new_tint = Color8(237, 107, 247)

	progress_bar.set_tint_progress(new_tint)
