extends Label


func _on_Day3Ui_level_state_changed(new_state: int) -> void:
	visible = new_state == Day03Level.LevelState.GAME_OVER
