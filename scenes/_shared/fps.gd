extends CanvasLayer


@onready var _label: Label = %Label


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.alt_pressed and event.keycode == KEY_F and \
				not event.is_echo() and event.is_pressed():
			_label.visible = not _label.visible
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _label.visible:
		_label.text = str(Engine.get_frames_per_second())
