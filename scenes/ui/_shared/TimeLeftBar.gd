extends HBoxContainer

export var max_time_seconds := 25.0
export var danger_zone_time_seconds := 12.5

onready var progress_bar = $ProgressBar


func _on_Day3Ui_time_left_changed(new_val):
	progress_bar.value = new_val * progress_bar.max_value / max_time_seconds

	var new_tint
	if new_val > danger_zone_time_seconds:
		new_tint = ColorN("blue")
	else:
		new_tint = Color8(237, 107, 247)

	progress_bar.set_tint_progress(new_tint)
