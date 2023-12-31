extends Label


func _on_day_3_ui_level_state_changed(new_state: int) -> void:
	visible = new_state == Day03Level.LevelState.LEVEL_COMPLETE
