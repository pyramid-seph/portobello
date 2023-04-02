extends VBoxContainer

const MIN_LABEL_2_VISIBILITY_DELAY: float = 1.6
const LABEL_2_COLOR_CHANGE_DELAY: float = 1.36
const MAKE_INVISIBLE_DELAY: float = MIN_LABEL_2_VISIBILITY_DELAY - LABEL_2_COLOR_CHANGE_DELAY

@export_color_no_alpha var label_2_font_color_out = Color.MAGENTA

var _tween: Tween

@onready var label_2 := $Label2 as Label


func start(time_sec: float) -> void:
	var label_2_visibility_delay = maxf(
		MIN_LABEL_2_VISIBILITY_DELAY, time_sec - MIN_LABEL_2_VISIBILITY_DELAY
	)
	
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_callback(func(): 
		visible = true
		label_2.visible = false
		label_2.remove_theme_color_override("font_color")
	)
	_tween.tween_callback(func(): 
		label_2.visible = true
	).set_delay(label_2_visibility_delay)
	_tween.tween_callback(func():
		label_2.add_theme_color_override("font_color", label_2_font_color_out)
	).set_delay(LABEL_2_COLOR_CHANGE_DELAY)
	_tween.tween_callback(func(): 
		visible = false
		_tween = null
	).set_delay(MAKE_INVISIBLE_DELAY)
