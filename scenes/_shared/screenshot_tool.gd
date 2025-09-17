extends Node


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("take_screenshot"):
		take_screenshot()


func take_screenshot() -> void:
	var time: String = Time.get_datetime_string_from_system(true).replace(":", "-")
	var filepath: String = "user://screenshot_%s.png" % time
	if get_viewport().get_texture().get_image().save_png(filepath) == OK:
		Log.d("Screenshot saved on: ", filepath)
	else:
		Log.d("Error while saving screenshot on: ", filepath)
