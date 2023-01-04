extends Control

@onready var blink_timer = $BlinkTimer
@onready var pause_label = $PauseLabel


func _on_BlinkTimer_timeout():
	pause_label.visible = not pause_label.visible


func _on_pause_state_changed(paused):
	visible = paused
	pause_label.visible = paused

	if paused:
		blink_timer.start()
	else:
		blink_timer.stop()


func _on_day_3_ui_pause_state_changed(new_state):
	_on_pause_state_changed(new_state)
