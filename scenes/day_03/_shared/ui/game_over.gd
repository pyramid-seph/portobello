extends Label


func _on_day_3_ui_level_state_changed(new_state: Day03Level.LevelState) -> void:
	visible = new_state == Day03Level.LevelState.GAME_OVER
