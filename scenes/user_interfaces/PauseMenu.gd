extends Control


onready var blink_timer = $BlinkTimer
onready var pause_label = $PauseLabel
onready var scene_tree = get_tree()

func _input(event):
	if event.is_action_pressed("pause"):
		scene_tree.paused = not scene_tree.paused
		visible = scene_tree.paused
		pause_label.visible = scene_tree.paused
		
		if scene_tree.paused:
			blink_timer.start()
		else:
			blink_timer.stop()


func _on_BlinkTimer_timeout():
	pause_label.visible = not pause_label.visible
