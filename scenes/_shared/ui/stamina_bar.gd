extends HBoxContainer

@export var dangerous_level: float = 0.5

@onready var _progress_bar = %ProgressBar


func _on_day_3_ui_stamina_changed(new_val: int, max_value: int) -> void:
	_progress_bar.value = new_val * _progress_bar.max_value / max_value
	
	var new_tint
	if new_val > max_value * dangerous_level:
		new_tint = Color.BLUE
	else:
		new_tint = Color8(237, 107, 247)

	_progress_bar.set_tint_progress(new_tint)
