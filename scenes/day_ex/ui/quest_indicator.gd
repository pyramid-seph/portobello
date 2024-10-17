extends Control


var _step_text_msg: String

@onready var _step_label: Label = $PanelContainer/VBoxContainer/StepLabel
@onready var _animation_player: AnimationPlayer = $AnimationPlayer



func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_step_label()


func set_step_text(text: String) -> void:
	_step_text_msg = text
	_update_step_label()
	


func appear(immediate: bool = false) -> void:
	if immediate:
		show()
	else:
		_animation_player.play(&"appear")


func disappear(immediate: bool = false) -> void:
	if immediate:
		hide()
	else:
		_animation_player.play_backwards(&"appear")


func _update_step_label() -> void:
	if is_node_ready():
		_step_label.text = "- %s" % tr(_step_text_msg)
