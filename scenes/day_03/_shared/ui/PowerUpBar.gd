extends HBoxContainer

const NORMAL_COLOR: Color = Color8(250, 172, 88)

var _tween: Tween

@onready var progress_bar := %ProgressBar as TextureProgressBar


func _ready() -> void:
	progress_bar.set_tint_progress(NORMAL_COLOR)


func _set_progress_color(color: Color) -> void:
	progress_bar.set_tint_progress(color)


func _cancel_maxed_out_anim() -> void:
	if _tween: 
		_tween.kill()
		_tween = null
		progress_bar.set_tint_progress(NORMAL_COLOR)


func _animate_maxed_out() -> void:
	_cancel_maxed_out_anim()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	_tween.set_loops()
	_tween.tween_callback(_set_progress_color.bind(Color.RED))
	_tween.tween_interval(Utils.FRAME_TIME)
	_tween.tween_callback(_set_progress_color.bind(NORMAL_COLOR))
	_tween.tween_interval(Utils.FRAME_TIME)


func _on_Day3Ui_power_up_changed(new_val: float, max_val: float) -> void:
	progress_bar.value = new_val * progress_bar.max_value / max_val
	if new_val < max_val: 
		_cancel_maxed_out_anim()
	else:
		_animate_maxed_out()
