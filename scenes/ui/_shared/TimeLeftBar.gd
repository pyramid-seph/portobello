extends HBoxContainer

export var dangerous_level : float = 0.5

onready var progress_bar = $ProgressBar


func _on_Day3Ui_time_changed(new_val, max_value):
	progress_bar.value = new_val * progress_bar.max_value / max_value

	var new_tint
	if new_val > max_value * dangerous_level:
		new_tint = ColorN("blue")
	else:
		new_tint = Color8(237, 107, 247)

	progress_bar.set_tint_progress(new_tint)
